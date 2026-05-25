import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: volMenuContent
    property var colors: ({})
    
    // Passed properties
    property int volume: 0
    property bool muted: false

    implicitWidth: 200
    implicitHeight: volMenuLayout.implicitHeight + 50
    color: colors.mantle
    radius: 12
    border.color: colors.surface1
    border.width: 1
    
    ColumnLayout {
        id: volMenuLayout
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: volMenuContent.muted ? "󰝟" : (volMenuContent.volume > 50 ? "󰕾" : "󰖀")
                color: colors.mauve
                font.pixelSize: 16
            }
            Text {
                text: "Volume"
                color: colors.text
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: volMenuContent.volume + "%"
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
                width: (volMenuContent.volume / 100) * parent.width
                height: parent.height
                radius: 3
                color: colors.mauve
            }
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: colors.text
                anchors.verticalCenter: parent.verticalCenter
                x: (volMenuContent.volume / 100) * (parent.width - width)
                border.color: colors.mauve
                border.width: 2
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                function updateVolume(mouse) {
                    let val = Math.max(0, Math.min(1, mouse.x / parent.width))
                    if (Pipewire.defaultAudioSink) {
                        Pipewire.defaultAudioSink.audio.volume = val
                    }
                }
                onPressed: updateVolume(mouse)
                onPositionChanged: updateVolume(mouse)
            }
        }
    }
}
