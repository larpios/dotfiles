import QtQuick
import QtQuick.Layouts

Item {
    id: indicator
    property alias icon: iconText.text
    property alias label: labelText.text
    property color iconColor: "white"
    property bool labelVisible: true
    property var colors: ({})
    signal clicked()

    property bool hovered: false

    implicitWidth: bg.width
    implicitHeight: 28
    Layout.alignment: Qt.AlignVCenter

    Rectangle {
        id: bg
        width: layout.implicitWidth + 12
        height: parent.implicitHeight
        radius: 6
        color: indicator.hovered ? colors.surface0 : "transparent"
        border.color: indicator.hovered ? colors.surface1 : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 6
            Text {
                id: iconText
                color: indicator.iconColor
                font.pixelSize: 13
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                id: labelText
                color: indicator.hovered ? colors.text : (indicator.colors.subtext1 || "#bac2de")
                font.pixelSize: 11
                font.bold: true
                visible: indicator.labelVisible && text !== ""
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: indicator.hovered = true
        onExited: indicator.hovered = false
        onClicked: indicator.clicked()
    }
}
