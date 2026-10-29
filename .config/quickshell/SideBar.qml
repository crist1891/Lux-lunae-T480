import Quickshell
import QtQuick

// Tall MFD-style panel on the left. Visible only when the workspace has no windows.
// Leaves by sliding UP off the screen; returns by sliding down from the top.
PanelWindow {
    id: win
    readonly property bool shown: Desktop.atDesktop
    readonly property int pad: 12
    readonly property string emblem: "file://" + Quickshell.env("HOME") + "/.config/lux/shadow22-emblem.png"

    function stateText(s) { return (s || "").replace(/_/g, " ").toUpperCase() }
    function launcher() { Quickshell.execDetached(["sh", "-c", "pkill wofi || wofi --show drun"]) }

    anchors { left: true; top: true; bottom: true }
    implicitWidth: 330 + pad
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown || hide.running
    onShownChanged: hide.restart()
    Timer { id: hide; interval: Theme.slideMs + 100 }

    Rectangle {
        id: slab
        x: win.pad
        width: 330
        height: win.height - win.pad * 2
        y: win.shown ? win.pad : -(height + win.pad)
        color: Theme.bg
        border.width: Theme.line
        border.color: Theme.dim
        Behavior on y { NumberAnimation { duration: Theme.slideMs; easing.type: Easing.InOutCubic } }

        Brackets { tone: Theme.gold }

        Column {
            id: col
            x: 18; y: 16
            width: parent.width - 36
            spacing: 9

            // ── identity (click the emblem: launcher) ──
            Row {
                spacing: 14
                width: parent.width
                Item {
                    width: 66; height: 76
                    Image {
                        anchors.fill: parent
                        source: win.emblem
                        fillMode: Image.PreserveAspectFit
                        smooth: true; mipmap: true
                        opacity: elm.containsMouse ? 1.0 : 0.92
                    }
                    MouseArea { id: elm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: win.launcher() }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text { text: "1ST SPECIAL OPERATIONS WING"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 8; font.letterSpacing: 1 }
                    Text { text: "Lux Lunae"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 30 }
                    Text { text: "11TH TACTICAL SQUADRON"; color: Theme.gold; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 1 }
                    Text { text: "SHADOW 22  ·  FIAT LUX!"; color: Theme.red; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 1 }
                }
            }

            Rule { width: parent.width; tone: Theme.gold }

            // ── clock ──
            SectionHead { label: "CHRONO"; value: "LOCAL" }
            Text {
                text: Time.timeRich
                textFormat: Text.RichText
                color: Theme.moon
                font.family: Theme.mono; font.pixelSize: 32; font.bold: true
                topPadding: -4; bottomPadding: -4
            }
            Text {
                text: Time.dateRich
                textFormat: Text.RichText
                color: Theme.lgold
                font.family: Theme.mono; font.pixelSize: 14; font.letterSpacing: 1
            }

            // ── workspaces ──
            SectionHead { label: "SECTORS"; value: "WS " + Desktop.workspaceId }
            Grid {
                columns: 5
                rowSpacing: 0
                Repeater { model: 10; delegate: WsCell { n: index + 1; vertical: true; implicitHeight: 40; implicitWidth: 58 } }
            }

            // ── processor ──
            SectionHead { label: "PROCESSOR"; value: Stats.tempC >= 0 ? Stats.tempC + "°C" : "—" }
            Gauge { label: "LOAD"; pct: Stats.cpu; valueText: Stats.cpu + "%" }

            // ── memory / storage ──
            SectionHead { label: "MEMORY / STORAGE"; value: Stats.memUsed.toFixed(1) + " / " + Stats.memTotal.toFixed(1) + " GB" }
            Gauge { label: "RAM"; pct: Stats.memPct; valueText: Stats.memPct + "%" }
            Gauge { label: "DISK"; pct: Stats.diskPct; valueText: Stats.diskPct + "%" }

            // ── network | bluetooth (click either for its panel) ──
            Item {
                id: netRow
                width: parent.width; height: 60

                Item {
                    id: wifiHalf
                    width: parent.width / 2 - 8; height: parent.height
                    Rectangle { anchors.fill: parent; color: Theme.tonal; opacity: wma.containsMouse ? 1 : 0 }
                    Column {
                        x: 6; y: 3; width: parent.width - 12; spacing: 3
                        Text { text: "◢ WI-FI"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 1.5 }
                        Text {
                            width: parent.width
                            text: Stats.ssid !== "" ? Stats.ssid : (Stats.iface !== "none" && Stats.iface !== "—" ? Stats.iface : "OFFLINE")
                            elide: Text.ElideRight
                            color: Stats.ssid !== "" ? Theme.moon : Theme.dim
                            font.family: Theme.mono; font.pixelSize: 12; font.bold: true
                        }
                        Segments { visible: Stats.ssid !== ""; width: parent.width; pct: Stats.sigPct; count: 12; barHeight: 5 }
                        Text { text: "▼" + Stats.rxKB + "  ▲" + Stats.txKB + " KB/s"; color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 10 }
                    }
                    MouseArea {
                        id: wma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { Net.refresh(); var p = wifiHalf.mapToItem(null, 0, wifiHalf.height / 2); Ui.toggle("net", 0, p.y) }
                    }
                }
                Rule { vertical: true; x: parent.width / 2 - 0.5; height: parent.height; tone: Theme.dim }
                Item {
                    id: btHalf
                    x: parent.width / 2 + 8; width: parent.width / 2 - 8; height: parent.height
                    Rectangle { anchors.fill: parent; color: Theme.tonal; opacity: bma.containsMouse ? 1 : 0 }
                    Column {
                        x: 6; y: 3; width: parent.width - 12; spacing: 3
                        Text { text: "◢ BLUETOOTH"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 1.5 }
                        Text {
                            text: Stats.btOn ? "ON" : "OFF"
                            color: Stats.btOn ? Theme.moon : Theme.dim
                            font.family: Theme.mono; font.pixelSize: 12; font.bold: true
                        }
                        Text {
                            width: parent.width
                            property var names: Stats.btDev !== "" ? Stats.btDev.split("|") : []
                            text: names.length > 0 ? names[0] + (names.length > 1 ? "  +" + (names.length - 1) : "") : (Stats.btOn ? "NO DEVICE" : "")
                            elide: Text.ElideRight
                            color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 10
                        }
                    }
                    MouseArea {
                        id: bma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { Bt.refresh(); var p = btHalf.mapToItem(null, 0, btHalf.height / 2); Ui.toggle("bt", 0, p.y) }
                    }
                }
            }

            // ── power (BAT0 above BAT1, told apart by name and tone) ──
            SectionHead {
                label: "POWER"
                value: Stats.bat0 >= 0 ? win.stateText(Stats.bat0State) : "AC LINE"
            }
            Gauge {
                visible: Stats.bat0 >= 0
                label: "BAT0" + (Stats.bat0State === "Charging" ? "  ⚡" : "")
                pct: Stats.bat0; valueText: Stats.bat0 + "%"; tone: Theme.gold
            }
            Gauge {
                visible: Stats.bat1 >= 0
                label: "BAT1" + (Stats.bat1State === "Charging" ? "  ⚡" : "")
                pct: Stats.bat1; valueText: Stats.bat1 + "%"; tone: Theme.moon
            }

            // ── audio ──
            SectionHead { label: "AUDIO"; value: Audio.muted ? "MUTED" : "" }
            Item {
                width: parent.width; height: 12
                Text { text: "VOL"; color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 11; anchors.left: parent.left }
                Text { text: Audio.muted ? "MUTED" : Audio.vol + "%"; color: Audio.muted ? Theme.red : Theme.moon; font.family: Theme.mono; font.pixelSize: 11; anchors.right: parent.right }
            }
            SegSlider {
                width: parent.width
                value: Audio.vol
                dimmed: Audio.muted
                onMoved: pct => Audio.setVolume(pct)
            }
            Item {
                width: parent.width; height: 20
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Icon { name: Audio.micMuted ? "micoff" : "mic"; size: 16; color: Audio.micMuted ? Theme.red : Theme.gold; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "MIC"; color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                }
                Text {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    text: Audio.micMuted ? "MUTED" : "LIVE"
                    color: Audio.micMuted ? Theme.red : Theme.moon
                    font.family: Theme.mono; font.pixelSize: 11
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Audio.toggleMic() }
            }
            Text {
                width: parent.width
                text: Stats.media !== "" ? "♪ " + Stats.media : "NO SIGNAL"
                elide: Text.ElideRight
                color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10
            }
        }

        // ── four round buttons ──
        Row {
            id: btns
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: footRule.top
            anchors.bottomMargin: 10
            spacing: (slab.width - 36 - 4 * 56) / 3

            RoundButton {
                id: awakeBtn
                icon: "awake"
                active: Control.awake >= 1
                ring: Control.awake === 2
                wantDouble: true
                caption: Control.awake === 0 ? "AWAKE" : (Control.awake === 1 ? "AWAKE ON" : "AWAKE+LID")
                onClicked: Control.toggleAwake()
                onDoubleClicked: Control.setAwake(2)
            }
            RoundButton {
                icon: "gauge"
                active: Control.profile !== "balanced"
                caption: Control.profile === "power-saver" ? "SAVER" : (Control.profile === "performance" ? "PERFORM" : "BALANCED")
                onClicked: Control.cycleProfile()
            }
            RoundButton {
                icon: "phone"
                caption: "KDE CONNECT"
                onClicked: Quickshell.execDetached(["kdeconnect-app"])
            }
            RoundButton {
                id: quickBtn
                icon: "tune"
                active: Ui.open === "quick"
                caption: "QUICK"
                onClicked: {
                    Control.refreshBrightness()
                    var p = quickBtn.mapToItem(null, 0, 28)
                    Ui.toggle("quick", 0, p.y)
                }
            }
        }

        Rule { id: footRule; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: foot.top; anchors.margins: 18; anchors.bottomMargin: 6; tone: Theme.dim }
        Text {
            id: foot
            anchors.bottom: parent.bottom; anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: "LUX LUNAE  ·  FIAT LUX!"
            color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2
        }
    }
}
