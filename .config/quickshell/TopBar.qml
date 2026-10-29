import Quickshell
import QtQuick

// One dark translucent bar; every element sits directly on it.
// Slides DOWN from the top when a window is open, slides back up at the desktop.
PanelWindow {
    id: win
    readonly property bool shown: !Desktop.atDesktop
    readonly property string emblem: "file://" + Quickshell.env("HOME") + "/.config/lux/shadow22-emblem.png"

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.topBarH
    // Always mapped with a constant reserved strip: tiling never has to be
    // recalculated when the bar slides in or out (it just animates).
    exclusionMode: ExclusionMode.Auto
    color: "transparent"

    Rectangle {
        id: slab
        width: parent.width
        height: Theme.topBarH
        y: win.shown ? 0 : -height
        color: Theme.bg
        Behavior on y { NumberAnimation { duration: Theme.slideMs; easing.type: Easing.InOutCubic } }

        // bottom edge line + scale ticks (all 1px)
        Rule { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; tone: Theme.gold }
        Item {
            id: ticks
            anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.line
            width: parent.width; height: 5
            Repeater {
                model: Math.floor(slab.width / 6)
                delegate: Rectangle {
                    x: 4 + index * 6
                    width: Theme.line
                    height: index % 5 === 0 ? 5 : 3
                    y: ticks.height - height
                    color: Theme.dim
                }
            }
        }

        // ── left ──
        Row {
            anchors.left: parent.left; anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            spacing: 12
            Item {                                   // emblem → launcher
                width: 28; height: 32
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.fill: parent
                    source: win.emblem
                    fillMode: Image.PreserveAspectFit
                    smooth: true; mipmap: true
                    opacity: em.containsMouse ? 1.0 : 0.9
                }
                MouseArea {
                    id: em; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["sh", "-c", "pkill wofi || wofi --show drun"])
                }
            }
            Text {                                   // name → KDE Connect
                text: "Lux Lunae"
                color: nm.containsMouse ? Theme.lgold : Theme.moon
                font.family: Theme.display; font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: nm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["kdeconnect-app"])
                }
            }
            Rule { vertical: true; implicitHeight: 14; anchors.verticalCenter: parent.verticalCenter }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                Repeater { model: 10; delegate: WsCell { n: index + 1; vertical: false } }
            }
            Rule { vertical: true; implicitHeight: 14; anchors.verticalCenter: parent.verticalCenter; visible: win.width > 1700 }
            Text {
                visible: win.width > 1700
                width: 240
                text: Desktop.title !== "" ? "▸ " + Desktop.title : ""
                elide: Text.ElideRight
                color: Theme.gold
                font.family: Theme.mono; font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── center: time + date ──
        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            spacing: 14
            Text {
                text: Time.timeRich
                textFormat: Text.RichText
                color: Theme.moon
                font.family: Theme.mono; font.pixelSize: 20; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Rule { vertical: true; implicitHeight: 14; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: Time.dateRich
                textFormat: Text.RichText
                color: Theme.lgold
                font.family: Theme.mono; font.pixelSize: 13; font.letterSpacing: 1
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── right: notification centre, readouts ──
        Row {
            anchors.right: parent.right; anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            spacing: 12

            Item {                                   // notification centre: crosshair = empty, number = unread
                id: bell
                width: 24; height: 24
                anchors.verticalCenter: parent.verticalCenter
                Icon {
                    visible: Notifs.count === 0
                    anchors.centerIn: parent
                    name: "crosshair"; size: 20
                    color: Ui.open === "notif" ? Theme.moon : Theme.gold
                }
                Text {
                    visible: Notifs.count > 0
                    anchors.centerIn: parent
                    text: "" + Notifs.count
                    color: Theme.red
                    font.family: Theme.mono; font.pixelSize: 16; font.bold: true
                }
                MouseArea {
                    anchors.fill: parent; anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var p = bell.mapToItem(null, bell.width / 2, 0)
                        Ui.toggle("notif", p.x, 0)
                    }
                }
            }

            MiniGauge { label: "CPU"; pct: Stats.cpu; valueText: Stats.cpu + "%"; anchors.verticalCenter: parent.verticalCenter }
            MiniGauge { label: "TMP"; pct: Stats.tempC; valueText: Stats.tempC >= 0 ? Stats.tempC + "°" : "—"; anchors.verticalCenter: parent.verticalCenter }
            MiniGauge { visible: win.width > 1700; label: "MEM"; pct: Stats.memPct; valueText: Stats.memPct + "%"; anchors.verticalCenter: parent.verticalCenter }
            MiniGauge { label: "VOL"; pct: Audio.muted ? 0 : Audio.vol; valueText: Audio.muted ? "MUT" : Audio.vol + "%"; dimmed: Audio.muted; anchors.verticalCenter: parent.verticalCenter }
            Item {                                   // mic status
                width: 16; height: 18
                anchors.verticalCenter: parent.verticalCenter
                Icon { anchors.centerIn: parent; name: Audio.micMuted ? "micoff" : "mic"; size: 16; color: Audio.micMuted ? Theme.red : Theme.dim }
                MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: Audio.toggleMic() }
            }
            Text {
                visible: win.width > 1700
                text: "▼" + Stats.rxKB + " ▲" + Stats.txKB
                color: Theme.lgold
                font.family: Theme.mono; font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
            MiniGauge { visible: Stats.bat >= 0; label: "BAT"; pct: Stats.bat; valueText: Stats.bat + "%"; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "⏻"
                color: pw.containsMouse ? Theme.moon : Theme.red
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: pw
                    anchors.fill: parent; anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/lux/powermenu.sh"])
                }
            }
        }
    }
}
