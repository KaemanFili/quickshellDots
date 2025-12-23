import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../global"
import "../generics"
import "../util"
//could probably make the two types of saved connections load at the same time.
//should give option to forget connection
Item{
    id: networkConfig 

    implicitWidth:  childrenRect.width
    implicitHeight: childrenRect.height

    function getConnectionType(type){
        if(type.includes("wireless")){
            return "wifi"
        }
        if(type.includes("ethernet")){
            return "ethernet"
        }
        else{
            return "unknown"
        }
    }

    IconsMap {
        id: iconsMap
    }
    Column {
        id: content
        spacing: 8
        width: childrenRect.width
        height: childrenRect.height

        Text {
            text: "Network"; 
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true 
            style: Text.Outline
            styleColor: textBorderColor
        }
        // ...rest of popup...
        Text{
            text: "Saved Connections:"
            color: fontColor
            font.family: fontFamily
            font.pixelSize: 15
            font.bold:true
        }
        Repeater {
            id:  repeater
            model: NetworkManager.activeConnections
            width: childrenRect.width
            height: childrenRect.height

            RowLayout {
                width: 400
                spacing: 8


                Text {
                    property var symbolType : networkConfig.getConnectionType(modelData.type)

                    text: modelData.name + " " + iconsMap.map[symbolType]

                }
                Item{ Layout.fillWidth: true}
                PopupButton{
                    height: 3
                    text: "Disconnect"
                    onClicked: {
                        NetworkManager.changeConnection(modelData) 
                        NetworkManager.refresh()
                    }
                }
            }
        }
        Repeater {
            id:  repeater2
            model: NetworkManager.inactiveConnections
            width: childrenRect.width
            height: childrenRect.height

            RowLayout {
                width: 400
                spacing: 8
                Text {
                    property var symbolType : networkConfig.getConnectionType(modelData.type)
                    text: modelData.name + " " + iconsMap.map[symbolType]
                    color: tertiaryColor
                }
                Item{ Layout.fillWidth: true}
                PopupButton{
                    height: 3
                    text: "Connect"
                    onClicked: {
                        NetworkManager.changeConnection(modelData) 
                        NetworkManager.refresh()
                    }
                }
            }
        }
        Text{
            id: wifiTitle
            text: "Wifi:"
            color: fontColor
            font.family: fontFamily
            font.pixelSize: 15
            font.bold:true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: {
                    if(wifiFlickable.isVisible == true){
                        wifiFlickable.isVisible = false
                        wifiFlickable.height= 0
                    }
                    else {
                        wifiFlickable.isVisible = true
                        wifiFlickable.height = NetworkManager.availableNetworks.length === 0 ? 20 : (NetworkManager.availableNetworks.length)*20
                    }

                }
            }
        }
        Flickable {
            id: wifiFlickable

            property var isVisible: true

            width:  400
            height: NetworkManager.availableNetworks.length === 0 ? 20 : (NetworkManager.availableNetworks.length)*20
            clip: true
            visible: isVisible
            contentWidth: width
            contentHeight: contentItem.childrenRect.height +NetworkManager.availableNetworks.length
            
            Column{
                id: flickableColumn
                spacing: 8
                width: childrenRect.width
                height: childrenRect.height

                Repeater {
                    model: NetworkManager.availableNetworks
                    width: childrenRect.width
                    height: childrenRect.height
                    
                    RowLayout {
                        width: 400
                        spacing: 8

                        id: availableNetworksRow

                        property var showPasswordBox: false

                        visible: !modelData.inUse

                        Text { text: modelData.ssid }
                        Text { text: modelData.security === "--" ? "Open" : modelData.security }
                        Text { text: modelData.bars }
                        Item{ Layout.fillWidth: true}
                        PopupButton {
                            height: 3
                            text: "Connect"
                            visible: !availableNetworksRow.showPasswordBox
                            enabled: !modelData.inUse
                            onClicked: (m) => {
                                availableNetworksRow.showPasswordBox = true 
                            }
                            
                            //onClicked: NetworkManager.changeConnection(modelData) need to figure out connection flow here
                        }
                        TextField {
                            id: passwordInput
                            width: 50
                            placeholderText: "Enter password"
                            visible: availableNetworksRow.showPasswordBox
                            focus: true
                             onVisibleChanged: {
                            if (visible)
                                passwordInput.forceActiveFocus()
                            }
                            onAccepted: {
                                availableNetworksRow.showPasswordBox = false
                                NetworkManager.connectToNewNetwork(modelData.ssid,displayText)
                                NetworkManager.refresh()
                                clear()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}