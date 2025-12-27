import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../widgets"
import "../generics"
import "../util"
//should fix the height here to be like wifi. This would let me go ahead and make some of the options collapsible.
Item{
    id: bluetoothConfig 

    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property BluetoothDevice firstActiveDevice: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null
    readonly property int activeDeviceCount: Bluetooth.defaultAdapter?.devices.values.filter(device => device.connected).length ?? 0
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)
    

    property var listNameMap: {
        0: "Connected",
        1: "Paired",
        2: "Unpaired"
    }
    

    function sortFunction(a, b) {
        // Ones with meaningful names before MAC addresses
        const macRegex = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
        const aIsMac = macRegex.test(a.name);
        const bIsMac = macRegex.test(b.name);
        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1;

        // Alphabetical by name
        return a.name.localeCompare(b.name);
    }

    function getMaxSize(size){
        return size <= (10*25) ? size : (10*25)
    }
    
    
    property list<var> connectedDevices: Bluetooth.devices.values.filter(d => d.connected).sort(sortFunction)
    property list<var> pairedButNotConnectedDevices: Bluetooth.devices.values.filter(d => d.paired && !d.connected).sort(sortFunction)
    property list<var> unpairedDevices: Bluetooth.devices.values.filter(d => !d.paired && !d.connected).sort(sortFunction)
    property list<var> friendlyDeviceList: [connectedDevices, pairedButNotConnectedDevices,unpairedDevices]

    property var connectedVisibility: true
    property var pairedVisibility: true
    property var unPairedVisibility: true


    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    Column {
        id: content
        spacing: 10
        width: childrenRect.width
        height: childrenRect.height

        Text { 
            text: "Bluetooth"
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true 
            style: Text.Outline
            styleColor: textBorderColor
        }
        Repeater {
            id: deviceCategory
            model: friendlyDeviceList

            width: childrenRect.width
            height: childrenRect.height

            Column {
        
                property list<var> deviceList: modelData
                property int categoryIndex : index

                width: childrenRect.width
                height: childrenRect.height

                spacing: 5

                Text {
                    text: listNameMap[index] + " : " + modelData.length
                    color: fontColor
                    font.family: fontFamily
                    font.pixelSize: 15
                    font.bold:true
                    //style: Text.Outline
                    //styleColor: textBorderColor
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            if(bluetoothFlickable.isVisible == true){
                                bluetoothFlickable.isVisible = false
                                bluetoothFlickable.height= 0
                            }
                            else {
                                bluetoothFlickable.isVisible = true
                                bluetoothFlickable.height = bluetoothConfig.getMaxSize(modelData.length*25)
                            }
                        }
                    }

                }
                Flickable {
                    id: bluetoothFlickable
                    property var isVisible: true //need to figure out a way to maintain state when this reloads

                    width: 400
                    height: bluetoothConfig.getMaxSize(modelData.length*25)

                    clip: true
                    visible: isVisible

                    contentWidth: width
                    contentHeight: contentItem.childrenRect.height +modelData.length
                    Column{
                        id: devicesColumn
                        spacing: 5
                        width: childrenRect.width
                        height: childrenRect.height

                        Repeater {
                            id: deviceRepeater

                            model: deviceList

                            width: childrenRect.width
                            height: childrenRect.height

                            Row{
                                id: deviceRow

                                width: 400
                                spacing: 5
                                property var device: modelData

                                height: 20

                                Text {
                                    text: device.name
                                    width: 200
                                    font.family: fontFamily
                                }
                                PopupButton {
                                    height: deviceRow.height
                                    visible: listNameMap[categoryIndex] == "Connected"
                                    
                                    text: "disconnect"
                                    onClicked: {
                                        device.disconnect()
                                    }
                                }
                                PopupButton {
                                    height: deviceRow.height
                                    visible: listNameMap[categoryIndex] == "Paired" 
                                    text: "connect"
                                    onClicked: {
                                        device.connect()
                                    }
                                }
                                PopupButton {
                                    height: deviceRow.height
                                    visible: listNameMap[categoryIndex] == "Paired" 
                                    text: "forget"
                                    onClicked: {
                                        device.forget()
                                    }
                                }
                                PopupButton {
                                    height: deviceRow.height
                                    visible: listNameMap[categoryIndex] == "Unpaired" 
                                    text: "pair"
                                    clip:true
                                    onClicked: {
                                        device.pair()
                                    }
                                }
                                PopupButton {
                                    height: deviceRow.height
                                    visible: device.trusted == false 
                                    text: "trust"
                                    clip:true
                                    onClicked: {
                                        device.trusted=true
                                    }
                                }

                                
                            }
                        }

                    }
                }

            }
            
            
            
        }
    }


    Component.onCompleted: {
        if(Bluetooth.defaultAdapter){
            Bluetooth.defaultAdapter.discovering = true
            Bluetooth.defaultAdapter.pairable = true
        }
    }
    Component.onDestruction: {
        if(Bluetooth.defaultAdapter){
            Bluetooth.defaultAdapter.pairable = false
            Bluetooth.defaultAdapter.discovering = false 
        }
    }
    
}