import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: kbMenuContent
    property var colors: ({})

    // Properties passed from indicator
    property var kbLayoutsList: []
    property bool kbMenuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: kbMenuContent.width / 2
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
    
    onKbMenuVisibleChanged: {
        if (kbMenuVisible) {
            scaleInAnim.start();
        } else {
            scaleInAnim.stop();
            menuScale.yScale = 0.0;
        }
    }
    
    Component.onCompleted: {
        if (kbMenuVisible) {
            scaleInAnim.start();
        }
    }

    implicitWidth: 160
    implicitHeight: kbMenuLayout.implicitHeight + 20
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: kbMenuContent.colors
    }

    ColumnLayout {
        id: kbMenuLayout
        anchors.fill: parent
        anchors.leftMargin: 10 + 12
        anchors.rightMargin: 10 + 12
        anchors.topMargin: 10 + 12
        anchors.bottomMargin: 10
        spacing: 4
        Repeater {
            model: kbMenuContent.kbLayoutsList
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 32
                radius: 6
                color: "transparent"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 10
                    Text {
                        text: modelData.display
                        color: colors.mauve
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: modelData.id
                        color: colors.text
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = colors.surface0
                    onExited: parent.color = "transparent"
                    onClicked: {
                        // We need a way to run fcitx5-remote -s
                        // Since each module manages its own logic, we can add a Process here or pass a signal
                        kbActionProcess.command = ["fcitx5-remote", "-s", modelData.id]
                        kbActionProcess.running = true
                        kbMenuContent.kbMenuVisible = false
                    }
                }
            }
        }
    }

    Process {
        id: kbActionProcess
        running: false
    }
}
