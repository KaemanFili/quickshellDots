import QtQuick
import Quickshell

Item {
    id: clockWidget

    property string fontFamily: ""
    property string textColor: ""
    property string textBorderColor: ""

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, "hh\nmm\n----\nMM\ndd")
        color: textColor
        font.family: fontFamily
        font.pixelSize: 14
        font.bold: true
        //style: Text.Outline
        //styleColor: textBorderColor
    }
    implicitHeight: 100
    implicitWidth: 20
}

