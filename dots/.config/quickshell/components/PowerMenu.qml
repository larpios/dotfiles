import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: powerMenuContent
    property var colors: ({})
    property bool menuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: powerMenuContent.width / 2
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
    
    signal actionTriggered(var action)

    implicitWidth: 180
    implicitHeight: powerMenuLayout.implicitHeight + 20
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: powerMenuContent.colors
    }
    
    ColumnLayout {
        id: powerMenuLayout
        anchors.fill: parent
        anchors.leftMargin: 10 + 12
        anchors.rightMargin: 10 + 12
        anchors.topMargin: 10 + 12
        anchors.bottomMargin: 10
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
