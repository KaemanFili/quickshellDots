import Quickshell
import QtQuick
import "../util"
import "../global"

PanelWindow {
    id: popup
    color: "transparent"
    focusable: true

    PopupSourcesMap {
        id: popupSources
    }

    ThemesMap {
        id: themesMap
    }
    property var theme: ThemeManager.getCurTheme()
    property string backgroundColor: theme.backgroundColor
    property string fontColor: theme.defaultTextColor
    property string fontFamily: theme.fontStyle
    property string textBorderColor: theme.textBorderColor
    property string primaryColor: theme.primaryColor
    property string secondaryColor: theme.secondaryColor
    property string tertiaryColor: theme.tertiaryColor

    implicitWidth: contentWrapper.implicitWidth +30
    implicitHeight: contentWrapper.implicitHeight + 30
    
    visible: activePopup !== ""
    
    Rectangle {
        anchors.fill: parent
        color: popup.backgroundColor
        radius: 16
        border.width: 2
        border.color: popup.textBorderColor
        clip: true
        Item {
            id: contentWrapper
            anchors.centerIn: parent
            anchors.margins:12 
            clip: true
            
            implicitWidth: popupLoader.implicitWidth 
            implicitHeight: popupLoader.implicitHeight
            Loader {
                id: popupLoader
                source: popupSources.map[activePopup] || ""

            }
        }
    }
}