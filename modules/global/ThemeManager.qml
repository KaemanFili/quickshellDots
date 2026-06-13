pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // Path to JSON file
    property string path: Qt.resolvedUrl("../../config/themes.json")
    property string repoPath: localPath(Qt.resolvedUrl("../.."))
    property string userHome: stripTrailingSlash(String(Quickshell.env("QUICKSHELL_HOME") || Quickshell.env("HOME") || ""))
    property string wallpaperSetterPath: root.repoPath + "/scripts/set-wallpaper"
    property string rofiThemeSetterPath: root.repoPath + "/scripts/set-rofi-theme"
    property string rofiConfigPath: userHome ? userHome + "/.config/rofi/config.rasi" : ""
    property string defaultThemeName: "BMO"

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
        wallpaperPath: "wallpapers/retro-BMO.jpg",
        rofiThemePath: "rofi/themes/quickshell-BMO.rasi"
    })
    function localPath(url) {
        const path = String(url)

        if (path.startsWith("file://"))
            return decodeURIComponent(path.slice("file://".length))

        return path
    }
    function stripTrailingSlash(path) {
        return path.endsWith("/") ? path.slice(0, -1) : path
    }
    function resolveRepoPath(path) {
        if (!path || path.startsWith("/") || path.includes("://"))
            return path

        const base = root.repoPath.endsWith("/") ? root.repoPath.slice(0, -1) : root.repoPath
        const relativePath = path.startsWith("./") ? path.slice(2) : path

        return base + "/" + relativePath
    }
    function setCurTheme(name){
        //console.log("setting current theme of: "+ name)
        const themeName = root.map[name] ? name : root.defaultThemeName
        const themeData = theme(themeName)

        root.curTheme = themeName
        setWallpaper(themeData)
        setRofiTheme(themeName, themeData)
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
    function setWallpaper(themeData) {
        const wallpaperPath = themeData.wallpaperPath || root.defaultTheme.wallpaperPath

        if (!wallpaperPath)
            return

        wallpaperSetter.exec([root.wallpaperSetterPath, resolveRepoPath(wallpaperPath)])
    }
    function rofiThemePath(name, themeData) {
        const themePath = themeData.rofiThemePath || ("rofi/themes/quickshell-" + name + ".rasi")
        return resolveRepoPath(themePath)
    }
    function setRofiTheme(name, themeData) {
        if (!root.rofiConfigPath)
            return

        rofiThemeSetter.exec([root.rofiThemeSetterPath, root.rofiConfigPath, rofiThemePath(name, themeData)])
    }
    function alterColor(colorString, amount = 0.8) {
        const c = Qt.color(colorString)
        const v = Math.max(0, Math.min(1, c.hsvValue * amount))
        return Qt.hsva(c.hsvHue, c.hsvSaturation, v, c.a)
    }

    Process {
        id: wallpaperSetter

        stderr: StdioCollector {
            onStreamFinished: {
                const err = text.trim()
                if (err.length)
                    console.error("ThemeManager: failed to set wallpaper:", err)
            }
        }
    }

    Process {
        id: rofiThemeSetter

        stderr: StdioCollector {
            onStreamFinished: {
                const err = text.trim()
                if (err.length)
                    console.error("ThemeManager: failed to set rofi theme:", err)
            }
        }
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
