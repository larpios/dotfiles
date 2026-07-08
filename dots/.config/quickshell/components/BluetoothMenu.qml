import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

Rectangle {
    id: btMenuContent
    property var colors: ({})
    
    // Properties passed from indicator
    property string btState: "off"
    property bool btScanning: false
    property var btPairedDevices: []
    property var btAvailableDevices: []
    property bool btMenuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: btMenuContent.width / 2
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
    
    onBtMenuVisibleChanged: {
        if (btMenuVisible) {
            scaleInAnim.start();
        } else {
            scaleInAnim.stop();
            menuScale.yScale = 0.0;
        }
    }
    
    Component.onCompleted: {
        if (btMenuVisible) {
            scaleInAnim.start();
        }
    }

    implicitWidth: 240
    implicitHeight: btMenuLayout.implicitHeight + 20
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: btMenuContent.colors
    }
    
    ColumnLayout {
        id: btMenuLayout
        anchors.fill: parent
        anchors.leftMargin: 10 + 12
        anchors.rightMargin: 10 + 12
        anchors.topMargin: 10 + 12
        anchors.bottomMargin: 10
        spacing: 10
        
        // Toggle Switch
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Bluetooth"
                color: colors.text
                font.bold: true
                Layout.fillWidth: true
            }
            Rectangle {
                width: 36
                height: 20
                radius: 10
                color: btMenuContent.btState !== "off" ? colors.blue : colors.surface1
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: colors.crust
                    anchors.verticalCenter: parent.verticalCenter
                    x: btMenuContent.btState !== "off" ? 18 : 2
                    Behavior on x { NumberAnimation { duration: 200 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Bluetooth.defaultAdapter) {
                            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                        }
                    }
                }
            }
        }

        // Scanning Toggle
        RowLayout {
            Layout.fillWidth: true
            visible: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
            Text {
                text: btMenuContent.btScanning ? "Scanning..." : "Scan for Devices"
                color: btMenuContent.btScanning ? colors.mauve : colors.subtext0
                font.pixelSize: 11
                Layout.fillWidth: true
            }
            Text {
                text: btMenuContent.btScanning ? "󰓦" : "󰑐"
                color: btMenuContent.btScanning ? colors.mauve : colors.subtext1
                font.pixelSize: 14
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Bluetooth.defaultAdapter) {
                            Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering
                        }
                    }
                }
            }
        }

        // Paired Devices
        Text { text: "Paired Devices"; color: colors.subtext0; font.pixelSize: 10; font.bold: true; visible: btMenuContent.btPairedDevices.length > 0 }
        ColumnLayout {
            spacing: 2
            visible: btMenuContent.btPairedDevices.length > 0
            Repeater {
                model: btMenuContent.btPairedDevices
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        Text { text: modelData.connected ? "󰂱" : "󰂯"; color: colors.blue; font.pixelSize: 14 }
                        Text { text: modelData.name || modelData.address; color: colors.text; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = colors.surface0
                        onExited: parent.color = "transparent"
                        onClicked: {
                            modelData.connected = !modelData.connected
                            btMenuContent.btMenuVisible = false
                        }
                    }
                }
            }
        }

        // Available Devices
        Text { text: "Available Devices"; color: colors.subtext0; font.pixelSize: 10; font.bold: true; visible: btMenuContent.btAvailableDevices.length > 0 }
        ColumnLayout {
            spacing: 2
            visible: btMenuContent.btAvailableDevices.length > 0
            Repeater {
                model: btMenuContent.btAvailableDevices
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        Text { text: "󰂯"; color: colors.surface1; font.pixelSize: 14 }
                        Text { text: modelData.name || modelData.address; color: colors.text; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = colors.surface0
                        onExited: parent.color = "transparent"
                        onClicked: {
                            modelData.paired = true
                            modelData.connected = true
                            btMenuContent.btMenuVisible = false
                        }
                    }
                }
            }
        }
    }
}
