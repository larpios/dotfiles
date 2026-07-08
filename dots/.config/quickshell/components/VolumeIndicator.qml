import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    // Volume properties
    readonly property int volume: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
    readonly property bool muted: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : false

    property bool menuVisible: false

    implicitWidth: indicator.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    StatusIndicator {
        id: indicator
        icon: root.muted ? "󰝟" : (root.volume > 50 ? "󰕾" : "󰖀")
        label: root.volume + "%"
        iconColor: root.muted ? colors.red : colors.lavender
        colors: root.colors
        onClicked: root.menuVisible = !root.menuVisible
    }

    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let visibleDummy = popup.visible
            let xDummy = root.x
            let targetX = root.mapToItem(null, 0, 0).x - (volMenu.implicitWidth - root.width) / 2
            return Math.max(6, Math.min(bar.width - volMenu.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height - 8
        implicitWidth: volMenu.implicitWidth
        implicitHeight: volMenu.implicitHeight + 40
        visible: root.menuVisible
        grabFocus: true
        onVisibleChanged: if (!visible) root.menuVisible = false
        color: "transparent"
        
        VolumeMenu {
            id: volMenu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            volume: root.volume
            muted: root.muted
            menuVisible: root.menuVisible
        }
    }
}
