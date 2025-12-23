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
        color: textColor
        style: Text.Outline
        styleColor: textBorderColor

        Behavior on color { ColorAnimation { duration: 100 } }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            if (popupName !== "") {
                // activePopup comes from the outer Scope
                activePopup = (activePopup === popupName ? "" : popupName)
            }
        }
        onPressed: icon.color = pressedColor
        onReleased: {
            icon.color = containsMouse ? hoverColor : textColor
        }
        onEntered: if (!pressed) icon.color = hoverColor
        onExited:  if (!pressed) icon.color = textColor
    }
}