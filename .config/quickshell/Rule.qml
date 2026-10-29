import QtQuick
// 1px line, horizontal or vertical — same thickness everywhere
Rectangle {
    property bool vertical: false
    property color tone: Theme.dim
    color: tone
    implicitWidth:  vertical ? Theme.line : 10
    implicitHeight: vertical ? 10 : Theme.line
}
