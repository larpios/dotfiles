import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property alias text: text1.text
    property alias color: text1.color
    property alias font: text1.font
    property alias horizontalAlignment: text1.horizontalAlignment
    property int speed: 30 // Pixels per second
    property int delay: 2000 // Pause duration at start
    property int spacing: 50 // Space between loops
    
    height: text1.implicitHeight
    clip: true

    Item {
        id: container
        anchors.fill: parent
        layer.enabled: text1.implicitWidth > root.width
        layer.effect: OpacityMask {
            maskSource: LinearGradient {
                width: root.width
                height: root.height
                start: Qt.point(0, 0)
                end: Qt.point(root.width, 0)
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: scrollContent.scrollX >= 0 ? "white" : "transparent" 
                    }
                    GradientStop { position: 0.05; color: "white" }
                    GradientStop { position: 0.95; color: "white" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        Item {
            id: scrollContent
            width: text1.implicitWidth + root.spacing + text2.implicitWidth
            height: parent.height
            x: (horizontalAlignment === Text.AlignHCenter && text1.implicitWidth <= root.width) 
               ? (root.width - text1.implicitWidth) / 2 
               : scrollX
            
            property real scrollX: 0

            Text {
                id: text1
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: text2
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: text1.right
                anchors.leftMargin: root.spacing
                text: text1.text
                color: text1.color
                font: text1.font
                visible: text1.implicitWidth > root.width
            }
        }
    }

    SequentialAnimation {
        id: marqueeAnimation
        running: text1.implicitWidth > root.width
        loops: Animation.Infinite

        PauseAnimation { duration: root.delay }
        NumberAnimation {
            target: scrollContent
            property: "scrollX"
            from: 0
            to: -(text1.implicitWidth + root.spacing)
            duration: Math.max(0, (text1.implicitWidth + root.spacing) * (1000 / root.speed))
            easing.type: Easing.Linear
        }
    }
    
    // Reset position if text changes and fits
    onWidthChanged: if (text1.implicitWidth <= width) scrollContent.scrollX = 0
    onTextChanged: if (text1.implicitWidth <= width) scrollContent.scrollX = 0
}
