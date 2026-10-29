import Quickshell
import QtQuick

// A right-angled pop-out panel. dir "down": drops from the top bar, centred on the trigger.
// dir "right": grows out of the side panel, level with the trigger.
// The window is full-screen and transparent so a click anywhere outside closes it.
PanelWindow {
    id: win
    property string name: ""
    property string dir: "down"
    property int panelW: 360
    property int panelH: 400
    default property alias content: holder.data
    readonly property bool shown: Ui.open === name

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown || hideT.running
    onShownChanged: hideT.restart()
    Timer { id: hideT; interval: Theme.slideMs + 80 }

    MouseArea { anchors.fill: parent; onClicked: Ui.close() }

    readonly property real px: dir === "down"
        ? Math.max(8, Math.min(width - panelW - 8, Ui.anchorX - panelW / 2))
        : 12 + 330 + 6
    readonly property real py: dir === "down"
        ? Theme.topBarH + 5
        : Math.max(8, Math.min(height - panelH - 8, Ui.anchorY - 30))

    Item {
        id: clip
        x: win.px; y: win.py
        width: win.dir === "down" ? win.panelW : (win.shown ? win.panelW : 0)
        height: win.dir === "down" ? (win.shown ? win.panelH : 0) : win.panelH
        clip: true
        Behavior on width  { NumberAnimation { duration: Theme.slideMs; easing.type: Easing.InOutCubic } }
        Behavior on height { NumberAnimation { duration: Theme.slideMs; easing.type: Easing.InOutCubic } }

        Rectangle {
            width: win.panelW; height: win.panelH
            color: Theme.panel
            border.width: Theme.line; border.color: Theme.gold
            MouseArea { anchors.fill: parent }          // clicks inside stay inside
            Item { id: holder; anchors.fill: parent; anchors.margins: 14 }
        }
    }
}
