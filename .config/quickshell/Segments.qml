import QtQuick
// Segmented bar gauge, like a cockpit bar indicator
Item {
    id: seg
    property real pct: 0
    property int count: 22
    property int gap: 2
    property int barHeight: 8
    property bool warn: pct >= 85
    implicitHeight: barHeight
    Row {
        spacing: seg.gap
        Repeater {
            model: seg.count
            delegate: Rectangle {
                width: Math.max(1, (seg.width - seg.gap * (seg.count - 1)) / seg.count)
                height: seg.barHeight
                color: index < Math.round(Math.max(0, Math.min(100, seg.pct)) / 100 * seg.count)
                       ? (seg.warn ? Theme.red : Theme.gold) : Theme.ash
            }
        }
    }
}
