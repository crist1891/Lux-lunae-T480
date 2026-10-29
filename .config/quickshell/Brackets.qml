import QtQuick
// Square corner brackets, like the corners of an MFD bezel
Item {
    property color tone: Theme.gold
    property int arm: 14
    anchors.fill: parent
    Repeater {
        model: 4
        delegate: Item {
            anchors.fill: parent
            property bool atRight: index % 2 === 1
            property bool atBottom: index >= 2
            Rectangle {   // horizontal arm
                width: arm; height: Theme.line; color: tone
                x: atRight ? parent.width - width : 0
                y: atBottom ? parent.height - height : 0
            }
            Rectangle {   // vertical arm
                width: Theme.line; height: arm; color: tone
                x: atRight ? parent.width - width : 0
                y: atBottom ? parent.height - height : 0
            }
        }
    }
}
