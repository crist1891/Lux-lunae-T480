pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Keep-awake modes, power profile and screen brightness.
Singleton {
    id: root

    // 0 = off · 1 = stay awake (no idle lock/sleep) · 2 = also stay awake with the lid closed
    property int awake: 0
    property string profile: "balanced"
    property int brightness: 50

    function setAwake(m) { root.awake = m }
    function toggleAwake() { root.awake = root.awake === 0 ? 1 : 0 }

    function cycleProfile() {
        var next = { "power-saver": "balanced", "balanced": "performance", "performance": "power-saver" }
        var n = next[root.profile] || "balanced"
        root.profile = n
        Quickshell.execDetached(["powerprofilesctl", "set", n])
    }
    function setProfile(p) {
        root.profile = p
        Quickshell.execDetached(["powerprofilesctl", "set", p])
    }
    function refreshProfile() { profGet.running = true }

    function setBrightness(p) {
        p = Math.max(1, Math.min(100, Math.round(p)))
        root.brightness = p
        Quickshell.execDetached(["brightnessctl", "set", p + "%"])
    }
    function refreshBrightness() { briGet.running = true }

    Process {
        id: idleInhibit
        running: root.awake >= 1
        command: ["systemd-inhibit", "--what=idle", "--who=Lux Lunae", "--why=Keep awake", "--mode=block", "sleep", "infinity"]
    }
    Process {
        id: lidInhibit
        running: root.awake >= 2
        command: ["systemd-inhibit", "--what=handle-lid-switch", "--who=Lux Lunae", "--why=Keep awake with the lid closed", "--mode=block", "sleep", "infinity"]
    }
    Process {
        id: profGet
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector { onStreamFinished: { var t = this.text.trim(); if (t !== "") root.profile = t } }
    }
    Process {
        id: briGet
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var f = this.text.trim().split(",")
                if (f.length >= 4) { var v = parseInt(f[3]); if (!isNaN(v)) root.brightness = v }
            }
        }
    }
    Timer { interval: 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refreshProfile() }
}
