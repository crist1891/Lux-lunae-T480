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
    property string ssid: ""
    property int sigPct: 0
    property bool btOn: false
    property string btDev: ""
    property int bat0: -1
    property string bat0State: ""
    property int bat1: -1
    property string bat1State: ""
    property int bat: -1
    property string batState: ""
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
                    root.ssid = d.ssid
                    root.sigPct = d.sigPct
                    root.btOn = d.btOn
                    root.btDev = d.btDev
                    root.bat0 = d.bat0
                    root.bat0State = d.bat0State
                    root.bat1 = d.bat1
                    root.bat1State = d.bat1State
                    root.media = d.media
                } catch (e) {}
            }
        }
    }
}
