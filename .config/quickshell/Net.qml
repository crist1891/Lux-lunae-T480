pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi list / actions through NetworkManager (nmcli). The side panel's SSID comes from stats.sh and works without it.
Singleton {
    id: root
    property var networks: []        // [{ssid, signal, secured, active}]
    property bool wifiOn: true

    function refresh() { stateP.running = true; listP.running = true }
    function rescan() { Quickshell.execDetached(["nmcli", "dev", "wifi", "rescan"]); rescanTimer.restart() }
    function connectTo(ssid) { Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid]); after.restart() }
    function setWifi(on) { root.wifiOn = on; Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]); after.restart() }
    function openEditor() { Quickshell.execDetached(["kitty", "-e", "nmtui"]) }

    function parseList(t) {
        var out = [], seen = {}
        var lines = t.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i]
            if (l === "") continue
            l = l.replace(/\\:/g, "\u0001")
            var f = l.split(":")
            var ssid = (f[1] || "").replace(/\u0001/g, ":")
            if (ssid === "" || seen[ssid]) continue
            seen[ssid] = true
            out.push({ ssid: ssid, signal: parseInt(f[2]) || 0, secured: (f[3] || "") !== "" && f[3] !== "--", active: f[0] === "*" })
        }
        out.sort(function (a, b) { return (b.active ? 1000 : 0) + b.signal - ((a.active ? 1000 : 0) + a.signal) })
        root.networks = out
    }

    Process {
        id: listP
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        stdout: StdioCollector { onStreamFinished: root.parseList(this.text) }
    }
    Process {
        id: stateP
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: root.wifiOn = this.text.trim() === "enabled" }
    }
    Timer { id: after; interval: 2500; onTriggered: root.refresh() }
    Timer { id: rescanTimer; interval: 3000; onTriggered: listP.running = true }
}
