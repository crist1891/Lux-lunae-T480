import Quickshell
import QtQuick

// Tall MFD-style panel on the left. Visible only when the workspace has no windows.
// Leaves by sliding UP off the screen; returns by sliding down from the top.
PanelWindow {
    id: win
    readonly property bool shown: Desktop.atDesktop
    readonly property int pad: 12
    readonly property string emblem: "file://" + Quickshell.env("HOME") + "/.config/lux/shadow22-emblem.png"

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
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ── identity ──
            Row {
                spacing: 14
                width: parent.width
                Image {
                    source: win.emblem
                    width: 78; height: 90
                    fillMode: Image.PreserveAspectFit
                    smooth: true; mipmap: true
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text { text: "1ST SPECIAL OPERATIONS WING"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 8; font.letterSpacing: 1 }
                    Text { text: "Lux Lunae"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 32 }
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
                font.family: Theme.mono; font.pixelSize: 34; font.bold: true
            }
            Text {
                text: Time.dateRich
                textFormat: Text.RichText
                color: Theme.lgold
                font.family: Theme.mono; font.pixelSize: 15; font.letterSpacing: 1
            }

            // ── workspaces ──
            SectionHead { label: "SECTORS"; value: "WS " + Desktop.workspaceId }
            Grid {
                columns: 5
                rowSpacing: 2
                Repeater { model: 10; delegate: WsCell { n: index + 1; vertical: true } }
            }

            // ── processor ──
            SectionHead { label: "PROCESSOR"; value: Stats.tempC >= 0 ? Stats.tempC + "°C" : "—" }
            Gauge { label: "LOAD"; pct: Stats.cpu; valueText: Stats.cpu + "%" }
            Text {
                visible: Stats.freqGHz > 0
                text: "FREQ " + Stats.freqGHz.toFixed(2) + " GHz"
                color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10
            }

            // ── memory / storage ──
            SectionHead { label: "MEMORY / STORAGE"; value: Stats.memUsed.toFixed(1) + " / " + Stats.memTotal.toFixed(1) + " GB" }
            Gauge { label: "RAM"; pct: Stats.memPct; valueText: Stats.memPct + "%" }
            Gauge { label: "DISK"; pct: Stats.diskPct; valueText: Stats.diskPct + "%" }

            // ── network ──
            SectionHead { label: "NETWORK"; value: Stats.iface }
            Text {
                text: "▼ " + Stats.rxKB + " KB/s      ▲ " + Stats.txKB + " KB/s"
                color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 11
            }

            // ── power ──
            SectionHead { label: "POWER"; value: Stats.bat >= 0 ? Stats.batState.toUpperCase() : "AC LINE" }
            Gauge { visible: Stats.bat >= 0; label: "BAT"; pct: Stats.bat; valueText: Stats.bat + "%" }

            // ── audio ──
            SectionHead { label: "AUDIO"; value: Stats.muted ? "MUTED" : "" }
            Gauge { label: "VOL"; pct: Stats.muted ? 0 : Stats.vol; valueText: Stats.vol + "%" }
            Text {
                width: parent.width
                text: Stats.media !== "" ? "♪ " + Stats.media : "NO SIGNAL"
                elide: Text.ElideRight
                color: Theme.dim; font.family: Theme.mono; font.pixelSize: 10
            }
        }

        Rule { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: foot.top; anchors.margins: 18; anchors.bottomMargin: 6; tone: Theme.dim }
        Text {
            id: foot
            anchors.bottom: parent.bottom; anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: "LUX LUNAE  ·  FIAT LUX!"
            color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2
        }
    }
}
