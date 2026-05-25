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

    implicitWidth: layout.implicitWidth
    implicitHeight: 26
    Layout.alignment: Qt.AlignVCenter

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6
        Text {
            id: iconText
            color: indicator.iconColor
            font.pixelSize: 14
        }
        Text {
            id: labelText
            color: indicator.colors.subtext1 || "#bac2de"
            font.pixelSize: 11
            font.bold: true
            visible: indicator.labelVisible && text !== ""
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: indicator.clicked()
    }
}
