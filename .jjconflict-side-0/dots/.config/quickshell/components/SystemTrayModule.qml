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

    // Shared popup for all tray items
    property var selectedItem: null
    
    function openItemMenu(item, data) {
        selectedItem = data;
        itemMenuPopup.anchor.rect.x = item.mapToItem(null, 0, 0).x - (itemMenuPopup.implicitWidth - item.width) / 2;
        itemMenuPopup.anchor.rect.y = bar ? bar.height + 4 : 0;
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
        implicitWidth: 180
        implicitHeight: menuContent.implicitHeight
        visible: false
        color: "transparent"

        Rectangle {
            id: menuContent
            width: 180
            implicitHeight: column.implicitHeight + 12
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
                }

                PowerOption {
                    visible: root.selectedItem && root.selectedItem.hasMenu
                    icon: "󰍜"
                    label: "Open App Menu"
                    optColor: colors.blue
                    colors: root.colors
                    onTriggered: {
                        root.selectedItem.menu.open(null)
                        itemMenuPopup.visible = false
                    }
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

    // Still keep the "Quit Quickshell" option but only on background right click
    MouseArea {
        anchors.fill: parent
        z: -1 // Behind the Row
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                shellMenuPopup.anchor.rect.x = root.mapToItem(null, 0, 0).x;
                shellMenuPopup.anchor.rect.y = bar ? bar.height + 4 : 0;
                shellMenuPopup.visible = true;
            }
        }
    }

    PopupWindow {
        id: shellMenuPopup
        anchor.window: bar
        implicitWidth: 160
        implicitHeight: shellMenuContent.implicitHeight
        visible: false
        color: "transparent"

        Rectangle {
            id: shellMenuContent
            width: 160
            implicitHeight: 44
            color: colors.mantle
            radius: 10
            border.color: colors.surface1
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                PowerOption {
                    icon: "󰈆"
                    label: "Quit Quickshell"
                    optColor: colors.red
                    colors: root.colors
                    onTriggered: {
                        Qt.quit()
                        shellMenuPopup.visible = false
                    }
                }
            }
        }
    }
}
