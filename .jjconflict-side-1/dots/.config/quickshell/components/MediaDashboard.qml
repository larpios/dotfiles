import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

Rectangle {
    id: mediaDashboardContent
    property var colors: ({})
    
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
    implicitHeight: 520
    color: colors.crust
    radius: 20
    border.color: colors.surface0
    border.width: 1
    clip: true
    
    Rectangle { anchors.fill: parent; color: colors.base; opacity: 0.8 }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 240
            height: 240
            radius: 15
            color: colors.surface0
            clip: true

            Image {
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
            Text {
                Layout.fillWidth: true
                text: mediaTitle
                color: colors.text
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: mediaArtist
                color: colors.mauve
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: mediaAlbum
                color: colors.subtext0
                font.pixelSize: 11
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
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
            Layout.bottomMargin: 10
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
