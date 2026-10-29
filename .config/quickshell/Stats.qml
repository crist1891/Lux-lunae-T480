pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpu: 0
    property int memPct: 0
    property real memUsed: 0
    property real memTotal: 0
    property int diskPct: 0
    property real tempC: -1
    property real freqGHz: 0
    property real rxKB: 0
    property real txKB: 0
    property string iface: "—"
    property int bat: -1
    property string batState: ""
    property int vol: 0
    property bool muted: false
    property string media: ""

    Process {
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/stats.sh"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    var d = JSON.parse(line)
                    root.cpu = d.cpu
                    root.memPct = d.memPct
                    root.memUsed = d.memUsed
                    root.memTotal = d.memTotal
                    root.diskPct = d.diskPct
                    root.tempC = d.tempC
                    root.freqGHz = d.freqGHz
                    root.rxKB = d.rxKB
                    root.txKB = d.txKB
                    root.iface = d.iface
                    root.bat = d.bat
                    root.batState = d.batState
                    root.vol = d.vol
                    root.muted = d.muted
                    root.media = d.media
                } catch (e) {}
            }
        }
    }
}
