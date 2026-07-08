import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: volMenuContent
    property var colors: ({})
    property bool menuVisible: false
    
    transform: Scale {
        id: menuScale
        origin.x: volMenuContent.width / 2
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
    
    onMenuVisibleChanged: {
        if (menuVisible) {
            scaleInAnim.start();
        } else {
            scaleInAnim.stop();
            menuScale.yScale = 0.0;
        }
    }
    
    Component.onCompleted: {
        if (menuVisible) {
            scaleInAnim.start();
        }
    }
    
    // Default system values
    property int volume: 0
    property bool muted: false
    
    implicitWidth: 320
    implicitHeight: 400
    color: "transparent"
    border.width: 0
    
    MenuBackground {
        colors: volMenuContent.colors
    }
    
    // State
    property string activeTab: "outputs" // "outputs" or "inputs"
    
    // Declaratively filter outputs and inputs
    property var audioOutputs: {
        let list = [];
        let all = Pipewire.nodes.values;
        for (let i = 0; i < all.length; i++) {
            let node = all[i];
            if (node.properties["media.class"] === "Audio/Sink") {
                list.push(node);
            }
        }
        return list;
    }

    property var audioInputs: {
        let list = [];
        let all = Pipewire.nodes.values;
        for (let i = 0; i < all.length; i++) {
            let node = all[i];
            if (node.properties["media.class"] === "Audio/Source") {
                list.push(node);
            }
        }
        return list;
    }
    
    // PwObjectTracker to keep node properties synced (tracks all nodes to populate media.class)
    PwObjectTracker {
        id: deviceTracker
        objects: Pipewire.nodes.values
    }
    
    // Peak Monitors for active default devices
    PwNodePeakMonitor {
        id: sinkPeakMonitor
        node: Pipewire.defaultAudioSink
        enabled: volMenuContent.menuVisible && activeTab === "outputs"
    }
    
    PwNodePeakMonitor {
        id: sourcePeakMonitor
        node: Pipewire.defaultAudioSource
        enabled: volMenuContent.menuVisible && activeTab === "inputs"
    }
    
    // Helpers to get current active values
    readonly property var activeNode: activeTab === "outputs" ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    readonly property int activeVolume: activeNode ? Math.round(activeNode.audio.volume * 100) : 0
    readonly property bool activeMuted: activeNode ? activeNode.audio.muted : false
    readonly property var activePeakMonitor: activeTab === "outputs" ? sinkPeakMonitor : sourcePeakMonitor
    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 15 + 12
        anchors.rightMargin: 15 + 12
        anchors.topMargin: 15 + 12
        anchors.bottomMargin: 15
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 20
            
            Text {
                text: activeTab === "outputs" ? "󰓃" : "󰍬"
                color: colors.mauve
                font.pixelSize: 18
            }
            Text {
                text: activeTab === "outputs" ? "Output Settings" : "Input Settings"
                color: colors.text
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
            }
        }
        
        // Tab Switcher (Outputs / Inputs)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 32
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: activeTab === "outputs" ? colors.surface0 : "transparent"
                border.color: activeTab === "outputs" ? colors.mauve : "transparent"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Outputs"
                    color: activeTab === "outputs" ? colors.mauve : colors.subtext1
                    font.bold: activeTab === "outputs"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: activeTab = "outputs"
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: activeTab === "inputs" ? colors.surface0 : "transparent"
                border.color: activeTab === "inputs" ? colors.mauve : "transparent"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Inputs"
                    color: activeTab === "inputs" ? colors.mauve : colors.subtext1
                    font.bold: activeTab === "inputs"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: activeTab = "inputs"
                }
            }
        }
        
        // Active/Default device volume section
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 52
            spacing: 6
            
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: activeNode ? (activeNode.description || activeNode.name) : "No Device"
                    color: colors.text
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: activeMuted ? "Muted" : (activeVolume + "%")
                    color: colors.subtext1
                    font.pixelSize: 10
                }
            }
            
            // Slider with Peak Meter
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                // Mute toggle button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: activeMuted ? colors.red : colors.surface0
                    Text {
                        anchors.centerIn: parent
                        text: activeTab === "outputs" 
                            ? (activeMuted ? "󰝟" : "󰕾") 
                            : (activeMuted ? "󰍭" : "󰍬")
                        color: activeMuted ? colors.crust : colors.text
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (activeNode) {
                                activeNode.audio.muted = !activeNode.audio.muted
                            }
                        }
                    }
                }
                
                Rectangle {
                    id: mainSliderTrack
                    Layout.fillWidth: true
                    height: 16
                    radius: 8
                    color: colors.surface0
                    clip: true
                    
                    // Peak monitor overlay (bouncing level meter)
                    Rectangle {
                        height: parent.height
                        width: parent.width * (activePeakMonitor ? activePeakMonitor.peak : 0)
                        color: colors.teal
                        opacity: 0.15
                        Behavior on width {
                            NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
                        }
                    }
                    
                    Rectangle {
                        width: Math.max(0, Math.min(parent.width, (activeVolume / 100) * parent.width))
                        height: parent.height
                        radius: 8
                        color: activeMuted ? colors.overlay1 : colors.mauve
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: activeMuted ? "MUTED" : (activeVolume + "%")
                        color: activeMuted ? colors.text : colors.crust
                        font.bold: true
                        font.pixelSize: 10
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        function updateVol(mouse) {
                            let val = Math.max(0, Math.min(1, mouse.x / parent.width))
                            if (activeNode) {
                                activeNode.audio.volume = val
                            }
                        }
                        onPressed: updateVol(mouse)
                        onPositionChanged: updateVol(mouse)
                    }
                }
            }
        }
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 1
            color: colors.surface1
        }
        
        // Device List Header
        Text {
            text: "Select Device"
            color: colors.subtext1
            font.bold: true
            font.pixelSize: 10
            Layout.fillWidth: true
            Layout.fillHeight: false
        }
        
        // Scrollable list of devices
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: listLayout.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            
            Column {
                id: listLayout
                width: parent.width
                spacing: 8
                
                Repeater {
                    model: activeTab === "outputs" ? audioOutputs : audioInputs
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 48
                        radius: 8
                        color: isDefault ? colors.surface0 : "transparent"
                        border.color: isDefault ? colors.surface1 : "transparent"
                        border.width: 1
                        
                        readonly property bool isDefault: activeTab === "outputs" 
                            ? Pipewire.defaultAudioSink === modelData
                            : Pipewire.defaultAudioSource === modelData
                            
                        readonly property int devVolume: modelData.audio ? Math.round(modelData.audio.volume * 100) : 0
                        readonly property bool devMuted: modelData.audio ? modelData.audio.muted : false
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            // Check / radio button
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: isDefault ? colors.mauve : "transparent"
                                border.color: colors.mauve
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰄬"
                                    font.pixelSize: 10
                                    color: colors.crust
                                    visible: isDefault
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: selectAsDefault()
                                }
                            }
                            
                            // Middle: details + slider
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Text {
                                        text: modelData.description || modelData.name
                                        color: colors.text
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: selectAsDefault()
                                        }
                                    }
                                    Text {
                                        text: devMuted ? "Muted" : (devVolume + "%")
                                        color: colors.subtext1
                                        font.pixelSize: 10
                                    }
                                }
                                
                                // Individual device volume slider
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 8
                                    radius: 4
                                    color: colors.surface1
                                    clip: true
                                    
                                    Rectangle {
                                        width: Math.max(0, Math.min(parent.width, (devVolume / 100) * parent.width))
                                        height: parent.height
                                        radius: 4
                                        color: devMuted ? colors.overlay1 : colors.sky
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        function updateDevVol(mouse) {
                                            let val = Math.max(0, Math.min(1, mouse.x / parent.width))
                                            if (modelData.audio) {
                                                modelData.audio.volume = val
                                            }
                                        }
                                        onPressed: updateDevVol(mouse)
                                        onPositionChanged: updateDevVol(mouse)
                                    }
                                }
                            }
                            
                            // Right: Mute toggle
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 4
                                color: devMuted ? colors.red : colors.surface0
                                Text {
                                    anchors.centerIn: parent
                                    text: activeTab === "outputs" 
                                        ? (devMuted ? "󰝟" : "󰕾") 
                                        : (devMuted ? "󰍭" : "󰍬")
                                    color: devMuted ? colors.crust : colors.text
                                    font.pixelSize: 11
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.audio) {
                                            modelData.audio.muted = !modelData.audio.muted
                                        }
                                    }
                                }
                            }
                        }
                        
                        function selectAsDefault() {
                            if (activeTab === "outputs") {
                                Pipewire.preferredDefaultAudioSink = modelData
                            } else {
                                Pipewire.preferredDefaultAudioSource = modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
