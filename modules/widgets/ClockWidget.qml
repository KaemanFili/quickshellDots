import QtQuick
import Quickshell

Item {
    id: clockWidget

    property string fontFamily: ""
    property string textColor: ""
    property string textBorderColor: ""
    property string backgroundColor: ""
    signal clicked()

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
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 16
                font.bold: true
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
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 16
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "ddd")
                color: textColor
                opacity: 0.75
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 8
                font.bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clockWidget.clicked()
    }
}
