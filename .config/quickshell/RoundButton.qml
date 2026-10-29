import QtQuick

// Material 3 expressive circular button: tonal fill, state layer, shape morph while pressed.
Item {
    id: b
    property string icon: ""
    property string caption: ""
    property bool active: false          // filled / selected look
    property bool ring: false            // extra outline ring (second "level" of a toggle)
    signal clicked()
    signal doubleClicked()
    property bool wantDouble: false      // when true, a single click is delayed to tell it from a double click

    implicitWidth: 56
    implicitHeight: 56 + (caption !== "" ? 16 : 0)

    Item {
        id: btn
        width: 56; height: 56
        scale: ma.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: ma.pressed ? 16 : width / 2          // circle → squircle while pressed
            color: b.active ? Theme.gold : (ma.containsMouse ? Theme.tonalHi : Theme.tonal)
            border.width: b.ring ? 2 : 0
            border.color: Theme.red
            Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 140 } }
            Rectangle {                                    // state layer
                anchors.fill: parent
                radius: parent.radius
                color: b.active ? "#000000" : "#ffffff"
                opacity: ma.pressed ? 0.14 : (ma.containsMouse ? 0.07 : 0)
            }
        }
        Icon {
            anchors.centerIn: parent
            name: b.icon
            size: 26
            color: b.active ? Theme.black : Theme.moon
        }
        Rectangle {                                        // outer ring for the "+ lid" state
            visible: b.ring
            anchors.centerIn: parent
            width: parent.width + 8; height: parent.height + 8
            radius: width / 2
            color: "transparent"
            border.width: 1; border.color: Theme.red
        }
    }
    Text {
        visible: b.caption !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: btn.bottom; anchors.topMargin: 6
        text: b.caption
        color: b.active ? Theme.lgold : Theme.dim
        font.family: Theme.mono; font.pixelSize: 8; font.letterSpacing: 1
    }
    Timer { id: single; interval: 240; onTriggered: b.clicked() }
    MouseArea {
        id: ma
        width: 56; height: 56
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (b.wantDouble) single.restart(); else b.clicked() }
        onDoubleClicked: { if (b.wantDouble) { single.stop(); b.doubleClicked() } }
    }
}
