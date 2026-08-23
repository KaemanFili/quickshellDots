import QtQuick
import "../global"

Item {
    id: root

    property string popupName: ""
    property var popupController: null
    property string fontFamily: ""
    property string textColor: ""
    property string textBorderColor: ""
    property string hoverColor: ThemeManager.alterColor(textColor, 0.7)
    property string pressedColor: ThemeManager.alterColor(textColor, 0.5)
    property int cursorShape: Qt.ArrowCursor

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed
    readonly property string interactiveTextColor: pressed
        ? pressedColor
        : (hovered ? hoverColor : textColor)

    signal clicked()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.cursorShape

        onClicked: {
            root.clicked()
            if (root.popupName !== "" && root.popupController)
                root.popupController.togglePopup(root.popupName)
        }
    }
}
