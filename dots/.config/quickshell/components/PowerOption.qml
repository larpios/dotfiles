import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: powerOption
    property string icon: ""
    property string label: ""
    property color optColor: "white"
    property var action: []
    property var colors: ({})
    
    signal triggered(var action)

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
        onClicked: powerOption.triggered(powerOption.action)
    }
}
