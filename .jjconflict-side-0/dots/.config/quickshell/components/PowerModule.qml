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
            let targetX = powerBtn.mapToItem(null, 0, 0).x - (popup.implicitWidth - powerBtn.width)
            return Math.max(6, Math.min(bar.width - popup.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height + 4
        implicitWidth: powerMenu.implicitWidth
        implicitHeight: powerMenu.implicitHeight
        visible: root.menuVisible
        color: "transparent"
        
        PowerMenu {
            id: powerMenu
            colors: root.colors
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
