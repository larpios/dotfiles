import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    property bool menuVisible: false

    implicitWidth: powerBtn.width
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    Rectangle {
        id: powerBtn
        width: 26
        height: 26
        radius: 13
        color: root.menuVisible ? colors.surface2 : colors.surface0
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.centerIn: parent
            text: "󰐥"
            color: colors.red
            font.pixelSize: 14
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: if (!root.menuVisible) parent.color = colors.surface1
            onExited: if (!root.menuVisible) parent.color = colors.surface0
            onClicked: root.menuVisible = !root.menuVisible
        }
    }

    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let visibleDummy = popup.visible
            let xDummy = root.x
            let targetX = root.mapToItem(null, 0, 0).x - (powerMenu.implicitWidth - root.width)
            let windowX = targetX - 15
            return Math.max(6, Math.min(bar.width - (powerMenu.implicitWidth + 30) - 6, windowX))
        }
        anchor.rect.y: bar.height - 8
        implicitWidth: powerMenu.implicitWidth + 30
        implicitHeight: powerMenu.implicitHeight + 60
        visible: root.menuVisible
        color: "transparent"
        
        PowerMenu {
            id: powerMenu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            menuVisible: root.menuVisible
            onActionTriggered: (action) => {
                actionProcess.run(action)
                root.menuVisible = false
            }
        }
        
        DropShadow {
            anchors.fill: powerMenu
            source: powerMenu
            radius: 10
            samples: 16
            color: "#80000000"
            verticalOffset: 4
            visible: popup.visible
        }
    }

    Process {
        id: actionProcess
        running: false
        function run(cmd) {
            command = cmd
            running = true
        }
    }
}
