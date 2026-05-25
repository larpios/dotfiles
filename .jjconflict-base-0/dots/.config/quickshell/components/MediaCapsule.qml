import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

Rectangle {
    id: mediaContainer
    property var colors: ({})
    
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaArt: ""
    property string mediaStatus: "Stopped"
    property string formattedTime: "0:00"
    
    signal toggleDashboard()
    signal next()
    signal previous()
    signal playPause()

    Layout.alignment: Qt.AlignVCenter
    height: 25
    width: Math.max(100, mediaLayout.implicitWidth + 30)
    color: colors.mantle
    radius: 15
    border.color: colors.surface0
    border.width: 1
    visible: mediaStatus !== "Stopped" && mediaTitle !== ""
    clip: true

    // Background art/blur
    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: mediaContainer.width
                height: mediaContainer.height
                radius: 15
            }
        }

        Image {
            id: barBlurredArtSource
            anchors.fill: parent
            source: mediaArt
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        GaussianBlur {
            anchors.fill: parent
            source: barBlurredArtSource
            radius: 20
            samples: 16
            opacity: 0.2
            visible: mediaArt !== ""
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: mediaContainer.toggleDashboard()
    }

    RowLayout {
        id: mediaLayout
        anchors.centerIn: parent
        spacing: 10
        
        Item {
            width: 22
            height: 22
            Layout.alignment: Qt.AlignVCenter
            visible: mediaArt !== ""
            
            Rectangle { id: thumbMask; anchors.fill: parent; radius: 11; visible: false }

            Image {
                anchors.fill: parent
                source: mediaArt
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask { maskSource: thumbMask }
            }
        }
        
        Text {
            text: mediaContainer.formattedTime
            color: colors.mauve
            font.pixelSize: 9
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            visible: mediaStatus !== "Stopped"
        }

        ColumnLayout {
            spacing: -4
            Layout.alignment: Qt.AlignVCenter
            MarqueeText {
                text: mediaTitle
                color: colors.text
                font.pixelSize: 10
                font.bold: true
                width: 100
            }
            MarqueeText {
                text: mediaArtist
                color: colors.subtext0
                font.pixelSize: 8
                width: 100
            }
        }
        
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter
            Text {
                text: "󰒮"
                color: colors.subtext1
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mediaContainer.previous()
                }
            }
            Text {
                text: mediaStatus === "Playing" ? "󰏤" : "󰐊"
                color: colors.mauve
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mediaContainer.playPause()
                }
            }
            Text {
                text: "󰒭"
                color: colors.subtext1
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mediaContainer.next()
                }
            }
        }
    }
}
