pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // Path to JSON file
    property string path: Qt.resolvedUrl("../../config/themes.json")  

    property string curTheme: ""
    // The live map of themes (name -> object)
    property var map: ({})

    // Optional: a default theme if lookup fails
    property var defaultTheme: ({
        primaryColor: "#444444",
        secondaryColor: "#777777",
        tertiaryColor: '#c4c4c4',
        backgroundColor: "#222222",
        defaultTextColor: "#ffffff",
        textBorderColor: "#000000",
        fontStyle: "Gohu Nerd Font",
        wallpaperPath: "/home/kaemy/.config/wallpapers/retro-BMO.jpg"
    })
    function setCurTheme(name){
        //console.log("setting current theme of: "+ name)
        root.curTheme = name
    }
    function getCurTheme(){
        return theme(root.curTheme)
    }
    function updateMap() {
        try {
            const text = file.text()
            root.map = text ? JSON.parse(text) : {}
        } catch (e) {
            console.error("ThemeStore: failed to parse JSON:", e)
            root.map = {}
        }
    }

    function theme(name) {
        //console.log("grabbing theme with name: "+ name)
        return root.map[name] || root.defaultTheme
    }
    function alterColor(colorString, amount = 0.8) {
        const c = Qt.color(colorString)
        const v = Math.max(0, Math.min(1, c.hsvValue * amount))
        return Qt.hsva(c.hsvHue, c.hsvSaturation, v, c.a)
    }

    FileView {
        id: file
        path: root.path

        //blockLoading: true

        watchChanges: true

        onFileChanged: reload()

        onLoaded: root.updateMap()

        onTextChanged: root.updateMap()

        onLoadFailed: {
            console.error("ThemeStore: failed to load theme file")
            root.map = {}
        }
        Component.onCompleted: reload()
    }
}