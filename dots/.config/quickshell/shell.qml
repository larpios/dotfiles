pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "./components"
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ShellRoot {
    id: root
    Colors { id: colors }

    Component.onCompleted: console.log("Quickshell: Shell loaded successfully")

    property date currentTime: new Date()
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.currentTime = new Date()
    }

    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 40
        color: "transparent"

        Rectangle {
            id: barContent
            anchors.fill: parent
            anchors.margins: 6
            color: colors.base
            radius: 12
            border.color: colors.surface1
            border.width: 1

            // --- Absolute Center Window Title ---
            Text {
                id: windowTitleLabel
                anchors.centerIn: parent
                text: (Hyprland.activeToplevel && Hyprland.activeToplevel.title) ? Hyprland.activeToplevel.title : "Hyprland"
                color: colors.subtext1
                font.pixelSize: 11
                font.bold: true
                elide: Text.ElideRight
                width: parent.width * 0.4
                horizontalAlignment: Text.AlignHCenter
                z: 10
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 0

                // --- Left Section ---
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16

                    Text {
                        text: "󰣇"
                        color: colors.blue
                        font.pixelSize: 18
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("Launcher clicked")
                        }
                    }

                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                required property var modelData
                                property bool isActive: modelData.active
                                property bool hovered: false
                                width: isActive ? 32 : 20
                                height: 20
                                radius: 10
                                color: isActive ? colors.mauve : (hovered ? colors.surface2 : colors.surface1)
                                border.color: isActive ? colors.mauve : (hovered ? colors.surface2 : colors.surface1)
                                border.width: 1
                                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                
                                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: parent.isActive ? colors.crust : colors.text
                                    font.pixelSize: 10
                                    font.bold: parent.isActive
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    MediaController {
                        colors: colors
                        bar: bar
                    }
                }

                Item { Layout.fillWidth: true }

                // --- Right Section ---
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16

                    KeyboardIndicator {
                        colors: colors
                        bar: bar
                    }

                    BluetoothIndicator {
                        colors: colors
                        bar: bar
                    }
                    
                    BrightnessIndicator {
                        colors: colors
                        bar: bar
                    }
                    
                    VolumeIndicator {
                        colors: colors
                        bar: bar
                    }

                    SystemIndicator {
                        colors: colors
                        bar: bar
                    }

                    SystemTrayModule {
                        colors: colors
                        bar: bar
                    }

                    TimeIndicator {
                        colors: colors
                        bar: bar
                        currentTime: root.currentTime
                    }

                    PowerModule {
                        colors: colors
                        bar: bar
                    }
                }
            }
        }

        DropShadow {
            anchors.fill: barContent
            source: barContent
            radius: 8
            samples: 16
            color: "#80000000"
            verticalOffset: 2
            z: 0
        }
    }
}
