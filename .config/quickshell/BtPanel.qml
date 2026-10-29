import QtQuick

// Bluetooth panel: power, devices, connect / disconnect.
PopPanel {
    id: p
    name: "bt"
    dir: "right"
    panelW: 340
    panelH: 400
    onShownChanged: if (shown) Bt.refresh()

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            width: parent.width; height: 30
            Icon { id: bi; anchors.verticalCenter: parent.verticalCenter; name: "bluetooth"; size: 20; color: Theme.gold }
            Text { anchors.left: bi.right; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "BLUETOOTH"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 20 }
            Chip { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Bt.powered ? "ON" : "OFF"; active: Bt.powered; onClicked: Bt.setPower(!Bt.powered) }
        }
        Rule { width: parent.width; tone: Theme.gold }

        Item {
            width: parent.width; height: 30
            Text { anchors.verticalCenter: parent.verticalCenter; text: "DEVICES"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Chip { text: "SCAN"; onClicked: Bt.scan() }
                Chip { text: "MANAGER"; onClicked: Bt.openManager() }
            }
        }

        Flickable {
            width: parent.width
            height: parent.height - y
            clip: true
            contentHeight: dl.height
            boundsBehavior: Flickable.StopAtBounds
            Column {
                id: dl
                width: parent.width
                spacing: 4
                Text {
                    visible: Bt.devices.length === 0
                    text: Bt.powered ? "No devices yet — press SCAN." : "Bluetooth is off."
                    color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10
                    wrapMode: Text.Wrap; width: parent.width
                }
                Repeater {
                    model: Bt.devices
                    delegate: Rectangle {
                        required property var modelData
                        width: dl.width; height: 40
                        color: dma.containsMouse ? Theme.tonalHi : Theme.tonal
                        Rectangle { visible: modelData.connected; width: 3; height: parent.height; color: Theme.gold }
                        Text {
                            x: 14; anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 120
                            text: modelData.name
                            elide: Text.ElideRight
                            color: modelData.connected ? Theme.lgold : Theme.moon; font.family: Theme.mono; font.pixelSize: 12
                        }
                        Text {
                            anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                            text: modelData.connected ? "CONNECTED" : "CONNECT"
                            color: modelData.connected ? Theme.gold : Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 1
                        }
                        MouseArea {
                            id: dma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.connected ? Bt.disconnectDev(modelData.mac) : Bt.connectDev(modelData.mac)
                        }
                    }
                }
            }
        }
    }
}
