import QtQuick
import Quickshell

// One workspace: moon (crescent -> full across 1..10) + number, active number red.
Item {
    id: c
    property int n: 1
    property bool vertical: true
    readonly property bool active: Desktop.workspaceId === n
    readonly property string moon: n <= 3 ? "🌒" : n <= 5 ? "🌓" : n <= 9 ? "🌔" : "🌕"

    implicitWidth: vertical ? 58 : g.implicitWidth + 12
    implicitHeight: vertical ? 46 : 30

    Grid {
        id: g
        anchors.centerIn: parent
        columns: c.vertical ? 1 : 2
        spacing: c.vertical ? 2 : 5
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        Text {
            text: c.moon
            font.pixelSize: c.vertical ? 20 : 14
            opacity: c.active ? 1.0 : 0.55
        }
        Text {
            text: "" + c.n
            color: c.active ? Theme.red : Theme.dim
            font.family: Theme.mono
            font.pixelSize: 12
            font.bold: c.active
        }
    }
    Rectangle {
        visible: c.active
        height: Theme.line; color: Theme.gold
        width: g.width + 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + c.n + " })"])
    }
}
