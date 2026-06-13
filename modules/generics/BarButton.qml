import QtQuick
import QtQuick.Controls
import Quickshell
import "../global"

Item {
    id: barButton

    //style
    property string labelIcon: ""
    property string fontFamily: ""
    property string textColor: ""
    property string textBorderColor: ""
    property var theme: ThemeManager.getCurTheme()
    property string hoverColor: ThemeManager.alterColor(textColor, .7)
    property string pressedColor: ThemeManager.alterColor(textColor, .5)

    implicitWidth:  20
    implicitHeight: 30

    //button functionality
    property var onClick
    property var popupName: ""

    Text {
        id: icon
        text: labelIcon
        font.pixelSize: 20
        font.family: fontFamily
        color: mouseArea.pressed ? pressedColor : mouseArea.containsMouse ? hoverColor : textColor
        style: Text.Outline
        styleColor: textBorderColor

        Behavior on color { ColorAnimation { duration: 100 } }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            if (popupName !== "") {
                // activePopup comes from the outer Scope
                activePopup = (activePopup === popupName ? "" : popupName)
            }
        }
    }
}
