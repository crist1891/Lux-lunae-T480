pragma Singleton
import QtQuick
import Quickshell

// Which pop-out panel is open and where it should appear.
Singleton {
    id: root
    property string open: ""     // "", "notif", "net", "bt", "quick"
    property real anchorX: 0     // down-pop-outs: centre x of the trigger
    property real anchorY: 0     // right-pop-outs: centre y of the trigger
    function toggle(name, x, y) {
        if (root.open === name) { root.open = ""; return }
        root.anchorX = x
        root.anchorY = y
        root.open = name
    }
    function close() { root.open = "" }
}
