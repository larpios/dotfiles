import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: timeMenuContent
    property var colors: ({})
    property bool menuVisible: false
    property date currentTime: new Date()

    implicitWidth: 440
    implicitHeight: 240
    color: colors.mantle
    radius: 12
    border.color: colors.surface1
    border.width: 1

    // Clock rotations
    property real hourRotation: 0
    property real minuteRotation: 0
    property real secondRotation: 0

    // System info
    property string uptimeStr: "Loading..."
    property string loadStr: "Loading..."

    // Calendar state
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property int displayedMonth: currentMonth
    property int displayedYear: currentYear
    property var calendarDays: []

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    function updateCalendar() {
        let year = displayedYear;
        let month = displayedMonth;
        let firstDayIndex = new Date(year, month, 1).getDay(); // 0 is Sunday
        let daysInMonth = new Date(year, month + 1, 0).getDate();
        let prevDaysInMonth = new Date(year, month, 0).getDate();
        
        let days = [];
        // Trailing days from previous month
        for (let i = firstDayIndex - 1; i >= 0; i--) {
            days.push({ day: prevDaysInMonth - i, isCurrent: false, isToday: false });
        }
        // Days of current month
        let today = new Date();
        for (let i = 1; i <= daysInMonth; i++) {
            let isToday = (today.getDate() === i && today.getMonth() === month && today.getFullYear() === year);
            days.push({ day: i, isCurrent: true, isToday: isToday });
        }
        // Leading days of next month
        let remaining = 42 - days.length;
        for (let i = 1; i <= remaining; i++) {
            days.push({ day: i, isCurrent: false, isToday: false });
        }
        calendarDays = days;
    }

    Component.onCompleted: {
        updateCalendar();
        updateStats();
    }

    onMenuVisibleChanged: {
        if (menuVisible) {
            displayedMonth = new Date().getMonth();
            displayedYear = new Date().getFullYear();
            updateCalendar();
            updateStats();
        }
    }

    // Smooth sweeping clock timer
    Timer {
        interval: 30
        repeat: true
        running: timeMenuContent.menuVisible
        onTriggered: {
            let d = new Date();
            let ms = d.getMilliseconds();
            let sec = d.getSeconds() + ms / 1000.0;
            let min = d.getMinutes() + sec / 60.0;
            let hr = (d.getHours() % 12) + min / 60.0;
            
            timeMenuContent.secondRotation = sec * 6;
            timeMenuContent.minuteRotation = min * 6;
            timeMenuContent.hourRotation = hr * 30;
        }
    }

    // System stats processes
    Process {
        id: uptimeProcess
        command: ["uptime", "-p"]
        stdout: SplitParser {
            onRead: data => {
                if (data) timeMenuContent.uptimeStr = data.trim().replace(/^up\s+/, "");
            }
        }
    }

    Process {
        id: loadProcess
        command: ["sh", "-c", "cat /proc/loadavg | awk '{print $1, $2, $3}'"]
        stdout: SplitParser {
            onRead: data => {
                if (data) timeMenuContent.loadStr = data.trim();
            }
        }
    }

    function updateStats() {
        uptimeProcess.running = true;
        loadProcess.running = true;
    }

    // Refresh stats every 10 seconds when open
    Timer {
        interval: 10000
        repeat: true
        running: timeMenuContent.menuVisible
        onTriggered: updateStats()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 16

        // --- Left Column: Analog Clock + Stats ---
        ColumnLayout {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            spacing: 10

            // Analog Clock Face
            Rectangle {
                id: clockFace
                width: 100
                height: 100
                radius: 50
                color: colors.surface0
                border.color: colors.surface2
                border.width: 2
                Layout.alignment: Qt.AlignHCenter

                // Hour notches
                Repeater {
                    model: 12
                    delegate: Rectangle {
                        width: 2
                        height: index % 3 === 0 ? 8 : 4
                        color: index % 3 === 0 ? colors.mauve : colors.overlay0
                        x: 50 - width / 2
                        y: 2
                        transformOrigin: Item.Bottom
                        transform: Rotation {
                            origin.x: 1
                            origin.y: 48
                            angle: index * 30
                        }
                    }
                }

                // Hour Hand
                Rectangle {
                    width: 3.5
                    height: 28
                    radius: 2
                    color: colors.text
                    x: 50 - width / 2
                    y: 50 - height
                    transformOrigin: Item.Bottom
                    rotation: timeMenuContent.hourRotation
                }

                // Minute Hand
                Rectangle {
                    width: 2.5
                    height: 40
                    radius: 1.5
                    color: colors.subtext0
                    x: 50 - width / 2
                    y: 50 - height
                    transformOrigin: Item.Bottom
                    rotation: timeMenuContent.minuteRotation
                }

                // Second Hand
                Rectangle {
                    width: 1.2
                    height: 44
                    color: colors.red
                    x: 50 - width / 2
                    y: 50 - height
                    transformOrigin: Item.Bottom
                    rotation: timeMenuContent.secondRotation
                }

                // Center Pin
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: colors.mauve
                    anchors.centerIn: parent
                }
            }

            // Timezone Displays
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Text { text: "Local:"; color: colors.subtext1; font.pixelSize: 10; font.bold: true }
                    Text {
                        text: Qt.formatDateTime(timeMenuContent.currentTime, "HH:mm:ss")
                        color: colors.text
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "monospace"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                RowLayout {
                    Text { text: "UTC:"; color: colors.subtext1; font.pixelSize: 10; font.bold: true }
                    Text {
                        text: {
                            let d = timeMenuContent.currentTime;
                            return d.getUTCHours().toString().padStart(2, '0') + ":" +
                                   d.getUTCMinutes().toString().padStart(2, '0') + ":" +
                                   d.getUTCSeconds().toString().padStart(2, '0');
                        }
                        color: colors.mauve
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "monospace"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // System Uptime / Load Stats
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Rectangle { Layout.fillWidth: true; height: 1; color: colors.surface1 }

                RowLayout {
                    Text { text: "Uptime:"; color: colors.subtext0; font.pixelSize: 9 }
                    Text {
                        text: timeMenuContent.uptimeStr
                        color: colors.subtext1
                        font.pixelSize: 9
                        elide: Text.ElideLeft
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                RowLayout {
                    Text { text: "Load:"; color: colors.subtext0; font.pixelSize: 9 }
                    Text {
                        text: timeMenuContent.loadStr
                        color: colors.subtext1
                        font.pixelSize: 9
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // Vertical Separator
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: colors.surface1
        }

        // --- Right Column: Calendar ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            // Calendar Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: timeMenuContent.monthNames[timeMenuContent.displayedMonth] + " " + timeMenuContent.displayedYear
                    color: colors.text
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                }

                // Prev Month
                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: prevMouse.containsMouse ? colors.surface0 : "transparent"
                    Text { anchors.centerIn: parent; text: "󰅁"; color: colors.subtext1; font.pixelSize: 12 }
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (timeMenuContent.displayedMonth === 0) {
                                timeMenuContent.displayedMonth = 11;
                                timeMenuContent.displayedYear--;
                            } else {
                                timeMenuContent.displayedMonth--;
                            }
                            timeMenuContent.updateCalendar();
                        }
                    }
                }

                // Next Month
                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: nextMouse.containsMouse ? colors.surface0 : "transparent"
                    Text { anchors.centerIn: parent; text: "󰅂"; color: colors.subtext1; font.pixelSize: 12 }
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (timeMenuContent.displayedMonth === 11) {
                                timeMenuContent.displayedMonth = 0;
                                timeMenuContent.displayedYear++;
                            } else {
                                timeMenuContent.displayedMonth++;
                            }
                            timeMenuContent.updateCalendar();
                        }
                    }
                }
            }

            // Calendar Days Grid
            GridLayout {
                columns: 7
                rowSpacing: 4
                columnSpacing: 4
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                // Weekday Headers
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    delegate: Text {
                        required property var modelData
                        text: modelData
                        color: colors.mauve
                        font.pixelSize: 9
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                }

                // Days
                Repeater {
                    model: timeMenuContent.calendarDays
                    delegate: Rectangle {
                        required property var modelData
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        color: modelData.isToday ? colors.mauve : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: modelData.isToday 
                                ? colors.crust 
                                : (modelData.isCurrent ? colors.text : colors.surface1)
                            font.bold: modelData.isToday || modelData.isCurrent
                            font.pixelSize: 9
                        }
                    }
                }
            }
        }
    }
}
