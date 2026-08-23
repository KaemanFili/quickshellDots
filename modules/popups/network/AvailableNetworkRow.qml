import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../generics"

ColumnLayout {
    id: row
    required property var network
    property int rowHeight: 28
    property string fontName: "sans-serif"
    property color labelColor: "white"
    property color fieldColor: "gray"
    property bool enteringPassword: false
    readonly property bool isOpen: network.security === "--" || network.security.trim() === ""
    signal connectRequested(string password)

    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: row.network.ssid
            color: row.labelColor
            font.family: row.fontName
            elide: Text.ElideRight
        }
        Text {
            Layout.preferredWidth: 64
            text: row.isOpen ? "Open" : row.network.security
            color: row.labelColor
            font.family: row.fontName
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
        Text {
            Layout.preferredWidth: 42
            text: row.network.bars
            color: row.labelColor
            font.family: row.fontName
            horizontalAlignment: Text.AlignHCenter
        }
        PopupButton {
            Layout.preferredWidth: 82
            Layout.preferredHeight: row.rowHeight
            text: "Connect"
            visible: !row.enteringPassword
            onClicked: {
                if (row.isOpen)
                    row.connectRequested("")
                else
                    row.enteringPassword = true
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: row.enteringPassword
        spacing: 6

        TextField {
            id: passwordInput
            Layout.fillWidth: true
            Layout.preferredHeight: row.rowHeight
            placeholderText: "Password for " + row.network.ssid
            echoMode: TextInput.Password
            font.family: row.fontName
            color: row.labelColor
            selectByMouse: true
            background: Rectangle {
                radius: 8
                color: row.fieldColor
            }
            onVisibleChanged: {
                if (visible)
                    forceActiveFocus()
            }
            onAccepted: join()

            function join() {
                if (text.length === 0)
                    return
                row.connectRequested(text)
                clear()
                row.enteringPassword = false
            }
        }
        PopupButton {
            Layout.preferredWidth: 62
            Layout.preferredHeight: row.rowHeight
            text: "Join"
            onClicked: passwordInput.join()
        }
        PopupButton {
            Layout.preferredWidth: 62
            Layout.preferredHeight: row.rowHeight
            text: "Cancel"
            onClicked: {
                passwordInput.clear()
                row.enteringPassword = false
            }
        }
    }
}
