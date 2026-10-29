pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth devices through bluetoothctl.
Singleton {
    id: root
    property bool powered: false
    property var devices: []         // [{mac, name, connected}]
    property var connectedSet: ({})

    function refresh() { showP.running = true; connP.running = true }
    function setPower(on) { root.powered = on; Quickshell.execDetached(["bluetoothctl", "power", on ? "on" : "off"]); after.restart() }
    function connectDev(mac) { Quickshell.execDetached(["bluetoothctl", "connect", mac]); after.restart() }
    function disconnectDev(mac) { Quickshell.execDetached(["bluetoothctl", "disconnect", mac]); after.restart() }
    function scan() { Quickshell.execDetached(["bluetoothctl", "--timeout", "8", "scan", "on"]); scanT.restart() }
    function openManager() { Quickshell.execDetached(["blueman-manager"]) }

    function parseDevices(t) {
        var out = [], lines = t.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^Device\s+([0-9A-Fa-f:]{17})\s+(.*)$/)
            if (m) out.push({ mac: m[1], name: m[2], connected: root.connectedSet[m[1]] === true })
        }
        out.sort(function (a, b) { return (b.connected ? 1 : 0) - (a.connected ? 1 : 0) })
        root.devices = out
    }

    Process {
        id: showP
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector { onStreamFinished: root.powered = /Powered:\s+yes/.test(this.text) }
    }
    Process {
        id: connP
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector {
            onStreamFinished: {
                var s = {}, lines = this.text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var m = lines[i].match(/^Device\s+([0-9A-Fa-f:]{17})/)
                    if (m) s[m[1]] = true
                }
                root.connectedSet = s
                allP.running = true
            }
        }
    }
    Process {
        id: allP
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector { onStreamFinished: root.parseDevices(this.text) }
    }
    Timer { id: after; interval: 2500; onTriggered: root.refresh() }
    Timer { id: scanT; interval: 5000; onTriggered: root.refresh() }
}
