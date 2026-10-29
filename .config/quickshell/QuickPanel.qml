import QtQuick

// Quick settings: brightness, volume, toggles, power profile.
PopPanel {
    id: p
    name: "quick"
    dir: "right"
    panelW: 330
    panelH: 360
    onShownChanged: if (shown) { Control.refreshBrightness(); Control.refreshProfile(); Net.refresh(); Bt.refresh() }

    Column {
        anchors.fill: parent
        spacing: 12

        Item {
            width: parent.width; height: 30
            Icon { id: qi; anchors.verticalCenter: parent.verticalCenter; name: "tune"; size: 20; color: Theme.gold }
            Text { anchors.left: qi.right; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "QUICK SETTINGS"; color: Theme.moon; font.family: Theme.display; font.pixelSize: 20 }
        }
        Rule { width: parent.width; tone: Theme.gold }

        Column {
            width: parent.width; spacing: 6
            Item { width: parent.width; height: 14
                Text { text: "BRIGHTNESS"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
                Text { anchors.right: parent.right; text: Control.brightness + "%"; color: Theme.moon; font.family: Theme.mono; font.pixelSize: 10 }
            }
            Row { width: parent.width; spacing: 10
                Icon { name: "sun"; size: 18; color: Theme.gold; anchors.verticalCenter: parent.verticalCenter }
                SegSlider { width: parent.width - 28; value: Control.brightness; onMoved: pct => Control.setBrightness(pct); anchors.verticalCenter: parent.verticalCenter }
            }
        }
        Column {
            width: parent.width; spacing: 6
            Item { width: parent.width; height: 14
                Text { text: "VOLUME"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
                Text { anchors.right: parent.right; text: Audio.muted ? "MUTED" : Audio.vol + "%"; color: Audio.muted ? Theme.red : Theme.moon; font.family: Theme.mono; font.pixelSize: 10 }
            }
            Row { width: parent.width; spacing: 10
                Icon { name: "volume"; size: 18; color: Audio.muted ? Theme.dim : Theme.gold; anchors.verticalCenter: parent.verticalCenter }
                SegSlider { width: parent.width - 28; value: Audio.vol; dimmed: Audio.muted; onMoved: pct => Audio.setVolume(pct); anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flow {
            width: parent.width
            spacing: 8
            Chip { text: "MUTE";      icon: "volume";    active: Audio.muted;    onClicked: Audio.toggleMute() }
            Chip { text: "MIC OFF";   icon: "micoff";    active: Audio.micMuted; onClicked: Audio.toggleMic() }
            Chip { text: "WI-FI";     icon: "wifi";      active: Net.wifiOn;     onClicked: Net.setWifi(!Net.wifiOn) }
            Chip { text: "BLUETOOTH"; icon: "bluetooth"; active: Bt.powered;     onClicked: Bt.setPower(!Bt.powered) }
        }

        Column {
            width: parent.width; spacing: 6
            Text { text: "POWER PROFILE"; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 9; font.letterSpacing: 2 }
            Row {
                spacing: 8
                Chip { text: "SAVER";       active: Control.profile === "power-saver";  onClicked: Control.setProfile("power-saver") }
                Chip { text: "BALANCED";    active: Control.profile === "balanced";     onClicked: Control.setProfile("balanced") }
                Chip { text: "PERFORMANCE"; active: Control.profile === "performance";  onClicked: Control.setProfile("performance") }
            }
        }
    }
}
