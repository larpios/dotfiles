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

    implicitWidth: 160
    implicitHeight: kbMenuLayout.implicitHeight + 20
    color: colors.mantle
    radius: 12
    border.color: colors.surface1
    border.width: 1

    ColumnLayout {
        id: kbMenuLayout
        anchors.fill: parent
        anchors.margins: 10
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
