import QtQuick
import Quickshell

Item {
    id: clockWidget

    property string fontFamily: ""
    property string textColor: ""
    property string textBorderColor: ""
    property string backgroundColor: ""

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    Rectangle {
        implicitHeight: childrenRect.height
        implicitWidth: childrenRect.width
        color: "transparent"
        Text {
            height: 50
            //width: 20

            text: Qt.formatDateTime(clock.date, "hh\nmm")
            color: textColor
            font.family: fontFamily
            font.pixelSize: 16
            font.bold: true
            //style: Text.Outline
            //styleColor: textBorderColor
        }
    }
    
}

