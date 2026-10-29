import QtQuick

// Notification centre: drops down under the top bar, centred on the bell icon.
PopPanel {
    id: p
    name: "notif"
    dir: "down"
    panelW: 380
    panelH: Math.max(170, Math.min(460, 80 + Notifs.count * 72))

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            width: parent.width; height: 30
            Text {
                id: ttl
                anchors.verticalCenter: parent.verticalCenter
                text: "NOTIFICATIONS"
                color: Theme.moon; font.family: Theme.display; font.pixelSize: 20
            }
            Text {
                anchors.left: ttl.right; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: Notifs.count > 0 ? "" + Notifs.count : ""
                color: Theme.red; font.family: Theme.mono; font.pixelSize: 14; font.bold: true
            }
            Chip {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: Notifs.count > 0
                text: "CLEAR ALL"
                onClicked: Notifs.clearAll()
            }
        }
        Rule { width: parent.width; tone: Theme.gold }

        Item {
            width: parent.width
            height: parent.height - 30 - 1 - 20

            Column {
                anchors.centerIn: parent
                visible: Notifs.count === 0
                spacing: 10
                Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "crosshair"; size: 44; color: Theme.dim }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "NO SIGNAL"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 3 }
            }

            Flickable {
                anchors.fill: parent
                visible: Notifs.count > 0
                clip: true
                contentHeight: list.height
                boundsBehavior: Flickable.StopAtBounds
                Column {
                    id: list
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: Notifs.model
                        delegate: Rectangle {
                            required property var modelData
                            width: list.width
                            height: body.y + body.height + 12
                            color: Theme.tonal
                            Rectangle { width: 3; height: parent.height; color: modelData.urgency === 2 ? Theme.red : Theme.gold }
                            Text {
                                id: app
                                x: 14; y: 8
                                text: (modelData.appName || "").toUpperCase()
                                color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2
                            }
                            Text {
                                id: sum
                                x: 14; y: app.y + app.height + 3
                                width: parent.width - 52
                                text: modelData.summary
                                elide: Text.ElideRight
                                color: Theme.moon; font.family: Theme.mono; font.pixelSize: 12; font.bold: true
                            }
                            Text {
                                id: body
                                x: 14; y: sum.y + sum.height + 3
                                width: parent.width - 28
                                text: modelData.body
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 10
                            }
                            MouseArea {
                                x: parent.width - 34; y: 4; width: 30; height: 30
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.dismiss()
                                Icon { anchors.centerIn: parent; name: "close"; size: 12; color: Theme.dim }
                            }
                        }
                    }
                }
            }
        }
    }
}
