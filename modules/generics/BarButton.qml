import QtQuick

BarButtonBase {
    id: barButton

    property string labelIcon: ""

    implicitWidth:  20
    implicitHeight: 30

    Text {
        id: icon
        anchors.centerIn: parent
        text: labelIcon
        font.pixelSize: 20
        font.family: fontFamily
        color: interactiveTextColor
        style: Text.Outline
        styleColor: textBorderColor

        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
