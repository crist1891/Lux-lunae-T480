import Quickshell
import QtQuick

// Short-lived pop-ups for new notifications, top right.
PanelWindow {
    id: win
    anchors { top: true; right: true }
    margins { top: Theme.topBarH + 10; right: 12 }
    implicitWidth: 340
    implicitHeight: Math.max(1, col.height)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifs.toasts.length > 0

    Column {
        id: col
        width: parent.width
        spacing: 8
        Repeater {
            model: Notifs.toasts
            delegate: Rectangle {
                required property var modelData
                width: col.width
                height: tb.y + tb.height + 12
                color: Theme.panel
                border.width: Theme.line
                border.color: modelData.urgency === 2 ? Theme.red : Theme.gold
                Text {
                    id: ta
                    x: 14; y: 9
                    text: (modelData.app || "").toUpperCase()
                    color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2
                }
                Text {
                    id: ts
                    x: 14; y: ta.y + ta.height + 3
                    width: parent.width - 28
                    text: modelData.summary
                    elide: Text.ElideRight
                    color: Theme.moon; font.family: Theme.mono; font.pixelSize: 12; font.bold: true
                }
                Text {
                    id: tb
                    x: 14; y: ts.y + ts.height + 3
                    width: parent.width - 28
                    text: modelData.body
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 10
                }
            }
        }
    }
}
