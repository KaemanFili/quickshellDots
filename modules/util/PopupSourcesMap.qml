import QtQuick

QtObject {
     // Map popup names to QML file paths
    id: popupSources
    property var map: {
        "bluetooth" : "../popups/BluetoothConfig.qml",
        "audio" :     "../popups/AudioConfig.qml",
        "network" :   "../popups/NetworkConfig.qml"
        // add more as needed
    }
}
