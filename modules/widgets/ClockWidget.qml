import QtQuick
import Quickshell
import "../generics"

BarButtonBase {
    id: clockWidget

    property string backgroundColor: ""
    cursorShape: Qt.PointingHandCursor

    implicitHeight: clockPill.height
    implicitWidth: clockPill.width

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        id: clockPill

        width: 32
        height: 58
        radius: 8
        color: backgroundColor
        border.color: textBorderColor
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: -1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "hh")
                color: clockWidget.interactiveTextColor
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 16
                font.bold: true
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 14
                height: 1
                color: textBorderColor
                opacity: 0.5
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "mm")
                color: clockWidget.interactiveTextColor
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 16
                font.bold: true
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "ddd")
                color: clockWidget.interactiveTextColor
                opacity: 0.75
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 8
                font.bold: true
                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }
    }

}
