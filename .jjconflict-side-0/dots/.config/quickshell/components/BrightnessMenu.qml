import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: brightnessMenuContent
    property var colors: ({})
    
    // Passed properties
    property int brightness: 0
    signal moved(int value)

    implicitWidth: 200
    implicitHeight: brightnessMenuLayout.implicitHeight + 50
    color: colors.mantle
    radius: 12
    border.color: colors.surface1
    border.width: 1
    
    ColumnLayout {
        id: brightnessMenuLayout
        anchors.fill: parent
        anchors.margins: 15
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
