import QtQuick
import QtQuick.Layouts

Canvas {
    id: root
    property var colors: ({})
    property int radius: 12
    property int borderWidth: 1
    property color borderColor: colors.surface1 || "transparent"
    property color backgroundColor: colors.base || "transparent"
    
    anchors.fill: parent
    
    onColorsChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    
    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        
        var w = width;
        var h = height;
        var r = radius;
        var b = borderWidth;
        var off = b / 2.0; // border stroke offset to align exactly with pixel grid
        
        ctx.lineWidth = b;
        ctx.strokeStyle = borderColor;
        ctx.fillStyle = backgroundColor;
        
        // --- 1. Fill Background (seamlessly merged top + body) ---
        ctx.beginPath();
        // Start top-left
        ctx.moveTo(0, 0);
        // Curve to body left
        ctx.quadraticCurveTo(r, 0, r, r);
        // Down to bottom-left
        ctx.lineTo(r, h - r);
        // Curve bottom-left
        ctx.quadraticCurveTo(r, h, r + r, h);
        // Right to bottom-right
        ctx.lineTo(w - 2*r, h);
        // Curve bottom-right
        ctx.quadraticCurveTo(w - r, h, w - r, h - r);
        // Up to top-right
        ctx.lineTo(w - r, r);
        // Curve to top-right connection
        ctx.quadraticCurveTo(w - r, 0, w, 0);
        // Close along top
        ctx.lineTo(0, 0);
        ctx.closePath();
        ctx.fill();
        
        // --- 2. Stroke Sharp Border (inward offset by 'off' for pixel-perfection) ---
        ctx.beginPath();
        // Start top-left connection point
        ctx.moveTo(off, off);
        // Curve down to left edge
        ctx.quadraticCurveTo(r + off, off, r + off, r + off);
        // Line to bottom-left
        ctx.lineTo(r + off, h - r - off);
        // Curve bottom-left
        ctx.quadraticCurveTo(r + off, h - off, r + r + off, h - off);
        // Line to bottom-right
        ctx.lineTo(w - 2*r - off, h - off);
        // Curve bottom-right
        ctx.quadraticCurveTo(w - r - off, h - off, w - r - off, h - r - off);
        // Line to top-right
        ctx.lineTo(w - r - off, r + off);
        // Curve to top-right connection point
        ctx.quadraticCurveTo(w - r - off, off, w - off, off);
        
        ctx.stroke();
    }
}
