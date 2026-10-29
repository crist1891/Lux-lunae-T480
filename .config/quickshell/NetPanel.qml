import QtQuick

// Wi-Fi panel: current connection + nearby networks (NetworkManager).
PopPanel {
    id: p
    name: "net"
    dir: "right"
    panelW: 340
    panelH: 440
    onShownChanged: if (shown) Net.refresh()

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            width: parent.width; height: 30
            Icon { id: wi; anchors.verticalCenter: parent.verticalCenter; name: "wifi"; size: 20; color: Theme.gold }
            Text { anchors.left: wi.right; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "WI-FI"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 20 }
            Chip { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Net.wifiOn ? "ON" : "OFF"; active: Net.wifiOn; onClicked: Net.setWifi(!Net.wifiOn) }
        }
        Rule { width: parent.width; tone: Theme.gold }

        Column {
            width: parent.width
            spacing: 5
            Text { text: "CONNECTED"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
            Text {
                width: parent.width
                text: Stats.ssid !== "" ? Stats.ssid : (Stats.iface !== "none" && Stats.iface !== "—" ? Stats.iface + " (wired)" : "NOT CONNECTED")
                elide: Text.ElideRight
                color: Theme.moon; font.family: Theme.mono; font.pixelSize: 14; font.bold: true
            }
            Segments { visible: Stats.ssid !== ""; width: parent.width; pct: Stats.sigPct; count: 20; barHeight: 6 }
            Text { text: "▼ " + Stats.rxKB + " KB/s     ▲ " + Stats.txKB + " KB/s"; color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 10 }
        }

        Item {
            width: parent.width; height: 30
            Text { anchors.verticalCenter: parent.verticalCenter; text: "NETWORKS"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Chip { text: "RESCAN"; onClicked: Net.rescan() }
                Chip { text: "EDITOR"; onClicked: Net.openEditor() }
            }
        }

        Flickable {
            width: parent.width
            height: parent.height - y
            clip: true
            contentHeight: nl.height
            boundsBehavior: Flickable.StopAtBounds
            Column {
                id: nl
                width: parent.width
                spacing: 4
                Text {
                    visible: Net.networks.length === 0
                    text: "No networks listed. Needs NetworkManager (nmcli)."
                    color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10
                    wrapMode: Text.Wrap; width: parent.width
                }
                Repeater {
                    model: Net.networks
                    delegate: Rectangle {
                        required property var modelData
                        width: nl.width; height: 38
                        color: ma.containsMouse ? Theme.tonalHi : Theme.tonal
                        Rectangle { visible: modelData.active; width: 3; height: parent.height; color: Theme.gold }
                        Icon { visible: modelData.secured; x: 12; anchors.verticalCenter: parent.verticalCenter; name: "lock"; size: 12; color: Theme.dim }
                        Text {
                            x: 32; anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 92
                            text: modelData.ssid
                            elide: Text.ElideRight
                            color: modelData.active ? Theme.lgold : Theme.moon; font.family: Theme.mono; font.pixelSize: 12
                        }
                        Text {
                            anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                            text: modelData.signal + "%"
                            color: Theme.gold; font.family: Theme.mono; font.pixelSize: 11
                        }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Net.connectTo(modelData.ssid) }
                    }
                }
            }
        }
    }
}
