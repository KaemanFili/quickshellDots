import Quickshell
import Quickshell.Wayland
import QtQuick
import "global"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaperWindow

            required property var modelData
            readonly property url themeWallpaper: ThemeManager.resolveRepoPath(ThemeManager.wallpaperPath)
            property int transitionDuration: ThemeManager.themeTransitionDuration
            property bool initialized: false

            screen: modelData
            color: "black"
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            // Sit above background providers such as Hyprpaper, but below all
            // normal application windows. Ignore exclusion so this reserves no
            // desktop space.
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell-wallpaper"

            Image {
                id: currentWallpaper
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }

            Image {
                id: nextWallpaper
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                opacity: 0

                onStatusChanged: {
                    if (status === Image.Ready && source !== currentWallpaper.source)
                        crossfade.restart()
                }
            }

            onThemeWallpaperChanged: {
                if (!initialized)
                    return

                if (themeWallpaper === currentWallpaper.source)
                    return

                crossfade.stop()
                nextWallpaper.opacity = 0
                nextWallpaper.source = themeWallpaper
            }

            Component.onCompleted: {
                currentWallpaper.source = themeWallpaper
                initialized = true
            }

            NumberAnimation {
                id: crossfade
                target: nextWallpaper
                property: "opacity"
                from: 0
                to: 1
                duration: wallpaperWindow.transitionDuration
                easing.type: Easing.InOutCubic

                onFinished: {
                    currentWallpaper.source = nextWallpaper.source
                    nextWallpaper.opacity = 0
                }
            }
        }
    }
}
