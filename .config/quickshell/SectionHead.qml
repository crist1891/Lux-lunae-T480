import QtQuick
// "◢ LABEL ────────── value"
Item {
    id: head
    property string label: ""
    property string value: ""
    implicitHeight: 14
    width: parent ? parent.width : 200
    Text {
        id: lab
        text: "◢ " + head.label
        color: Theme.dim
        font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 1.5
        anchors.verticalCenter: parent.verticalCenter
    }
    Rule {
        anchors.left: lab.right; anchors.leftMargin: 8
        anchors.right: val.left; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        id: val
        text: head.value
        color: Theme.lgold
        font.family: Theme.mono; font.pixelSize: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
