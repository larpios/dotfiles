import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
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

    function formatTime(ms) {
        if (!ms || ms < 0) return "0:00"
        let totalSeconds = Math.floor(ms / 1000000)
        let hours = Math.floor(totalSeconds / 3600)
        let minutes = Math.floor((totalSeconds % 3600) / 60)
        let seconds = totalSeconds % 60
        return (hours > 0 ? hours + ":" : "") + (minutes < 10 && hours > 0 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }

    function getYouTubeThumbnail(url) {
        if (!url) return ""
        let match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&]+)/)
        if (match && match[1]) {
            return "https://img.youtube.com/vi/" + match[1] + "/hqdefault.jpg"
        }
        return ""
    }

    property bool _controlLocked: false
    Timer {
        id: controlLockTimer
        interval: 500
        onTriggered: root._controlLocked = false
    }

    function controlMedia(action) {
        if (!activePlayer || _controlLocked) return;
        
        _controlLocked = true;
        controlLockTimer.start();

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
            if (root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing) {
                root.activePlayer.positionChanged();
                let rawPos = root.activePlayer.position;
                root.mediaPosition = (rawPos > 100000) ? rawPos : rawPos * 1000000;

                let rawLen = root.activePlayer.length;
                let parsedLen = (rawLen > 100000) ? rawLen : rawLen * 1000000;
                if (parsedLen > root.mediaLength) root.mediaLength = parsedLen;
            }
        }
    }

    implicitWidth: capsule.visible ? capsule.implicitWidth : 0
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    MediaCapsule {
        id: capsule
        colors: root.colors
        
        mediaTitle: root.mediaTitle
        mediaArtist: root.mediaArtist
        mediaArt: root.mediaArt
        mediaStatus: root.mediaStatus
        formattedTime: root.formatTime(root.mediaPosition)
        
        onToggleDashboard: root.mediaDashboardVisible = !root.mediaDashboardVisible
        onNext: root.controlMedia("next")
        onPrevious: root.controlMedia("previous")
        onPlayPause: root.controlMedia("play-pause")
    }

    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let visibleDummy = popup.visible
            let xDummy = root.x
            let targetX = root.mapToItem(null, 0, 0).x - (mediaDashboard.implicitWidth - root.width) / 2
            let windowX = targetX - 20
            return Math.max(6, Math.min(bar.width - (mediaDashboard.implicitWidth + 40) - 6, windowX))
        }
        anchor.rect.y: bar.height - 8
        implicitWidth: mediaDashboard.implicitWidth + 40
        implicitHeight: mediaDashboard.implicitHeight + 60
        visible: root.mediaDashboardVisible
        grabFocus: true
        onVisibleChanged: if (!visible) root.mediaDashboardVisible = false
        color: "transparent"
        
        DropShadow {
            anchors.fill: mediaDashboard
            source: mediaDashboard
            radius: 12
            samples: 20
            color: "#80000000"
            verticalOffset: 6
            visible: popup.visible
        }

        MediaDashboard {
            id: mediaDashboard
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            menuVisible: root.mediaDashboardVisible
            
            mediaTitle: root.mediaTitle
            mediaArtist: root.mediaArtist
            mediaAlbum: root.mediaAlbum
            mediaArt: root.mediaArt
            mediaStatus: root.mediaStatus
            formattedPosition: root.formatTime(root.mediaPosition)
            formattedLength: root.formatTime(root.mediaLength)
            progress: (root.mediaLength > 0) ? (root.mediaPosition / root.mediaLength) : 0
            
            onNext: root.controlMedia("next")
            onPrevious: root.controlMedia("previous")
            onPlayPause: root.controlMedia("play-pause")
            onClose: root.mediaDashboardVisible = false
        }
    }
}
