pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Tracks the active workspace so the shell knows desktop vs. window mode.
Singleton {
    id: root

    property int windows: 0
    property int workspaceId: 1
    property string title: ""
    // true only after the workspace has stayed empty for a moment
    property bool atDesktop: true

    function apply() {
        if (root.windows > 0) { settle.stop(); root.atDesktop = false }
        else if (!root.atDesktop && !settle.running) settle.start()
    }
    Timer { id: settle; interval: 350; onTriggered: if (root.windows === 0) root.atDesktop = true }

    function parse(t) {
        var parts = t.split("@@@")
        try {
            var w = JSON.parse(parts[0])
            root.windows = w.windows || 0
            root.workspaceId = w.id || 1
            root.apply()
        } catch (e) {}
        try {
            var a = JSON.parse(parts[1])
            root.title = a.title || ""
        } catch (e) { root.title = "" }
    }

    Process {
        id: query
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/hypr-state.sh"]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) { debounce.restart() }
    }
    Timer { id: debounce; interval: 60; onTriggered: query.running = true }
    // safety net in case an event is missed
    Timer { interval: 1500; running: true; repeat: true; triggeredOnStart: true; onTriggered: query.running = true }
}
