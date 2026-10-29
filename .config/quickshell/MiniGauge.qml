import QtQuick

Row {
    id: m
    property string label: ""
    property real pct: 0
    property string valueText: ""
    property bool dimmed: false
    spacing: 6
    height: 16
    Text {
        text: m.label
        color: Theme.dim
        font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 1
        anchors.verticalCenter: parent.verticalCenter
    }
    Segments {
        width: 44; count: 8; barHeight: 8; pct: m.pct
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: m.valueText
        color: m.dimmed ? Theme.dim : Theme.moon
        font.family: Theme.mono; font.pixelSize: 11
        width: 34
        anchors.verticalCenter: parent.verticalCenter
    }
}
