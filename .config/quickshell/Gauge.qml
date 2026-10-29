import QtQuick
// label + value text over a segmented bar
Column {
    id: g
    property string label: ""
    property string valueText: ""
    property real pct: 0
    property color tone: Theme.gold
    width: parent ? parent.width : 200
    spacing: 4
    Item {
        width: parent.width; height: 12
        Text { text: g.label; color: Theme.lgold; font.family: Theme.mono; font.pixelSize: 11; anchors.left: parent.left }
        Text { text: g.valueText; color: Theme.moon; font.family: Theme.mono; font.pixelSize: 11; anchors.right: parent.right }
    }
    Segments { width: parent.width; pct: g.pct; tone: g.tone }
}
