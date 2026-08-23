import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import "." as PopupComponents
import "../../generics" as Generics

Item {
    id: bluetoothConfig

    readonly property int popupWidth: 400
    readonly property int rowHeight: 28
    readonly property int maximumListHeight: 250
    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false

    property list<var> connectedDevices: Bluetooth.devices.values
        .filter(device => device.connected).sort(sortDevices)
    property list<var> pairedDevices: Bluetooth.devices.values
        .filter(device => device.paired && !device.connected).sort(sortDevices)
    property list<var> unpairedDevices: Bluetooth.devices.values
        .filter(device => !device.paired && !device.connected).sort(sortDevices)

    implicitWidth: popupWidth
    implicitHeight: content.implicitHeight

    function sortDevices(a, b) {
        const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/
        const aIsMac = macRegex.test(a.name)
        const bIsMac = macRegex.test(b.name)
        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1
        return a.name.localeCompare(b.name)
    }

    ColumnLayout {
        id: content
        width: bluetoothConfig.popupWidth
        spacing: 10

        Text {
            text: "Bluetooth"
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true
            style: Text.Outline
            styleColor: textBorderColor
        }

        Text {
            visible: !bluetoothConfig.available
            text: "No Bluetooth adapter found"
            color: tertiaryColor
            font.family: fontFamily
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Connected"
            count: bluetoothConfig.connectedDevices.length
            titleColor: fontColor
            fontName: fontFamily

            ListView {
                width: bluetoothConfig.popupWidth
                implicitHeight: Math.min(contentHeight, bluetoothConfig.maximumListHeight)
                height: implicitHeight
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: bluetoothConfig.connectedDevices
                delegate: PopupComponents.BluetoothDeviceRow {
                    required property var modelData
                    width: ListView.view.width
                    device: modelData
                    category: "connected"
                    rowHeight: bluetoothConfig.rowHeight
                    fontName: fontFamily
                    labelColor: textBorderColor
                }
            }
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Paired"
            count: bluetoothConfig.pairedDevices.length
            titleColor: fontColor
            fontName: fontFamily

            ListView {
                width: bluetoothConfig.popupWidth
                implicitHeight: Math.min(contentHeight, bluetoothConfig.maximumListHeight)
                height: implicitHeight
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: bluetoothConfig.pairedDevices
                delegate: PopupComponents.BluetoothDeviceRow {
                    required property var modelData
                    width: ListView.view.width
                    device: modelData
                    category: "paired"
                    rowHeight: bluetoothConfig.rowHeight
                    fontName: fontFamily
                    labelColor: textBorderColor
                }
            }
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Unpaired"
            count: bluetoothConfig.unpairedDevices.length
            titleColor: fontColor
            fontName: fontFamily

            ListView {
                width: bluetoothConfig.popupWidth
                implicitHeight: Math.min(contentHeight, bluetoothConfig.maximumListHeight)
                height: implicitHeight
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: bluetoothConfig.unpairedDevices
                delegate: PopupComponents.BluetoothDeviceRow {
                    required property var modelData
                    width: ListView.view.width
                    device: modelData
                    category: "unpaired"
                    rowHeight: bluetoothConfig.rowHeight
                    fontName: fontFamily
                    labelColor: textBorderColor
                }
            }
        }
    }

    Component.onCompleted: {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.discovering = true
            Bluetooth.defaultAdapter.pairable = true
        }
    }

    Component.onDestruction: {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.pairable = false
            Bluetooth.defaultAdapter.discovering = false
        }
    }
}
