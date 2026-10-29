pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    SystemClock { id: clk; precision: SystemClock.Seconds }

    function two(n) { return n < 10 ? "0" + n : "" + n }

    readonly property var months: ["JAN","FEB","MAR","APR","MAY","JUNE","JULY","AUG","SEPT","OCT","NOV","DEC"]
    readonly property var days:   ["SUN","MON","TUE","WED","THU","FRI","SAT"]

    readonly property string hh: { var h = clk.date.getHours() % 12; return two(h === 0 ? 12 : h) }
    readonly property string mm: two(clk.date.getMinutes())
    readonly property string ss: two(clk.date.getSeconds())
    readonly property string ap: clk.date.getHours() < 12 ? "AM" : "PM"

    readonly property string dow: days[clk.date.getDay()]
    readonly property string mon: months[clk.date.getMonth()]
    readonly property string day: "" + clk.date.getDate()
    readonly property string yearHi: ("" + clk.date.getFullYear()).slice(0, 2)
    readonly property string yearLo: ("" + clk.date.getFullYear()).slice(2)

    // rich text: seconds red, AM/PM after
    readonly property string timeRich:
        hh + ":" + mm + ":<font color='" + Theme.red + "'>" + ss + "</font> " + ap
    // rich text: last two digits of the year red
    readonly property string dateRich:
        dow + "  " + mon + " " + day + "  " + yearHi + "<font color='" + Theme.red + "'>" + yearLo + "</font>"
}
