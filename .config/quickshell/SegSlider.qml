import QtQuick

// Segmented bar you can grab and drag. Emits moved(percent) while dragging (throttled).
Item {
    id: s
    property real value: 0
    property color tone: Theme.gold
    property bool dimmed: false
    signal moved(int pct)
    property bool dragging: false
    property real dragValue: 0
    readonly property real shown: dragging ? dragValue : value
    implicitHeight: 22

    Segments {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        barHeight: 10
        tone: s.dimmed ? Theme.dim : s.tone
        pct: Math.min(100, s.shown)
    }
    Rectangle {                         // grab handle
        width: 2; height: 20
        y: (s.height - height) / 2
        x: Math.max(0, Math.min(s.width - 2, Math.min(100, s.shown) / 100 * s.width - 1))
        color: Theme.moon
    }
    Timer { id: tick; interval: 60; onTriggered: if (s.dragging) s.moved(Math.round(s.dragValue)) }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.topMargin: -6; anchors.bottomMargin: -6
        preventStealing: true
        cursorShape: Qt.PointingHandCursor
        function pct(mx) { return Math.max(0, Math.min(100, Math.round(mx / s.width * 100))) }
        onPressed: mouse => { s.dragging = true; s.dragValue = pct(mouse.x); tick.restart() }
        onPositionChanged: mouse => { if (pressed) { s.dragValue = pct(mouse.x); if (!tick.running) tick.start() } }
        onReleased: { s.moved(Math.round(s.dragValue)); s.dragging = false }
    }
}
