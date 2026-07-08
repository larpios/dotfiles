import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

Rectangle {
    id: mediaDashboardContent
    property var colors: ({})
    property bool menuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: mediaDashboardContent.width / 2
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
    
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaAlbum: ""
    property string mediaArt: ""
    property string mediaStatus: "Stopped"
    property string formattedPosition: "0:00"
    property string formattedLength: "0:00"
    property real progress: 0
    
    signal next()
    signal previous()
    signal playPause()
    signal close()

    implicitWidth: 340
    implicitHeight: mainLayout.implicitHeight + 40
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: mediaDashboardContent.colors
        radius: 12
    }
    
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.leftMargin: 20 + 12
        anchors.rightMargin: 20 + 12
        anchors.topMargin: 20 + 12
        anchors.bottomMargin: 20
        spacing: 15
        
        Rectangle {
            id: artContainer
            Layout.alignment: Qt.AlignHCenter
            width: 240
            height: 240
            radius: 20
            color: colors.surface0
            
            // Proper way to round children: use layer and mask
            layer.enabled: mediaArt !== ""
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: artContainer.width
                    height: artContainer.height
                    radius: artContainer.radius
                    antialiasing: true
                }
            }
            
            Image {
                id: artImage
                anchors.fill: parent
                source: mediaArt
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                text: "󰎆"
                color: colors.surface1
                font.pixelSize: 64
                visible: mediaArt === ""
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            MarqueeText {
                Layout.fillWidth: true
                text: mediaTitle
                color: colors.text
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            MarqueeText {
                Layout.fillWidth: true
                text: mediaArtist
                color: colors.mauve
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
            MarqueeText {
                Layout.fillWidth: true
                text: mediaAlbum
                color: colors.subtext0
                font.pixelSize: 11
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                visible: mediaAlbum !== ""
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            spacing: 4
            visible: mediaStatus !== "Stopped"
            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: colors.surface0
                Rectangle {
                    width: progress * parent.width
                    height: parent.height
                    radius: 2
                    color: colors.mauve
                    Behavior on width { NumberAnimation { duration: 500 } }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text { text: formattedPosition; color: colors.subtext1; font.pixelSize: 10 }
                Item { Layout.fillWidth: true }
                Text { text: formattedLength; color: colors.subtext1; font.pixelSize: 10 }
            }
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30
            Text {
                text: "󰒮"
                color: colors.subtext1
                font.pixelSize: 24
                Layout.alignment: Qt.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: previous()
                }
            }
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: colors.mauve
                Layout.alignment: Qt.AlignVCenter
                Text {
                    anchors.centerIn: parent
                    text: mediaStatus === "Playing" ? "󰏤" : "󰐊"
                    color: colors.crust
                    font.pixelSize: 24
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: playPause()
                }
            }
            Text {
                text: "󰒭"
                color: colors.subtext1
                font.pixelSize: 24
                Layout.alignment: Qt.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: next()
                }
            }
        }
    }
}
