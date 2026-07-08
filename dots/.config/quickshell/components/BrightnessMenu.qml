import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: brightnessMenuContent
    property var colors: ({})
    property bool menuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: brightnessMenuContent.width / 2
        origin.y: 0
        yScale: 0.0
    }
    
    NumberAnimation {
        id: scaleInAnim
        target: menuScale
        property: "yScale"
        from: 0.0
        to: 1.0
        duration: 320
        easing.type: Easing.OutBack
    }
    
    onMenuVisibleChanged: {
        if (menuVisible) {
            scaleInAnim.start();
        } else {
            scaleInAnim.stop();
            menuScale.yScale = 0.0;
        }
    }
    
    Component.onCompleted: {
        if (menuVisible) {
            scaleInAnim.start();
        }
    }
    
    // Passed properties
    property int brightness: 0
    signal moved(int value)

    implicitWidth: 200
    implicitHeight: brightnessMenuLayout.implicitHeight + 50
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: brightnessMenuContent.colors
    }
    
    ColumnLayout {
        id: brightnessMenuLayout
        anchors.fill: parent
        anchors.leftMargin: 15 + 12
        anchors.rightMargin: 15 + 12
        anchors.topMargin: 15 + 12
        anchors.bottomMargin: 15
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "󰃠"
                color: colors.yellow
                font.pixelSize: 16
            }
            Text {
                text: "Brightness"
                color: colors.text
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: brightnessMenuContent.brightness + "%"
                color: colors.subtext1
                font.pixelSize: 11
            }
        }
        
        // Custom Slider
        Rectangle {
            id: sliderTrack
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: colors.surface0
            Rectangle {
                width: (brightnessMenuContent.brightness / 100) * parent.width
                height: parent.height
                radius: 3
                color: colors.yellow
            }
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: colors.text
                anchors.verticalCenter: parent.verticalCenter
                x: (brightnessMenuContent.brightness / 100) * (parent.width - width)
                border.color: colors.yellow
                border.width: 2
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                function updateBrightness(mouse) {
                    let val = Math.max(0, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                    brightnessMenuContent.moved(val)
                }
                onPressed: updateBrightness(mouse)
                onPositionChanged: updateBrightness(mouse)
            }
        }
    }
}
