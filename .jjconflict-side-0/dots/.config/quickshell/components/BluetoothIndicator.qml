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
            let targetX = indicator.mapToItem(null, 0, 0).x - (popup.implicitWidth - indicator.width) / 2
            return Math.max(6, Math.min(bar.width - popup.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height + 4
        implicitWidth: btMenu.implicitWidth
        implicitHeight: btMenu.implicitHeight
        visible: root.menuVisible
        color: "transparent"
        
        BluetoothMenu {
            id: btMenu
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
