import QtQuick
import QtQuick.Layouts
import "../../generics"

RowLayout {
    id: row
    required property var connection
    property string icon: ""
    property bool connected: false
    property int rowHeight: 28
    property string fontName: "sans-serif"
    property color labelColor: "white"
    signal actionRequested()

    height: rowHeight
    spacing: 8

    Text {
        Layout.fillWidth: true
        text: row.connection.name
        color: row.labelColor
        font.family: row.fontName
        elide: Text.ElideRight
    }
    Text {
        Layout.preferredWidth: 24
        text: row.icon
        color: row.labelColor
        font.family: row.fontName
        horizontalAlignment: Text.AlignHCenter
    }
    PopupButton {
        Layout.preferredWidth: 96
        Layout.preferredHeight: row.rowHeight
        text: row.connected ? "Disconnect" : "Connect"
        onClicked: row.actionRequested()
    }
}
