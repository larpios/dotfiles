import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    implicitWidth: layout.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    // Shared model opener for extracting native menu entries
    property var selectedItem: null
    
    QsMenuOpener {
        id: menuOpener
    }
    
    function openItemMenu(item, data) {
        selectedItem = data;
        menuOpener.menu = data.menu;
        itemMenuPopup.anchor.rect.x = item.mapToItem(null, 0, 0).x - (menuContent.width - item.width) / 2 - 15;
        itemMenuPopup.anchor.rect.y = bar ? bar.height - 8 : 0;
        itemMenuPopup.visible = true;
    }

    Row {
        id: layout
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        
        Rectangle {
            height: 14
            width: 1
            color: colors.surface1
            anchors.verticalCenter: parent.verticalCenter
            visible: trayRepeater.count > 0
        }
        
        Repeater {
            id: trayRepeater
            model: SystemTray.items
            delegate: Item {
                id: trayItem
                required property var modelData
                width: 20
                height: 20
                
                IconImage {
                    anchors.fill: parent
                    source: modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            root.openItemMenu(trayItem, modelData)
                        } else {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: itemMenuPopup
        anchor.window: bar
        implicitWidth: 200 + 30
        implicitHeight: menuContent.implicitHeight + 20
        visible: false
        grabFocus: true
        color: "transparent"

        Rectangle {
            id: menuContent
            width: 200
            implicitHeight: column.implicitHeight + 12
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: colors.mantle
            radius: 10
            border.color: colors.surface1
            border.width: 1
            
            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4
                
                Text {
                    text: root.selectedItem ? root.selectedItem.title || root.selectedItem.id : ""
                    color: colors.subtext0
                    font.pixelSize: 10
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 4
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Dynamic Repeater for native menu entries (custom visual rendering of the app's menu!)
                Repeater {
                    model: menuOpener.children.values
                    delegate: Item {
                        id: entryItem
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: modelData.isSeparator ? 9 : 24
                        
                        // Separator line
                        Rectangle {
                            visible: modelData.isSeparator
                            anchors.centerIn: parent
                            width: parent.width - 12
                            height: 1
                            color: colors.surface1
                        }
                        
                        // Action menu item button
                        Rectangle {
                            visible: !modelData.isSeparator
                            anchors.fill: parent
                            radius: 4
                            color: mouseArea.containsMouse ? colors.surface0 : "transparent"
                            border.color: mouseArea.containsMouse ? colors.surface1 : "transparent"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6
                                
                                IconImage {
                                    visible: modelData.icon !== ""
                                    source: modelData.icon
                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 12
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                Text {
                                    text: modelData.text
                                    color: modelData.enabled ? (mouseArea.containsMouse ? colors.text : colors.subtext1) : colors.surface2
                                    font.pixelSize: 11
                                    font.bold: true
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }
                            
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: modelData.enabled
                                cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (modelData.enabled) {
                                        modelData.triggered() // execute the native app command!
                                        itemMenuPopup.visible = false
                                    }
                                }
                            }
                        }
                    }
                }

                // Separator before fallback option if entries were shown
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: colors.surface1
                    visible: menuOpener.children.values.length > 0
                }

                PowerOption {
                    icon: "󰈆"
                    label: "Terminate Program"
                    optColor: colors.red
                    colors: root.colors
                    onTriggered: {
                        if (root.selectedItem) {
                            let id = root.selectedItem.id;
                            // Try to extract PID from ID like org.kde.StatusNotifierItem-1234-1
                            let pidMatch = id.match(/-(\d+)-/);
                            if (pidMatch && pidMatch[1]) {
                                terminateProcess.run(["kill", "-9", pidMatch[1]]);
                            } else {
                                // Fallback to killall using the ID (often the app name)
                                terminateProcess.run(["killall", "-9", id.split('.').pop()]);
                            }
                        }
                        itemMenuPopup.visible = false
                    }
                }
            }
        }
        
        DropShadow {
            anchors.fill: menuContent
            source: menuContent
            radius: 8
            samples: 16
            color: "#80000000"
            verticalOffset: 2
            visible: itemMenuPopup.visible
        }
    }

    Process {
        id: terminateProcess
        running: false
        function run(cmd) {
            command = cmd
            running = true
        }
    }
}
