pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color bg:      Qt.rgba(5/255, 4/255, 3/255, 0.82)   // dark translucent
    readonly property color black:   "#050403"
    readonly property color ash:     "#29241e"
    readonly property color dim:     "#635d38"
    readonly property color gold:    "#988f46"
    readonly property color lgold:   "#bfb771"
    readonly property color moon:    "#e9e6c8"
    readonly property color red:     "#b5313a"

    readonly property string display: "Almendra"
    readonly property string mono:    "JetBrainsMono Nerd Font"

    readonly property int line: 1          // every rule, frame and tick is this thick
    readonly property int slideMs: 210
}
