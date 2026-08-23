import QtQuick
import QtQuick.Layouts
import "../../generics"

RowLayout {
    id: row

    required property var device
    required property string category
    property int rowHeight: 28
    property string fontName: "sans-serif"
    property color labelColor: "white"

    height: rowHeight
    spacing: 6

    Text {
        Layout.fillWidth: true
        text: row.device.name
        color: row.labelColor
        font.family: row.fontName
        elide: Text.ElideRight
    }

    PopupButton {
        Layout.preferredWidth: 88
        Layout.preferredHeight: row.rowHeight
        visible: row.category === "connected"
        text: "Disconnect"
        onClicked: row.device.disconnect()
    }

    PopupButton {
        Layout.preferredWidth: 72
        Layout.preferredHeight: row.rowHeight
        visible: row.category === "paired"
        text: "Connect"
        onClicked: row.device.connect()
    }

    PopupButton {
        Layout.preferredWidth: 62
        Layout.preferredHeight: row.rowHeight
        visible: row.category === "paired"
        text: "Forget"
        onClicked: row.device.forget()
    }

    PopupButton {
        Layout.preferredWidth: 62
        Layout.preferredHeight: row.rowHeight
        visible: row.category === "unpaired"
        text: "Pair"
        onClicked: row.device.pair()
    }

    PopupButton {
        Layout.preferredWidth: 62
        Layout.preferredHeight: row.rowHeight
        visible: !row.device.trusted
        text: "Trust"
        onClicked: row.device.trusted = true
    }
}
