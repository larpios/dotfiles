import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    property int brightness: 0
    property bool menuVisible: false

    implicitWidth: indicator.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    // Get current brightness percentage
    Process {
        id: getBrightnessProcess
        command: ["sh", "-c", "brightnessctl info | grep -oP '\\(\\K[^%]+(?=%\\))' | head -n1"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    let val = parseInt(data.trim())
                    if (!isNaN(val)) {
                        root.brightness = val
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: !root.menuVisible
        onTriggered: getBrightnessProcess.running = true
    }

    StatusIndicator {
        id: indicator
        icon: "󰃠"
        label: root.brightness + "%"
        iconColor: colors.yellow
        colors: root.colors
        onClicked: root.menuVisible = !root.menuVisible
    }

    PopupWindow {
        id: popup
        anchor.window: root.bar
        anchor.rect.x: {
            let targetX = indicator.mapToItem(null, 0, 0).x - (popup.implicitWidth - indicator.width) / 2
            return Math.max(6, Math.min(root.bar.width - popup.implicitWidth - 6, targetX))
        }
        anchor.rect.y: root.bar.height + 4
        implicitWidth: brightnessMenu.implicitWidth
        implicitHeight: brightnessMenu.implicitHeight
        visible: root.menuVisible
        color: "transparent"
        
        BrightnessMenu {
            id: brightnessMenu
            colors: root.colors
            brightness: root.brightness
            onMoved: (val) => {
                if (val !== root.brightness) {
                    setBrightnessProcess.brightnessValue = val
                    setBrightnessProcess.running = true
                    root.brightness = val
                }
            }
        }
    }

    Process {
        id: setBrightnessProcess
        property int brightnessValue: 0
        command: ["brightnessctl", "s", brightnessValue + "%"]
    }
}
