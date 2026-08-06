pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    // Path to JSON file
    property string path: Qt.resolvedUrl("../../config/themes.json")
    property string statePath: Qt.resolvedUrl("../../config/theme-state.json")
    property string repoPath: localPath(Qt.resolvedUrl("../.."))
    property string userHome: stripTrailingSlash(String(Quickshell.env("QUICKSHELL_HOME") || Quickshell.env("HOME") || ""))
    property string wallpaperSetterPath: root.repoPath + "/scripts/set-wallpaper"
    property string rofiThemeSetterPath: root.repoPath + "/scripts/set-rofi-theme"
    property string kittyThemeSetterPath: root.repoPath + "/scripts/set-kitty-theme"
    property string sddmThemeSetterPath: root.repoPath + "/scripts/set-sddm-theme"
    property string sddmThemeConfigPath: root.repoPath + "/sddm/themes/simple/theme.conf"
    property string rofiConfigPath: userHome ? userHome + "/.config/rofi/config.rasi" : ""
    property string rofiThemePath: userHome ? userHome + "/.config/rofi/quickshell-current-theme.rasi" : ""
    property string kittyConfigPath: userHome ? userHome + "/.config/kitty/kitty.conf" : ""
    property string kittyThemePath: userHome ? userHome + "/.config/kitty/quickshell-current-theme.conf" : ""
    property string defaultThemeName: "BMO"

    property string curTheme: ""
    property bool themeMapReady: false
    property bool themeStateReady: false
    // The live map of themes (name -> object)
    property var map: ({})

    // Optional: a default theme if lookup fails
    property var defaultTheme: ({
        primaryColor: "#444444",
        secondaryColor: "#777777",
        tertiaryColor: '#c4c4c4',
        quaternaryColor: "#777777",
        backgroundColor: "#222222",
        defaultTextColor: "#ffffff",
        textBorderColor: "#000000",
        fontStyle: "Noto Sans",
        wallpaperPath: "wallpapers/retro-BMO.jpg",
        kittyBackgroundOpacity: "1.0"
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

        if (themeState.currentTheme !== themeName)
            themeState.currentTheme = themeName

        if (root.curTheme === themeName)
            return

        const themeData = theme(themeName)
        root.curTheme = themeName
        applyTheme(themeData)
    }
    function initializeTheme() {
        if (!root.themeMapReady || !root.themeStateReady)
            return

        setCurTheme(themeState.currentTheme)
    }
    function applyTheme(themeData) {
        setWallpaper(themeData)
        setRofiTheme(themeData)
        setKittyTheme(themeData)
        setSddmTheme(themeData)
    }
    function getCurTheme(){
        return theme(root.curTheme)
    }
    function updateMap() {
        try {
            const text = file.text()
            root.map = text ? JSON.parse(text) : {}
            if (root.curTheme !== "")
                applyTheme(theme(root.curTheme))
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
    function setRofiTheme(themeData) {
        if (!root.rofiConfigPath || !root.rofiThemePath)
            return

        rofiThemeSetter.exec(themeCommandArgs(root.rofiThemeSetterPath, root.rofiConfigPath, root.rofiThemePath, themeData))
    }
    function setKittyTheme(themeData) {
        if (!root.kittyConfigPath || !root.kittyThemePath)
            return

        kittyThemeSetter.exec(themeCommandArgs(root.kittyThemeSetterPath, root.kittyConfigPath, root.kittyThemePath, themeData))
    }
    function setSddmTheme(themeData) {
        sddmThemeSetter.exec([
            root.sddmThemeSetterPath,
            root.sddmThemeConfigPath,
            root.curTheme,
            themeData.fontStyle || root.defaultTheme.fontStyle,
            resolveRepoPath(themeData.wallpaperPath || root.defaultTheme.wallpaperPath),
            themeData.primaryColor || root.defaultTheme.primaryColor,
            themeData.secondaryColor || root.defaultTheme.secondaryColor,
            themeData.tertiaryColor || root.defaultTheme.tertiaryColor,
            themeData.backgroundColor || root.defaultTheme.backgroundColor,
            themeData.defaultTextColor || root.defaultTheme.defaultTextColor
        ])
    }
    function themeCommandArgs(scriptPath, configPath, themePath, themeData) {
        return [
            scriptPath,
            configPath,
            themePath,
            themeData.fontStyle || root.defaultTheme.fontStyle,
            themeData.primaryColor || root.defaultTheme.primaryColor,
            themeData.secondaryColor || root.defaultTheme.secondaryColor,
            themeData.tertiaryColor || root.defaultTheme.tertiaryColor,
            themeData.quaternaryColor || root.defaultTheme.quaternaryColor,
            themeData.backgroundColor || root.defaultTheme.backgroundColor,
            themeData.defaultTextColor || root.defaultTheme.defaultTextColor,
            themeData.textBorderColor || root.defaultTheme.textBorderColor,
            themeData.kittyBackgroundOpacity || root.defaultTheme.kittyBackgroundOpacity
        ]
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

    Process {
        id: kittyThemeSetter

        stderr: StdioCollector {
            onStreamFinished: {
                const err = text.trim()
                if (err.length)
                    console.error("ThemeManager: failed to set kitty theme:", err)
            }
        }
    }

    Process {
        id: sddmThemeSetter

        stderr: StdioCollector {
            onStreamFinished: {
                const err = text.trim()
                if (err.length)
                    console.error("ThemeManager: failed to set SDDM theme:", err)
            }
        }
    }

    FileView {
        id: file
        path: root.path

        blockLoading: true

        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            root.updateMap()
            root.themeMapReady = true
            root.initializeTheme()
        }

        onTextChanged: root.updateMap()

        onLoadFailed: {
            console.error("ThemeStore: failed to load theme file")
            root.map = {}
            root.themeMapReady = true
            root.initializeTheme()
        }
        Component.onCompleted: reload()
    }

    FileView {
        id: stateFile
        path: root.statePath

        blockLoading: true
        atomicWrites: true
        watchChanges: true

        onAdapterUpdated: writeAdapter()
        onFileChanged: reload()

        onLoaded: {
            root.themeStateReady = true
            root.initializeTheme()
        }

        onLoadFailed: {
            root.themeStateReady = true
            root.initializeTheme()
            writeAdapter()
        }

        JsonAdapter {
            id: themeState
            property string currentTheme: root.defaultThemeName
        }
    }
}
