import QtQuick

// Lux Lunae login screen — plain QtQuick only (no extra Qt modules needed).
// background.png and emblem.png are the unmodified originals, copied in by install.sh.
Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#050403"

    readonly property color gold:  "#988f46"
    readonly property color lgold: "#bfb771"
    readonly property color dim:   "#635d38"
    readonly property color ash:   "#29241e"
    readonly property color moon:  "#e9e6c8"
    readonly property color red:   "#b5313a"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string display: "Almendra"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool failed: false
    property var now: new Date()
    property var sessionNames: []

    function two(n) { return n < 10 ? "0" + n : "" + n }
    readonly property var months: ["JAN","FEB","MAR","APR","MAY","JUNE","JULY","AUG","SEPT","OCT","NOV","DEC"]
    readonly property var days: ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    readonly property string timeRich: {
        var h = now.getHours() % 12; if (h === 0) h = 12
        return two(h) + ":" + two(now.getMinutes()) + ":<font color='" + red + "'>" + two(now.getSeconds()) + "</font> " + (now.getHours() < 12 ? "AM" : "PM")
    }
    readonly property string dateRich: {
        var y = "" + now.getFullYear()
        return days[now.getDay()] + "  " + months[now.getMonth()] + " " + now.getDate() + "  " + y.slice(0, 2) + "<font color='" + red + "'>" + y.slice(2) + "</font>"
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    function sessionName() { return root.sessionNames[root.sessionIndex] || "" }
    function tryLogin() {
        root.failed = false
        sddm.login(userField.text, passField.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            passField.text = ""
            passField.forceActiveFocus()
        }
    }

    // original wallpaper, unmodified; a dark layer sits on top for legibility
    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle { anchors.fill: parent; color: "#050403"; opacity: 0.66 }

    // hidden helper that reads session names from the model
    Repeater {
        model: sessionModel
        delegate: Item { property string label: model.name }
        onItemAdded: (index, item) => {
            var a = root.sessionNames.slice()
            a[index] = item.label
            root.sessionNames = a
        }
    }

    // ── top-left: identity ──
    Row {
        x: 40; y: 36
        spacing: 16
        Image { source: "emblem.png"; width: 70; height: 80; fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text { text: "1ST SPECIAL OPERATIONS WING"; color: root.dim; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2 }
            Text { text: "Lux Lunae"; color: root.moon; font.family: root.display; font.pixelSize: 40 }
            Text { text: "11TH TACTICAL SQUADRON  ·  SHADOW 22"; color: root.gold; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2 }
        }
    }

    // ── top-right: clock ──
    Column {
        anchors.right: parent.right; anchors.rightMargin: 40
        y: 40
        spacing: 6
        Text { anchors.right: parent.right; text: root.timeRich; textFormat: Text.RichText; color: root.moon; font.family: root.mono; font.pixelSize: 34; font.bold: true }
        Text { anchors.right: parent.right; text: root.dateRich; textFormat: Text.RichText; color: root.lgold; font.family: root.mono; font.pixelSize: 15; font.letterSpacing: 1 }
    }

    // ── centre: login panel ──
    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 420; height: 268
        color: Qt.rgba(5/255, 4/255, 3/255, 0.82)
        border.width: 1; border.color: root.dim

        Repeater {
            model: 4
            delegate: Item {
                anchors.fill: parent
                property bool atRight: index % 2 === 1
                property bool atBottom: index >= 2
                Rectangle { width: 14; height: 1; color: root.gold; x: atRight ? parent.width - width : 0; y: atBottom ? parent.height - height : 0 }
                Rectangle { width: 1; height: 14; color: root.gold; x: atRight ? parent.width - width : 0; y: atBottom ? parent.height - height : 0 }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 16

            Item {
                width: parent.width; height: 14
                Text { id: hd; text: "◢ AUTHENTICATE"; color: root.dim; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { anchors.left: hd.right; anchors.leftMargin: 10; anchors.right: parent.right; height: 1; color: root.dim; anchors.verticalCenter: parent.verticalCenter }
            }

            Column {
                width: parent.width; spacing: 5
                Text { text: "CALLSIGN"; color: root.lgold; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2 }
                Rectangle {
                    width: parent.width; height: 38; color: "#0a0705"
                    border.width: 1; border.color: userField.activeFocus ? root.gold : root.ash
                    TextInput {
                        id: userField
                        anchors.fill: parent; anchors.margins: 10
                        verticalAlignment: TextInput.AlignVCenter
                        text: userModel.lastUser
                        color: root.moon
                        font.family: root.mono; font.pixelSize: 15
                        selectByMouse: true
                        KeyNavigation.tab: passField
                        Keys.onReturnPressed: passField.forceActiveFocus()
                    }
                }
            }

            Column {
                width: parent.width; spacing: 5
                Item {
                    width: parent.width; height: 12
                    Text { text: "PASSPHRASE"; color: root.lgold; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2 }
                    Text { anchors.right: parent.right; visible: root.failed; text: "Umbra."; color: root.red; font.family: root.display; font.pixelSize: 15 }
                    Text { anchors.right: parent.right; visible: !root.failed && keyboard.capsLock; text: "CAPS LOCK"; color: root.red; font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 2 }
                }
                Rectangle {
                    width: parent.width; height: 38; color: "#0a0705"
                    border.width: 1; border.color: root.failed ? root.red : (passField.activeFocus ? root.gold : root.ash)
                    TextInput {
                        id: passField
                        anchors.fill: parent; anchors.margins: 10
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: root.moon
                        font.family: root.mono; font.pixelSize: 15
                        focus: true
                        KeyNavigation.backtab: userField
                        Keys.onReturnPressed: root.tryLogin()
                        Keys.onEnterPressed: root.tryLogin()
                    }
                }
            }

            Item {
                width: parent.width; height: 36
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "SESSION  ◂ " + root.sessionName() + " ▸"
                    color: sessArea.containsMouse ? root.moon : root.gold
                    font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 1
                    MouseArea {
                        id: sessArea
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (sessionModel.count > 0) root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count
                    }
                }
                Rectangle {
                    anchors.right: parent.right
                    width: 120; height: 36
                    color: loginArea.containsMouse ? root.gold : "transparent"
                    border.width: 1; border.color: root.gold
                    Text { anchors.centerIn: parent; text: "FIAT LUX"; color: loginArea.containsMouse ? "#050403" : root.moon; font.family: root.mono; font.pixelSize: 12; font.letterSpacing: 2 }
                    MouseArea { id: loginArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.tryLogin() }
                }
            }
        }
    }

    // ── bottom: power ──
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: 36
        spacing: 34
        Repeater {
            model: [
                { label: "SUSPEND",   act: "suspend",  ok: sddm.canSuspend },
                { label: "RESTART",   act: "reboot",   ok: sddm.canReboot },
                { label: "SHUT DOWN", act: "powerOff", ok: sddm.canPowerOff }
            ]
            delegate: Text {
                visible: modelData.ok
                text: modelData.label
                color: pa.containsMouse ? (modelData.act === "powerOff" ? root.red : root.moon) : root.gold
                font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2
                MouseArea {
                    id: pa
                    anchors.fill: parent; anchors.margins: -8
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.act === "suspend") sddm.suspend()
                        else if (modelData.act === "reboot") sddm.reboot()
                        else sddm.powerOff()
                    }
                }
            }
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: 12
        text: "LUX LUNAE  ·  FIAT LUX!"
        color: root.ash; font.family: root.mono; font.pixelSize: 9; font.letterSpacing: 3
    }

    Component.onCompleted: passField.forceActiveFocus()
}
