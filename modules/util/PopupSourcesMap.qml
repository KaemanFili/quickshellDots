import QtQuick

QtObject {
     // Map popup names to QML file paths
    id: popupSources
    property var map: {
        "systemStats" : "../popups/SystemStatsConfig.qml",
        "bluetooth" : "../popups/bluetooth/BluetoothConfig.qml",
        "audio" :     "../popups/AudioConfig.qml",
        "network" :   "../popups/network/NetworkConfig.qml",
        "themeChanger" : "../popups/ThemeChangerConfig.qml",
        "calendar" : "../popups/CalendarConfig.qml"
        // add more as needed
    }
}
