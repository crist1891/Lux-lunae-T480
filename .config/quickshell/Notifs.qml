pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The shell is the notification daemon (replaces mako): keeps every notification until it is dismissed,
// and shows a short-lived toast for new ones.
Singleton {
    id: root
    readonly property var model: srv.trackedNotifications
    readonly property int count: srv.trackedNotifications.values.length
    property var toasts: []          // [{key, app, summary, body, urgency, t}]
    property int seq: 0

    function clearAll() {
        var v = srv.trackedNotifications.values.slice()
        for (var i = 0; i < v.length; i++) v[i].dismiss()
        root.toasts = []
    }
    function pruneToasts() {
        var now = Date.now(), keep = []
        for (var i = 0; i < root.toasts.length; i++)
            if (now - root.toasts[i].t < 6500) keep.push(root.toasts[i])
        if (keep.length !== root.toasts.length) root.toasts = keep
    }

    NotificationServer {
        id: srv
        keepOnReload: true
        actionsSupported: false
        bodySupported: true
        imageSupported: false
        onNotification: n => {
            n.tracked = true
            var t = root.toasts.slice()
            t.push({ key: ++root.seq, app: n.appName, summary: n.summary, body: n.body, urgency: n.urgency, t: Date.now() })
            root.toasts = t.slice(-4)
        }
    }
    Timer { interval: 1000; running: root.toasts.length > 0; repeat: true; onTriggered: root.pruneToasts() }

    IpcHandler {
        target: "notifs"
        function clear(): void { root.clearAll() }
    }
}
