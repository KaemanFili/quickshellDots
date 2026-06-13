import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "widgets"
import "generics"
import "util"
import "global"


Scope {
  id: root
  property string activePopup: ""
  property var theme: ThemeManager.getCurTheme()
  property string networkType: NetworkManager.getConnectionType()


  IconsMap {
    id: iconsMap
  }
  ScreensMap {
    id: screensMap
  }
  PopupSourcesMap {
    id: popupSources
  }

  function hasPopup(popupName) {
    return popupSources.map[popupName] !== undefined
  }

  function showPopup(popupName) {
    if (root.hasPopup(popupName)) {
      root.activePopup = popupName
    }
  }

  function togglePopup(popupName) {
    if (root.hasPopup(popupName)) {
      root.activePopup = root.activePopup === popupName ? "" : popupName
    }
  }

  function closePopup() {
    root.activePopup = ""
  }

  IpcHandler {
    target: "popup"

    function show(popupName: string): void { root.showPopup(popupName) }
    function toggle(popupName: string): void { root.togglePopup(popupName) }
    function close(): void { root.closePopup() }
    function toggleThemeChanger(): void { root.togglePopup("themeChanger") }
  }
  
  PopupWindow {
    id: popupWindow
    //backgroundColor: theme.backgroundColor
    //fontColor: theme.tertiaryColor
    //fontFamily: theme.fontStyle
  }

 PanelWindow {
      required property var modelData
      screen: Quickshell.screens.find(s => s.name === screensMap.map["monitor1"])
      // positioning
      anchors{
          top: true 
          right: true
          bottom: true
      }
      implicitWidth: 40
      implicitHeight: screen.height
      
      // styling
      color: root.theme.backgroundColor

      MarginWrapperManager {
          margin: 4
      }
      ColumnLayout {
        id: column
        //positioning


        WorkspaceWidget{
          Layout.alignment: Qt.AlignHCenter
          activeColor: root.theme.secondaryColor
          occupiedColor: root.theme.primaryColor
          emptyColor: root.theme.tertiaryColor
          fontFamily: root.theme.fontStyle
          textBorderColor: root.theme.textBorderColor
        }
        Item {
         Layout.fillHeight: true
        
        }

        // the bottom of the task bar
        BarButton {
          popupName: "network"
          Layout.alignment: Qt.AlignHCenter
          labelIcon : iconsMap.map[root.networkType]
          fontFamily: root.theme.fontStyle
          textColor: root.theme.primaryColor
          textBorderColor: root.theme.textBorderColor
        }
        BarButton {
          popupName: "audio"
          Layout.alignment: Qt.AlignHCenter
          labelIcon : iconsMap.map[popupName]
          fontFamily: root.theme.fontStyle
          textColor: root.theme.primaryColor
          textBorderColor: root.theme.textBorderColor
        }
        BarButton {
          popupName: "bluetooth"
          Layout.alignment: Qt.AlignHCenter
          labelIcon : iconsMap.map[popupName]
          fontFamily: root.theme.fontStyle
          textColor: root.theme.primaryColor
          textBorderColor: root.theme.textBorderColor
        }
        // the ClockWidget type we just created
        ClockWidget {
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: 2
          fontFamily: root.theme.fontStyle
          textColor: root.theme.defaultTextColor
          textBorderColor: root.theme.textBorderColor
          backgroundColor: root.theme.primaryColor
        }
        //spacer
        //Item {
         //implicitHeight: 20
        
        //}
        
      }
      
    }
    
}
