import QtQuick
import QtQuick.Layouts
import Quickshell
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    property date currentTime: new Date()
    
    property bool menuVisible: false
    property bool hovered: false
    
    implicitWidth: container.implicitWidth
    implicitHeight: 28
    Layout.alignment: Qt.AlignVCenter
    
    Rectangle {
        id: container
        implicitWidth: layout.implicitWidth + 12
        implicitHeight: parent.implicitHeight
        radius: 6
        color: root.hovered ? colors.surface0 : "transparent"
        border.color: root.hovered ? colors.surface1 : "transparent"
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        
        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "󰥔"
                color: root.hovered ? colors.pink : colors.mauve
                font.pixelSize: 13
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            Text {
                text: Qt.formatDateTime(root.currentTime, "yyyy-MM-dd HH:mm:ss (ddd)")
                color: root.hovered ? colors.text : colors.mauve
                font.pixelSize: 11
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hovered = true
            onExited: root.hovered = false
            onClicked: root.menuVisible = !root.menuVisible
        }
    }
    
    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let targetX = container.mapToItem(null, 0, 0).x - (popup.implicitWidth - container.width) / 2
            return Math.max(6, Math.min(bar.width - popup.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height + 4
        implicitWidth: timeMenu.implicitWidth
        implicitHeight: timeMenu.implicitHeight
        visible: root.menuVisible
        color: "transparent"
        
        TimeMenu {
            id: timeMenu
            colors: root.colors
            currentTime: root.currentTime
            menuVisible: root.menuVisible
        }
    }
}
