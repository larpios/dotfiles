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
            let targetX = indicator.mapToItem(null, 0, 0).x - (popup.implicitWidth - indicator.width) / 2
            return Math.max(6, Math.min(bar.width - popup.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height + 4
        implicitWidth: volMenu.implicitWidth
        implicitHeight: volMenu.implicitHeight
        visible: root.menuVisible
        color: "transparent"
        
        VolumeMenu {
            id: volMenu
            colors: root.colors
            volume: root.volume
            muted: root.muted
        }
    }
}
