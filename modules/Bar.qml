import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "widgets"
import "widgets/workspace"
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
  
  SidebarPopup {
    id: popupWindow
    anchorWindow: barPanel
    popupController: root
    anchorX: barBackground.middleInnerEdgeX
    anchorY: barBackground.middleCenterY
  }

 PanelWindow {
      id: barPanel
      property int fullBarWidth: 40
      property int slimBarWidth: 15
      property int spacerCurveRadius: 16
      property int outerCornerRadius: 16
      property int sectionExtension: 8
      screen: Quickshell.screens.find(s => s.name === screensMap.map["monitor1"])
          ?? Quickshell.screens[0]
      // positioning
      anchors{
          top: true 
          right: true
          bottom: true
      }
      implicitWidth: fullBarWidth
      
      // styling
      color: "transparent"

      Item {
        id: barContent
        anchors.fill: parent

        readonly property real spacerTop: column.y + spacer.y
        readonly property real spacerBottom: spacerTop + spacer.height

        BarBackground {
          id: barBackground
          anchors.fill: parent
          spacerTop: barContent.spacerTop
          spacerBottom: barContent.spacerBottom
          backgroundColor: root.theme.backgroundColor
          fullWidth: barPanel.fullBarWidth
          slimWidth: barPanel.slimBarWidth
          spacerCurveRadius: barPanel.spacerCurveRadius
          outerCornerRadius: barPanel.outerCornerRadius
          sectionExtension: barPanel.sectionExtension
        }

        ColumnLayout {
          id: column
          anchors.fill: parent
          anchors.margins: 4


          WorkspaceWidget{
            Layout.alignment: Qt.AlignHCenter
            activeColor: root.theme.secondaryColor
            occupiedColor: root.theme.primaryColor
            emptyColor: root.theme.tertiaryColor
            fontFamily: root.theme.fontStyle
            textBorderColor: root.theme.textBorderColor
          }
          Item {
           id: spacer
           Layout.fillHeight: true
        
          }

          Repeater {
            model: ["systemStats", "network", "audio", "bluetooth"]

            BarButton {
              required property string modelData

              popupController: root
              popupName: modelData
              Layout.alignment: Qt.AlignHCenter
              labelIcon: iconsMap.map[popupName === "network" ? root.networkType : popupName]
              fontFamily: root.theme.fontStyle
              textColor: root.theme.primaryColor
              textBorderColor: root.theme.textBorderColor
            }
          }
          // the ClockWidget type we just created
          ClockWidget {
            popupName: "calendar"
            popupController: root
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 2
            fontFamily: root.theme.fontStyle
            textColor: root.theme.defaultTextColor
            textBorderColor: root.theme.textBorderColor
            backgroundColor: root.theme.primaryColor
          }
          
        }
      }
      
    }
    
}
