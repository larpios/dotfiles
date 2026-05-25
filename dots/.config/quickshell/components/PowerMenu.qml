import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: powerMenuContent
    property var colors: ({})
    
    signal actionTriggered(var action)

    implicitWidth: 180
    implicitHeight: powerMenuLayout.implicitHeight + 20
    color: colors.mantle
    radius: 12
    border.color: colors.surface1
    border.width: 1
    
    ColumnLayout {
        id: powerMenuLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        
        PowerOption {
            icon: "󰐥"
            label: "Shutdown"
            optColor: colors.red
            action: ["systemctl", "poweroff"]
            colors: powerMenuContent.colors
            onTriggered: (action) => powerMenuContent.actionTriggered(action)
        }
        PowerOption {
            icon: "󰜉"
            label: "Reboot"
            optColor: colors.peach
            action: ["systemctl", "reboot"]
            colors: powerMenuContent.colors
            onTriggered: (action) => powerMenuContent.actionTriggered(action)
        }
        PowerOption {
            icon: "󰤄"
            label: "Suspend"
            optColor: colors.mauve
            action: ["systemctl", "suspend"]
            colors: powerMenuContent.colors
            onTriggered: (action) => powerMenuContent.actionTriggered(action)
        }
        PowerOption {
            icon: "󰈆"
            label: "Logout"
            optColor: colors.yellow
            action: ["hyprctl", "dispatch", "exit"]
            colors: powerMenuContent.colors
            onTriggered: (action) => powerMenuContent.actionTriggered(action)
        }
    }
}
