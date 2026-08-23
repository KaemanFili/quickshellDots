import QtQuick
import QtQuick.Layouts
import "../../global"
import "../../util"
import "." as PopupComponents
import "../../generics" as Generics

Item {
    id: networkConfig

    readonly property int popupWidth: 400
    readonly property int rowHeight: 28
    readonly property int maximumListHeight: 250

    implicitWidth: popupWidth
    implicitHeight: content.implicitHeight

    function connectionIcon(type) {
        if (type.includes("wireless"))
            return iconsMap.map.wifi
        if (type.includes("ethernet"))
            return iconsMap.map.ethernet
        return iconsMap.map.unknown
    }

    IconsMap { id: iconsMap }

    ColumnLayout {
        id: content
        width: networkConfig.popupWidth
        spacing: 10

        Text {
            text: "Network"
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true
            style: Text.Outline
            styleColor: textBorderColor
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Connected"
            count: NetworkManager.activeConnections.length
            titleColor: fontColor
            fontName: fontFamily

            Repeater {
                model: NetworkManager.activeConnections
                PopupComponents.NetworkConnectionRow {
                    required property var modelData
                    width: networkConfig.popupWidth
                    connection: modelData
                    icon: networkConfig.connectionIcon(modelData.type)
                    connected: true
                    rowHeight: networkConfig.rowHeight
                    fontName: fontFamily
                    labelColor: textBorderColor
                    onActionRequested: {
                        NetworkManager.changeConnection(connection)
                        NetworkManager.refresh()
                    }
                }
            }
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Saved"
            count: NetworkManager.inactiveConnections.length
            titleColor: fontColor
            fontName: fontFamily

            Repeater {
                model: NetworkManager.inactiveConnections
                PopupComponents.NetworkConnectionRow {
                    required property var modelData
                    width: networkConfig.popupWidth
                    connection: modelData
                    icon: networkConfig.connectionIcon(modelData.type)
                    connected: false
                    rowHeight: networkConfig.rowHeight
                    fontName: fontFamily
                    labelColor: tertiaryColor
                    onActionRequested: {
                        NetworkManager.changeConnection(connection)
                        NetworkManager.refresh()
                    }
                }
            }
        }

        Generics.PopupSection {
            Layout.fillWidth: true
            title: "Available Networks"
            count: availableNetworks.count
            titleColor: fontColor
            fontName: fontFamily

            ListView {
                id: availableNetworks
                width: networkConfig.popupWidth
                implicitHeight: Math.min(contentHeight, networkConfig.maximumListHeight)
                height: implicitHeight
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: NetworkManager.availableNetworks.filter(network => !network.inUse)

                delegate: PopupComponents.AvailableNetworkRow {
                    required property var modelData
                    width: availableNetworks.width
                    network: modelData
                    rowHeight: networkConfig.rowHeight
                    fontName: fontFamily
                    labelColor: textBorderColor
                    fieldColor: primaryColor
                    onConnectRequested: password => NetworkManager.connectToNewNetwork(network.ssid, password)
                }

                Text {
                    anchors.centerIn: parent
                    visible: availableNetworks.count === 0
                    text: NetworkManager.scanning ? "Scanning…" : "No networks found"
                    color: tertiaryColor
                    font.family: fontFamily
                }
            }
        }
    }
}
