import Quickshell
import Quickshell.Io
import QtQuick

// Super + /  →  full-screen overlay listing every keybind that has a description.
// Data comes live from `hyprctl binds -j`; cheatsheet.json is the fallback.
PanelWindow {
    id: win
    property bool shown: false
    property var columns: [[], [], []]
    property int total: 0
    readonly property string home: Quickshell.env("HOME")
    readonly property string emblem: "file://" + home + "/.config/lux/shadow22-emblem.png"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"
    visible: shown

    function toggle() {
        shown = !shown
        if (shown) bindsProc.running = true
    }

    IpcHandler {
        target: "cheatsheet"
        function toggle(): void { win.toggle() }
    }

    // ── data ──
    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector { onStreamFinished: win.fromHyprctl(this.text) }
    }
    Process {
        id: fallbackProc
        command: ["cat", win.home + "/.config/quickshell/cheatsheet.json"]
        stdout: StdioCollector { onStreamFinished: win.fromFallback(this.text) }
    }

    readonly property var keyNames: ({
        "Slash": "/", "Return": "Enter", "Period": ".", "Minus": "-", "Equal": "=",
        "Semicolon": ";", "Apostrophe": "'", "BracketLeft": "[", "BracketRight": "]",
        "Backslash": "\\", "Escape": "Esc", "Page_Up": "PgUp", "Page_Down": "PgDn",
        "mouse_up": "Scroll ↑", "mouse_down": "Scroll ↓",
        "mouse:272": "LMB", "mouse:273": "RMB", "mouse:274": "MMB",
        "mouse:275": "Mouse 4", "mouse:276": "Mouse 5",
        "Left": "←", "Right": "→", "Up": "↑", "Down": "↓", "space": "Space", "Space": "Space"
    })

    function modsOf(mask) {
        var p = []
        if (mask & 4)  p.push("CTRL")
        if (mask & 64) p.push("SUPER")
        if (mask & 8)  p.push("ALT")
        if (mask & 1)  p.push("SHIFT")
        return p
    }

    function fromHyprctl(text) {
        var arr = []
        try { arr = JSON.parse(text) } catch (e) { arr = [] }
        var items = [], seen = {}, groups = {}
        for (var i = 0; i < arr.length; i++) {
            var b = arr[i]
            if (!b.description) continue
            if (b.submap && b.submap !== "") continue
            var d = b.description, p = d.indexOf(":")
            var cat = p > 0 ? d.slice(0, p).trim().toUpperCase() : "OTHER"
            var label = p > 0 ? d.slice(p + 1).trim() : d
            var mods = modsOf(b.modmask)
            var m = label.match(/^(.*\S)\s+(\d+)$/)
            if (m && /^[0-9]$/.test(String(b.key))) {
                // collapse "Focus 1 … Focus 10" into one row
                var gk = cat + "|" + m[1] + "|" + b.modmask
                if (!groups[gk]) {
                    groups[gk] = true
                    items.push({ cat: cat, label: m[1] + " 1–10", keys: mods.concat(["1…0"]).join(" + ") })
                }
                continue
            }
            var k = win.keyNames[b.key] !== undefined ? win.keyNames[b.key] : String(b.key)
            var keys = mods.concat([k]).join(" + ")
            var id = cat + "|" + label + "|" + keys
            if (seen[id]) continue
            seen[id] = true
            items.push({ cat: cat, label: label, keys: keys })
        }
        if (items.length === 0) { fallbackProc.running = true; return }
        win.build(items)
    }

    function fromFallback(text) {
        var items = []
        try { items = JSON.parse(text) } catch (e) { items = [] }
        win.build(items)
    }

    function build(items) {
        var order = ["APP", "WINDOW", "WORKSPACE", "SHELL", "UTILITIES", "MEDIA", "SCREEN", "SESSION"]
        var by = {}
        for (var i = 0; i < items.length; i++) {
            var it = items[i]
            if (!by[it.cat]) by[it.cat] = []
            by[it.cat].push(it)
        }
        var names = Object.keys(by).sort(function (a, b) {
            var ia = order.indexOf(a), ib = order.indexOf(b)
            return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib)
        })
        var cols = [[], [], []], h = [0, 0, 0]
        for (var n = 0; n < names.length; n++) {
            var k = h.indexOf(Math.min(h[0], h[1], h[2]))
            cols[k].push({ name: names[n], items: by[names[n]] })
            h[k] += by[names[n]].length + 2
        }
        win.total = items.length
        win.columns = cols
    }

    // ── look ──
    Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.55 }
    MouseArea { anchors.fill: parent; onClicked: win.shown = false }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 1180)
        height: Math.min(parent.height - 40, 820)
        color: Theme.bg
        border.width: Theme.line
        border.color: Theme.dim
        focus: true
        Keys.onEscapePressed: win.shown = false
        MouseArea { anchors.fill: parent }   // clicks inside don't close it

        Brackets { tone: Theme.gold }

        Row {
            id: head
            x: 22; y: 18
            spacing: 14
            Image {
                source: win.emblem
                width: 44; height: 50
                fillMode: Image.PreserveAspectFit
                smooth: true; mipmap: true
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text { text: "KEYBIND REFERENCE"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 24 }
                Text { text: "LUX LUNAE  ·  " + win.total + " BINDINGS"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
            }
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 22
            y: 28
            text: "SUPER + /  OR CLICK OUTSIDE TO CLOSE"
            color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2
        }
        Rule { id: headRule; x: 22; y: 78; width: parent.width - 44; tone: Theme.gold }

        Flickable {
            id: fl
            anchors { left: parent.left; right: parent.right; top: headRule.bottom; bottom: parent.bottom; margins: 22 }
            anchors.topMargin: 16
            clip: true
            contentHeight: cols.height
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: cols
                spacing: 30
                Repeater {
                    model: win.columns
                    delegate: Column {
                        required property var modelData
                        width: (fl.width - 60) / 3
                        spacing: 18
                        Repeater {
                            model: parent.modelData
                            delegate: Column {
                                required property var modelData
                                width: parent.width
                                spacing: 5
                                SectionHead { label: modelData.name; value: "" + modelData.items.length }
                                Repeater {
                                    model: modelData.items
                                    delegate: Item {
                                        required property var modelData
                                        width: parent.width
                                        height: Math.max(lbl.implicitHeight, kys.implicitHeight) + 3
                                        Text {
                                            id: lbl
                                            width: 138
                                            text: modelData.label
                                            wrapMode: Text.Wrap
                                            color: Theme.moon
                                            font.family: Theme.mono; font.pixelSize: 11
                                        }
                                        Text {
                                            id: kys
                                            anchors.left: lbl.right; anchors.leftMargin: 8
                                            anchors.right: parent.right
                                            text: modelData.keys
                                            horizontalAlignment: Text.AlignRight
                                            wrapMode: Text.Wrap
                                            color: Theme.gold
                                            font.family: Theme.mono; font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
