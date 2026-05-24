pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ShellRoot {
    id: root
    Colors { id: colors }

    property date currentTime: new Date()
    property int cpuUsage: 0
    property int lastCpuTotal: 0
    property int lastCpuIdle: 0
    property int memUsage: 0
    property int volume: 0
    property bool muted: false

    // Media properties
    property var activePlayer: {
        const players = Mpris.players.values;
        if (players.length === 0) return null;
        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Playing) return player;
        }
        return players[0];
    }

    property string mediaTitle: activePlayer ? activePlayer.trackTitle : "No Media"
    property string mediaArtist: activePlayer ? activePlayer.trackArtist : "Unknown Artist"
    property string mediaAlbum: activePlayer ? activePlayer.trackAlbum : ""
    property string mediaArt: {
        if (!activePlayer) return "";
        let art = activePlayer.trackArtUrl || "";
        let url = activePlayer.metadata["xesam:url"] || "";
        
        if (art === "" && url !== "") {
            art = getYouTubeThumbnail(url)
        } else if (art.startsWith("/")) {
            art = "file://" + art
        }
        return art;
    }
    property string mediaUrl: activePlayer ? (activePlayer.metadata["xesam:url"] || "") : ""
    property string mediaStatus: {
        if (!activePlayer) return "Stopped";
        switch (activePlayer.playbackState) {
            case MprisPlaybackState.Playing: return "Playing";
            case MprisPlaybackState.Paused: return "Paused";
            case MprisPlaybackState.Stopped: return "Stopped";
            default: return "Stopped";
        }
    }
    property real mediaPosition: 0
    property real mediaLength: 0
    property string currentTrackId: activePlayer ? (activePlayer.metadata["xesam:url"] || activePlayer.trackTitle) : ""

    onCurrentTrackIdChanged: {
        root.mediaLength = 0;
    }
    property bool mediaDashboardVisible: false

    // Power Menu State
    property bool powerMenuVisible: false

    function formatTime(ms) {
        if (!ms || ms < 0) return "0:00"
        let totalSeconds = Math.floor(ms / 1000000)
        let hours = Math.floor(totalSeconds / 3600)
        let minutes = Math.floor((totalSeconds % 3600) / 60)
        let seconds = totalSeconds % 60
        return hours + ":" + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }

    function getYouTubeThumbnail(url) {
        if (!url) return ""
        let match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&]+)/)
        if (match && match[1]) {
            return "https://img.youtube.com/vi/" + match[1] + "/hqdefault.jpg"
        }
        return ""
    }

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
        Component.onCompleted: running = true
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

    // Volume
    Process {
        id: volProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                let match = data.match(/Volume: (\d\.\d+)( \[MUTED\])?/)
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100)
                    root.muted = !!match[2]
                }
            }
        }
    }

    // Generic Action Process
    Process {
        id: actionProcess
        running: false
    }

    function runAction(cmd) {
        actionProcess.running = false
        actionProcess.command = cmd
        actionProcess.running = true
    }

    function controlMedia(action) {
        if (!activePlayer) return;
        switch (action) {
            case "play-pause": activePlayer.togglePlaying(); break;
            case "next": activePlayer.next(); break;
            case "previous": activePlayer.previous(); break;
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            root.currentTime = new Date()
            cpuProcess.running = true
            memProcess.running = true
            volProcess.running = true
            if (root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing) {
                root.activePlayer.positionChanged(); // Force fresh poll
                let rawPos = root.activePlayer.position;
                if (rawPos > 100000) {
                    root.mediaPosition = rawPos;
                } else {
                    root.mediaPosition = rawPos * 1000000;
                }

                let rawLen = root.activePlayer.length;
                let parsedLen = (rawLen > 100000) ? rawLen : rawLen * 1000000;
                // Cache the largest length we've seen for this track.
                // This ignores the Firefox PiP bug where length is reported as equal to position.
                if (parsedLen > root.mediaLength) {
                    root.mediaLength = parsedLen;
                }
            }
        }
    }

    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 40
        color: "transparent"

        Rectangle {
            id: barContent
            anchors.fill: parent
            anchors.margins: 6
            color: colors.base
            radius: 12
            border.color: colors.surface1
            border.width: 1

            // --- Absolute Center Window Title ---
            Text {
                id: windowTitleLabel
                anchors.centerIn: parent
                text: (Hyprland.activeToplevel && Hyprland.activeToplevel.title) ? Hyprland.activeToplevel.title : "Hyprland"
                color: colors.subtext1
                font.pixelSize: 11
                font.bold: true
                elide: Text.ElideRight
                width: parent.width * 0.4
                horizontalAlignment: Text.AlignHCenter
                z: 10
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 0

                // --- Left Section ---
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16

                    Text {
                        text: "󰣇"
                        color: colors.blue
                        font.pixelSize: 18
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("Launcher clicked")
                        }
                    }

                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter
                        Repeater {
                            model: Hyprland.workspaces
                            delegate: Rectangle {
                                required property var modelData
                                property bool isActive: modelData.active
                                width: isActive ? 32 : 20
                                height: 20
                                radius: 10
                                color: isActive ? colors.mauve : colors.surface1
                                border.color: isActive ? colors.mauve : colors.surface1
                                border.width: 1
                                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData.name
                                    color: parent.isActive ? colors.crust : colors.text
                                    font.pixelSize: 10
                                    font.bold: parent.isActive
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.modelData.activate()
                                }
                            }
                        }
                    }

                    // --- Media Capsule ---
                    Rectangle {
                        id: mediaContainer
                        Layout.alignment: Qt.AlignVCenter
                        height: 25
                        width: mediaLayout.implicitWidth + 30
                        color: colors.mantle
                        radius: 15
                        border.color: colors.surface0
                        border.width: 1
                        visible: root.mediaStatus !== "Stopped" && root.mediaTitle !== ""
                        clip: true

                        // Background art/blur
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: mediaContainer.width
                                    height: mediaContainer.height
                                    radius: 15
                                }
                            }

                            Image {
                                id: barBlurredArtSource
                                anchors.fill: parent
                                source: root.mediaArt
                                fillMode: Image.PreserveAspectCrop
                                visible: false
                            }

                            GaussianBlur {
                                anchors.fill: parent
                                source: barBlurredArtSource
                                radius: 20
                                samples: 16
                                opacity: 0.6
                                visible: root.mediaArt !== ""
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: colors.base
                                opacity: 0.3
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.mediaDashboardVisible = !root.mediaDashboardVisible
                        }

                        RowLayout {
                            id: mediaLayout
                            anchors.centerIn: parent
                            spacing: 10
                            
                            Item {
                                width: 22
                                height: 22
                                Layout.alignment: Qt.AlignVCenter
                                visible: root.mediaArt !== ""
                                
                                Rectangle { id: thumbMask; anchors.fill: parent; radius: 11; visible: false }

                                Image {
                                    anchors.fill: parent
                                    source: root.mediaArt
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: true
                                    layer.effect: OpacityMask { maskSource: thumbMask }
                                }
                            }
                            
                            Text {
                                text: root.formatTime(root.mediaPosition)
                                color: colors.mauve
                                font.pixelSize: 9
                                font.bold: true
                                Layout.alignment: Qt.AlignVCenter
                                visible: root.mediaStatus !== "Stopped"
                            }

                            ColumnLayout {
                                spacing: -4
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: root.mediaTitle
                                    color: colors.text
                                    font.pixelSize: 10
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                                Text {
                                    text: root.mediaArtist
                                    color: colors.subtext0
                                    font.pixelSize: 8
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }
                            
                            Row {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: "󰒮"
                                    color: colors.subtext1
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.controlMedia("previous")
                                    }
                                }
                                Text {
                                    text: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                    color: colors.mauve
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.controlMedia("play-pause")
                                    }
                                }
                                Text {
                                    text: "󰒭"
                                    color: colors.subtext1
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.controlMedia("next")
                                    }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // --- Right Section ---
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16
                    
                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            text: root.muted ? "󰝟" : (root.volume > 50 ? "󰕾" : "󰖀")
                            color: root.muted ? colors.red : colors.lavender
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: root.volume + "%"
                            color: colors.subtext1
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 12
                        Layout.alignment: Qt.AlignVCenter
                        Row {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Text { text: "󰻠"; color: colors.blue; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: root.cpuUsage + "%"
                                color: colors.subtext1
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Text {
                                text: "󰍛"
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

                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle {
                            height: 14
                            width: 1
                            color: colors.surface1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: Qt.formatDateTime(root.currentTime, "yyyy-MM-dd HH:mm:ss")
                            color: colors.mauve
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        id: powerBtn
                        width: 26
                        height: 26
                        radius: 13
                        color: root.powerMenuVisible ? colors.surface2 : colors.surface0
                        Layout.alignment: Qt.AlignVCenter
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
                            onEntered: if (!root.powerMenuVisible) parent.color = colors.surface1
                            onExited: if (!root.powerMenuVisible) parent.color = colors.surface0
                            onClicked: root.powerMenuVisible = !root.powerMenuVisible
                        }
                    }
                }
            }
        }

        DropShadow {
            anchors.fill: barContent
            source: barContent
            radius: 8
            samples: 16
            color: "#80000000"
            verticalOffset: 2
            z: 0
        }
    }

    // --- Power Menu Popup ---
    PopupWindow {
        id: powerMenuPopup
        anchor.window: bar
        anchor.rect.x: bar.width - width - 12
        anchor.rect.y: bar.height + 4
        implicitWidth: 180
        implicitHeight: powerMenuLayout.implicitHeight + 40
        visible: root.powerMenuVisible
        color: "transparent"
        Rectangle {
            id: powerMenuContent
            anchors.fill: parent
            anchors.margins: 10
            color: colors.mantle
            radius: 12
            border.color: colors.surface1
            border.width: 1
            ColumnLayout {
                id: powerMenuLayout
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4
                PowerOption {
                    icon: "󰐥"
                    label: "Shutdown"
                    optColor: colors.red
                    action: ["systemctl", "poweroff"]
                }
                PowerOption {
                    icon: "󰜉"
                    label: "Reboot"
                    optColor: colors.peach
                    action: ["systemctl", "reboot"]
                }
                PowerOption {
                    icon: "󰤄"
                    label: "Suspend"
                    optColor: colors.mauve
                    action: ["systemctl", "suspend"]
                }
                PowerOption {
                    icon: "󰈆"
                    label: "Logout"
                    optColor: colors.yellow
                    action: ["hyprctl", "dispatch", "exit"]
                }
            }
        }
        DropShadow {
            anchors.fill: powerMenuContent
            source: powerMenuContent
            radius: 10
            samples: 16
            color: "#80000000"
            verticalOffset: 4
        }
    }

    // --- Media Dashboard Popup ---
    PopupWindow {
        id: mediaDashboardPopup
        anchor.window: bar
        anchor.rect.x: mediaContainer.mapToItem(bar.contentItem, 0, 0).x - (implicitWidth - mediaContainer.width) / 2
        anchor.rect.y: bar.height + 4
        implicitWidth: 340
        implicitHeight: 520
        visible: root.mediaDashboardVisible
        color: "transparent"

        Rectangle {
            id: mediaDashboardContent
            anchors.fill: parent
            anchors.margins: 10
            color: colors.crust
            radius: 20
            border.color: colors.surface0
            border.width: 1
            clip: true
            Rectangle { anchors.fill: parent; color: colors.base; opacity: 0.8 }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 240
                    height: 240
                    radius: 15
                    color: colors.surface0
                    clip: true
                    Image {
                        anchors.fill: parent
                        source: root.mediaArt
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "󰎆"
                        color: colors.surface1
                        font.pixelSize: 64
                        visible: root.mediaArt === ""
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: root.mediaTitle
                        color: colors.text
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.mediaArtist
                        color: colors.mauve
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.mediaAlbum
                        color: colors.subtext0
                        font.pixelSize: 11
                        font.italic: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        visible: root.mediaAlbum !== ""
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 4
                    visible: root.mediaStatus !== "Stopped"
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: colors.surface0
                        Rectangle {
                            width: (root.mediaLength > 0) ? (root.mediaPosition / root.mediaLength) * parent.width : 0
                            height: parent.height
                            radius: 2
                            color: colors.mauve
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: root.formatTime(root.mediaPosition); color: colors.subtext1; font.pixelSize: 10 }
                        Item { Layout.fillWidth: true }
                        Text { text: (root.mediaLength > 0) ? root.formatTime(root.mediaLength) : "--:--"; color: colors.subtext1; font.pixelSize: 10 }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                    spacing: 30
                    Text {
                        text: "󰒮"
                        color: colors.subtext1
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.controlMedia("previous")
                        }
                    }
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: colors.mauve
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            anchors.centerIn: parent
                            text: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                            color: colors.crust
                            font.pixelSize: 24
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.controlMedia("play-pause")
                        }
                    }
                    Text {
                        text: "󰒭"
                        color: colors.subtext1
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.controlMedia("next")
                        }
                    }
                }
            }
        }
        DropShadow {
            anchors.fill: mediaDashboardContent
            source: mediaDashboardContent
            radius: 12
            samples: 20
            color: "#80000000"
            verticalOffset: 6
        }
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.mediaDashboardVisible = false
        }
    }

    // --- Helper Component ---
    component PowerOption : Rectangle {
        id: powerOption
        property string icon: ""
        property string label: ""
        property color optColor: colors.text
        property var action: []
        Layout.fillWidth: true
        height: 32
        radius: 6
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            spacing: 10
            Text {
                text: powerOption.icon
                color: powerOption.optColor
                font.pixelSize: 16
                Layout.preferredWidth: 20
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: powerOption.label
                color: colors.text
                font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.color = colors.surface0
            onExited: parent.color = "transparent"
            onClicked: {
                root.runAction(parent.action)
                root.powerMenuVisible = false
            }
        }
    }
}
