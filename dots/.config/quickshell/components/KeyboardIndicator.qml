import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    property var colors: ({})
    property var bar: null
    
    property string kbLayout: "EN"
    property var kbLayoutsList: []
    property bool menuVisible: false

    implicitWidth: indicator.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    // Keyboard Layout (fcitx5)
    Process {
        id: kbProcess
        command: ["sh", "-c", "fcitx5-remote -n"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                let layout = data.trim()
                if (layout.startsWith("keyboard-")) {
                    root.kbLayout = layout.replace("keyboard-", "").substring(0, 2).toUpperCase()
                } else if (layout === "pinyin" || layout === "rime") {
                    root.kbLayout = "中"
                } else if (layout === "hangul") { 
                    root.kbLayout = "한"
                } else if (layout === "mozc" || layout === "mozc") { 
                    root.kbLayout = "日"
                } else if (layout.length > 0) {
                    root.kbLayout = layout.substring(0, 2).toUpperCase()
                } else {
                    root.kbLayout = "EN"
                }
            }
        }
    }

    // Keyboard layouts list
    Process {
        id: kbListProcess
        command: ["sh", "-c", "grep -E '^Name=' ~/.config/fcitx5/profile 2>/dev/null | cut -d= -f2 | grep -E '^(keyboard-|pinyin|mozc|hangul|anthy|bopomofo|chewing|rime)'"]
        running: false
        property string _buffer: ""
        onRunningChanged: {
            if (running) {
                _buffer = "";
            } else if (_buffer.length > 0) {
                let lines = _buffer.trim().split('\n');
                let layouts = [];
                for (let i = 0; i < lines.length; i++) {
                    if (!lines[i]) continue;
                    let name = lines[i];
                    let disp = name;
                    if (name.startsWith("keyboard-")) {
                        disp = name.replace("keyboard-", "").substring(0, 2).toUpperCase();
                    } else if (name === "pinyin") {
                        disp = "中";
                    } else {
                        disp = name.substring(0, 2).toUpperCase();
                    }
                    layouts.push({ id: name, display: disp });
                }
                root.kbLayoutsList = layouts;
            }
        }
        stdout: SplitParser {
            onRead: (data) => kbListProcess._buffer += data + "\n"
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: kbProcess.running = true
    }

    StatusIndicator {
        id: indicator
        icon: "󰌌"
        label: root.kbLayout
        iconColor: colors.lavender
        colors: root.colors
        onClicked: {
            kbListProcess.running = false
            kbListProcess.running = true
            root.menuVisible = !root.menuVisible
        }
    }

    PopupWindow {
        id: popup
        anchor.window: bar
        anchor.rect.x: {
            let visibleDummy = popup.visible
            let xDummy = root.x
            let targetX = root.mapToItem(null, 0, 0).x - (kbMenu.implicitWidth - root.width) / 2
            return Math.max(6, Math.min(bar.width - kbMenu.implicitWidth - 6, targetX))
        }
        anchor.rect.y: bar.height - 8
        implicitWidth: kbMenu.implicitWidth
        implicitHeight: kbMenu.implicitHeight + 40
        visible: root.menuVisible
        color: "transparent"
        
        KeyboardMenu {
            id: kbMenu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            kbLayoutsList: root.kbLayoutsList
            kbMenuVisible: root.menuVisible
            onKbMenuVisibleChanged: root.menuVisible = kbMenuVisible
        }
    }
}
