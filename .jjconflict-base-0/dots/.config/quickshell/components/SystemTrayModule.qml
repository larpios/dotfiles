import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Item {
    id: root
    property var colors: ({})
    
    implicitWidth: layout.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

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
                            modelData.menu.open(trayItem)
                        } else {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
