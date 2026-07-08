import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    // Bluetooth properties
    readonly property string state: {
        if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "off";
        for (const device of Bluetooth.devices.values) {
            if (device.connected) return "connected";
        }
        return "on";
    }
    readonly property bool scanning: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.discovering : false
    readonly property var pairedDevices: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices.values.filter(device => device.paired) : []
    readonly property var availableDevices: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices.values.filter(device => !device.paired && device.name !== "") : []

    property bool menuVisible: false

    implicitWidth: indicator.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    StatusIndicator {
        id: indicator
        icon: root.state === "connected" ? "󰂱" : (root.state === "on" ? "󰂯" : "󰂲")
        iconColor: root.state === "off" ? colors.surface1 : colors.blue
        colors: root.colors
        onClicked: root.menuVisible = !root.menuVisible
    }

    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let visibleDummy = popup.visible
            let xDummy = root.x
            let targetX = root.mapToItem(null, 0, 0).x - (btMenu.implicitWidth - root.width) / 2
            return Math.max(6, Math.min(bar.width - btMenu.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height - 8
        implicitWidth: btMenu.implicitWidth
        implicitHeight: btMenu.implicitHeight + 40
        visible: root.menuVisible
        grabFocus: true
        onVisibleChanged: if (!visible) root.menuVisible = false
        color: "transparent"
        
        BluetoothMenu {
            id: btMenu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            btState: root.state
            btScanning: root.scanning
            btPairedDevices: root.pairedDevices
            btAvailableDevices: root.availableDevices
            btMenuVisible: root.menuVisible
            onBtMenuVisibleChanged: root.menuVisible = btMenuVisible
        }
    }
}
