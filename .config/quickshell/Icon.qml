import QtQuick

// Small stroke icons drawn on a canvas (no icon font needed). 24-unit grid, round caps.
Canvas {
    id: c
    property string name: ""
    property color color: Theme.moon
    property real size: 22
    width: size
    height: size
    renderTarget: Canvas.Image
    renderStrategy: Canvas.Immediate
    onColorChanged: requestPaint()
    onNameChanged: requestPaint()
    onSizeChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.scale(size / 24, size / 24)
        ctx.strokeStyle = color
        ctx.fillStyle = color
        ctx.lineWidth = 2
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        function rr(x, y, w, h, r) {
            ctx.beginPath()
            ctx.moveTo(x + r, y)
            ctx.lineTo(x + w - r, y); ctx.arcTo(x + w, y, x + w, y + r, r)
            ctx.lineTo(x + w, y + h - r); ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
            ctx.lineTo(x + r, y + h); ctx.arcTo(x, y + h, x, y + h - r, r)
            ctx.lineTo(x, y + r); ctx.arcTo(x, y, x + r, y, r)
            ctx.closePath()
        }
        function line(x1, y1, x2, y2) { ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke() }
        var n = name
        if (n === "crosshair") {
            ctx.beginPath(); ctx.arc(12, 12, 7, 0, Math.PI * 2); ctx.stroke()
            line(12, 2, 12, 7); line(12, 17, 12, 22); line(2, 12, 7, 12); line(17, 12, 22, 12)
            ctx.beginPath(); ctx.arc(12, 12, 1.3, 0, Math.PI * 2); ctx.fill()
        } else if (n === "awake") {            // coffee cup
            ctx.beginPath()
            ctx.moveTo(4, 10); ctx.lineTo(4, 15); ctx.quadraticCurveTo(4, 20, 9, 20)
            ctx.lineTo(11, 20); ctx.quadraticCurveTo(16, 20, 16, 15); ctx.lineTo(16, 10); ctx.closePath(); ctx.stroke()
            ctx.beginPath(); ctx.arc(17, 13, 3, -Math.PI / 2, Math.PI / 2, false); ctx.stroke()
            line(7, 3, 7, 6.5); line(10, 2, 10, 6.5); line(13, 3, 13, 6.5)
        } else if (n === "gauge") {            // power profile
            ctx.beginPath(); ctx.arc(12, 14, 9, Math.PI * 0.88, Math.PI * 2.12); ctx.stroke()
            line(12, 14, 17, 8.5)
            ctx.beginPath(); ctx.arc(12, 14, 1.6, 0, Math.PI * 2); ctx.fill()
            line(6, 19.5, 18, 19.5)
        } else if (n === "phone") {            // KDE Connect
            rr(7, 2.5, 10, 19, 2.5); ctx.stroke()
            line(10.5, 5.5, 13.5, 5.5)
            ctx.beginPath(); ctx.arc(12, 18.2, 0.9, 0, Math.PI * 2); ctx.fill()
        } else if (n === "tune") {             // quick settings
            line(3, 6, 8, 6); line(14, 6, 21, 6); ctx.beginPath(); ctx.arc(11, 6, 3, 0, Math.PI * 2); ctx.stroke()
            line(3, 12, 14, 12); line(20, 12, 21, 12); ctx.beginPath(); ctx.arc(17, 12, 3, 0, Math.PI * 2); ctx.stroke()
            line(3, 18, 5, 18); line(11, 18, 21, 18); ctx.beginPath(); ctx.arc(8, 18, 3, 0, Math.PI * 2); ctx.stroke()
        } else if (n === "mic" || n === "micoff") {
            rr(9, 2, 6, 12, 3); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 11, 7, 0, Math.PI, false); ctx.stroke()
            line(12, 18, 12, 22); line(8, 22, 16, 22)
            if (n === "micoff") { ctx.lineWidth = 2.4; line(3.5, 3.5, 20.5, 20.5) }
        } else if (n === "wifi") {
            ctx.beginPath(); ctx.arc(12, 19, 5, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 19, 10, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 19, 15, -Math.PI * 0.75, -Math.PI * 0.25); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 19.5, 1.5, 0, Math.PI * 2); ctx.fill()
        } else if (n === "bluetooth") {
            ctx.beginPath()
            ctx.moveTo(6.5, 7.5); ctx.lineTo(17, 17); ctx.lineTo(12, 22); ctx.lineTo(12, 2); ctx.lineTo(17, 7); ctx.lineTo(6.5, 16.5)
            ctx.stroke()
        } else if (n === "bolt") {
            ctx.beginPath(); ctx.moveTo(13, 2); ctx.lineTo(5, 13.5); ctx.lineTo(12, 13.5); ctx.lineTo(11, 22); ctx.lineTo(19, 10.5); ctx.lineTo(12, 10.5); ctx.closePath(); ctx.fill()
        } else if (n === "close") {
            line(5, 5, 19, 19); line(19, 5, 5, 19)
        } else if (n === "sun") {
            ctx.beginPath(); ctx.arc(12, 12, 4.2, 0, Math.PI * 2); ctx.stroke()
            for (var k = 0; k < 8; k++) {
                var a = k * Math.PI / 4
                line(12 + Math.cos(a) * 7.5, 12 + Math.sin(a) * 7.5, 12 + Math.cos(a) * 10, 12 + Math.sin(a) * 10)
            }
        } else if (n === "volume") {
            ctx.beginPath(); ctx.moveTo(3, 9); ctx.lineTo(7, 9); ctx.lineTo(12, 4.5); ctx.lineTo(12, 19.5); ctx.lineTo(7, 15); ctx.lineTo(3, 15); ctx.closePath(); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 12, 5, -0.9, 0.9); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 12, 9, -0.8, 0.8); ctx.stroke()
        } else if (n === "lock") {
            rr(5, 11, 14, 10, 2); ctx.stroke()
            ctx.beginPath(); ctx.arc(12, 11, 4.5, Math.PI, 0); ctx.stroke()
        }
    }
}
