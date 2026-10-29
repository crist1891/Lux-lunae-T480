pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Live audio state: scripts/audio.sh prints a JSON line on every PipeWire change,
// so the bars update immediately (no 2-second polling).
Singleton {
    id: root
    property int vol: 0
    property bool muted: false
    property int micVol: 0
    property bool micMuted: false

    function setVolume(p) {
        p = Math.max(0, Math.min(150, Math.round(p)))
        root.vol = p
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", p + "%"])
    }
    function toggleMute() {
        root.muted = !root.muted
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    }
    function toggleMic() {
        root.micMuted = !root.micMuted
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
    }

    Process {
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/audio.sh"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    var d = JSON.parse(line)
                    root.vol = d.vol
                    root.muted = d.muted
                    root.micVol = d.micVol
                    root.micMuted = d.micMuted
                } catch (e) {}
            }
        }
    }
}
