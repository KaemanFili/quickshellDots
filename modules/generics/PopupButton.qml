import QtQuick
import "../global"

Item {
    id: root
    property var theme: ThemeManager.getCurTheme()

    property string text: ""
    property color normalColor: theme.primaryColor
    property color hoverColor: ThemeManager.alterColor(theme.primaryColor, 0.8)
    property color pressedColor: ThemeManager.alterColor(theme.primaryColor,0.7)
    property color textColor: theme.textBorderColor
    property string fontStyle: theme.fontStyle
    signal clicked()

    implicitWidth: label.implicitWidth + 40
    implicitHeight: 40


    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: normalColor

        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Text {
        id: label
        text: root.text
        anchors.centerIn: parent
        color: root.textColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPressed: bg.color = pressedColor
        onReleased: {
            bg.color = containsMouse ? hoverColor : normalColor
        }
        onEntered: if (!pressed) bg.color = hoverColor
        onExited:  if (!pressed) bg.color = normalColor

        onClicked: root.clicked()
    }
}