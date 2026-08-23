import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: section
    default property alias sectionContent: body.data

    property string title: ""
    property int count: 0
    property color titleColor: "white"
    property string fontName: "sans-serif"
    property bool expanded: true

    spacing: 6

    Item {
        Layout.fillWidth: true
        implicitHeight: header.implicitHeight

        RowLayout {
            id: header
            anchors.fill: parent
            spacing: 6

            Text {
                text: section.expanded ? "▾" : "▸"
                color: section.titleColor
                font.family: section.fontName
                font.pixelSize: 13
            }
            Text {
                Layout.fillWidth: true
                text: section.title + " (" + section.count + ")"
                color: section.titleColor
                font.family: section.fontName
                font.pixelSize: 15
                font.bold: true
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: section.expanded = !section.expanded
        }
    }

    Column {
        id: body
        Layout.fillWidth: true
        visible: section.expanded
        spacing: 6
    }
}
