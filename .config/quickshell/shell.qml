//  LUX LUNAE — MFD shell
//  Desktop (no windows on the workspace): tall panel on the left.
//  Window open: panel slides up off screen, top bar slides down.
//  Super + /  : keybind cheat sheet   (qs ipc call cheatsheet toggle)
import Quickshell
import QtQuick

ShellRoot {
    SideBar {}
    TopBar {}
    CheatSheet {}
}
