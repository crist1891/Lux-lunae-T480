import QtQuick

// Pill-shaped tonal chip (Material 3 style) for use inside panels.
Rectangle {
    id: chip
    property string text: ""
    property string icon: ""
    property bool active: false
    signal clicked()
    implicitHeight: 30
    implicitWidth: row.implicitWidth + 24
    radius: height / 2
    color: active ? Theme.gold : (ma.containsMouse ? Theme.tonalHi : Theme.tonal)
    Behavior on color { ColorAnimation { duration: 120 } }
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
        Icon { visible: chip.icon !== ""; name: chip.icon; size: 14; color: chip.active ? Theme.black : Theme.moon; anchors.verticalCenter: parent.verticalCenter }
        Text {
            text: chip.text
            color: chip.active ? Theme.black : Theme.moon
            font.family: Theme.mono; font.pixelSize: 10; font.letterSpacing: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: chip.clicked() }
}
