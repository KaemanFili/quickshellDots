import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
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
    anchorX: barPanel.middleInnerEdgeX
    anchorY: barPanel.middleBarCenterY
    //backgroundColor: theme.backgroundColor
    //fontColor: theme.tertiaryColor
    //fontFamily: theme.fontStyle
  }

 PanelWindow {
      id: barPanel
      required property var modelData
      property int fullBarWidth: 40
      property int slimBarWidth: 15
      readonly property int middleInnerEdgeX: fullBarWidth - slimBarWidth
      readonly property real middleBarCenterY: middleBar.y + (middleBar.height / 2)
      property int spacerCurveRadius: 16
      property int outerCornerRadius: 16
      property int sectionExtension: 8
      screen: Quickshell.screens.find(s => s.name === screensMap.map["monitor1"])
      // positioning
      anchors{
          top: true 
          right: true
          bottom: true
      }
      implicitWidth: fullBarWidth
      implicitHeight: screen.height
      
      // styling
      color: "transparent"

      Item {
        id: barContent
        anchors.fill: parent

        readonly property real spacerTop: column.y + spacer.y
        readonly property real spacerBottom: spacerTop + spacer.height

        Rectangle {
          anchors.top: parent.top
          anchors.right: parent.right
          width: barPanel.fullBarWidth
          height: barContent.spacerTop + barPanel.sectionExtension
          color: root.theme.backgroundColor
          bottomLeftRadius: barPanel.outerCornerRadius
        }

        Shape {
          id: middleBar
          anchors.right: parent.right
          y: barContent.spacerTop + barPanel.sectionExtension
          width: barPanel.fullBarWidth
          height: Math.max(0, spacer.height - (barPanel.sectionExtension * 2))

          ShapePath {
            fillColor: root.theme.backgroundColor
            strokeWidth: 0
            startX: barPanel.outerCornerRadius
            startY: 0

            PathLine { x: barPanel.fullBarWidth; y: 0 }
            PathLine { x: barPanel.fullBarWidth; y: middleBar.height }
            PathLine { x: barPanel.outerCornerRadius; y: middleBar.height }
            PathQuad {
              x: barPanel.fullBarWidth - barPanel.slimBarWidth
              y: middleBar.height - barPanel.spacerCurveRadius
              controlX: barPanel.fullBarWidth - barPanel.slimBarWidth
              controlY: middleBar.height
            }
            PathLine {
              x: barPanel.fullBarWidth - barPanel.slimBarWidth
              y: barPanel.spacerCurveRadius
            }
            PathQuad {
              x: barPanel.outerCornerRadius
              y: 0
              controlX: barPanel.fullBarWidth - barPanel.slimBarWidth
              controlY: 0
            }
          }
        }

        Rectangle {
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          width: barPanel.fullBarWidth
          height: barPanel.height - barContent.spacerBottom + barPanel.sectionExtension
          color: root.theme.backgroundColor
          topLeftRadius: barPanel.outerCornerRadius
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

          // the bottom of the task bar
          BarButton {
            popupName: "systemStats"
            Layout.alignment: Qt.AlignHCenter
            labelIcon: iconsMap.map[popupName]
            fontFamily: root.theme.fontStyle
            textColor: root.theme.primaryColor
            textBorderColor: root.theme.textBorderColor
          }
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
            popupName: "calendar"
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
