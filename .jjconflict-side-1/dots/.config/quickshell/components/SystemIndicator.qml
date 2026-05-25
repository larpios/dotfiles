import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0
    property int memUsage: 0
    property var cpuHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    implicitWidth: layout.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    // CPU Usage
    Process {
        id: cpuProcess
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)))
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }
    }

    // Memory Usage
    Process {
        id: memProcess
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        running: true
        stdout: SplitParser {
            onRead: (data) => root.memUsage = Math.round(parseFloat(data))
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            cpuProcess.running = true
            memProcess.running = true
            root.cpuHistory = [...root.cpuHistory, root.cpuUsage].slice(-15)
        }
    }

    Row {
        id: layout
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter
        
        Row {
            spacing: 6
            Text { text: ""; color: colors.red; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
            
            // CPU Graph
            Row {
                spacing: 1
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: root.cpuHistory
                    delegate: Rectangle {
                        required property var modelData
                        width: 2
                        height: Math.max(2, (modelData / 100) * 14)
                        color: colors.blue
                        opacity: 0.6
                        anchors.bottom: parent.bottom
                        radius: 1
                    }
                }
            }

            Text {
                text: root.cpuUsage + "%"
                color: colors.subtext1
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Row {
            spacing: 4
            Text {
                text: ""
                color: colors.green
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.memUsage + "%"
                color: colors.subtext1
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
