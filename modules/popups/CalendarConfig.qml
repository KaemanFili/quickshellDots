import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    implicitWidth: 360
    implicitHeight: content.implicitHeight

    property date displayedMonth: clock.date

    function changeMonth(offset) {
        displayedMonth = new Date(displayedMonth.getFullYear(),
                                  displayedMonth.getMonth() + offset, 1)
    }

    function isToday(date) {
        return date.getFullYear() === clock.date.getFullYear()
            && date.getMonth() === clock.date.getMonth()
            && date.getDate() === clock.date.getDate()
    }

    function dayOfYear(date) {
        const startOfYear = Date.UTC(date.getFullYear(), 0, 1)
        const currentDay = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())
        return Math.floor((currentDay - startOfYear) / 86400000) + 1
    }

    function isoWeekNumber(date) {
        const target = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
        const day = target.getUTCDay() || 7
        target.setUTCDate(target.getUTCDate() + 4 - day)
        const yearStart = new Date(Date.UTC(target.getUTCFullYear(), 0, 1))
        return Math.ceil((((target - yearStart) / 86400000) + 1) / 7)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    ColumnLayout {
        id: content
        width: parent.width
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: textBorderColor
        }

        Text {
            Layout.fillWidth: true
            text: Qt.formatDateTime(clock.date, "h:mm:ss AP")
            color: fontColor
            font.family: fontFamily
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: tertiaryColor
            opacity: 0.5
        }

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                property color accentColor: secondaryColor
                implicitWidth: 34
                implicitHeight: 30
                radius: 8
                color: previousMonthMouse.pressed
                    ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.25)
                    : previousMonthMouse.containsMouse
                        ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.14)
                        : "transparent"

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1
                    text: "\u2039"
                    color: secondaryColor
                    font.family: fontFamily
                    font.pixelSize: 24
                }

                MouseArea {
                    id: previousMonthMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.changeMonth(-1)
                }

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(displayedMonth, "MMMM yyyy")
                color: secondaryColor
                font.family: fontFamily
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                property color accentColor: secondaryColor
                implicitWidth: 34
                implicitHeight: 30
                radius: 8
                color: nextMonthMouse.pressed
                    ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.25)
                    : nextMonthMouse.containsMouse
                        ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.14)
                        : "transparent"

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1
                    text: "\u203a"
                    color: secondaryColor
                    font.family: fontFamily
                    font.pixelSize: 24
                }

                MouseArea {
                    id: nextMonthMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.changeMonth(1)
                }

                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }

        DayOfWeekRow {
            Layout.fillWidth: true
            locale: Qt.locale()

            delegate: Text {
                required property string shortName
                text: shortName
                color: tertiaryColor
                font.family: fontFamily
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        MonthGrid {
            id: monthGrid
            Layout.fillWidth: true
            Layout.preferredHeight: 210
            month: displayedMonth.getMonth()
            year: displayedMonth.getFullYear()
            locale: Qt.locale()
            spacing: 4

            delegate: Rectangle {
                required property var model

                implicitWidth: 44
                implicitHeight: 30
                radius: 8
                color: root.isToday(model.date) ? primaryColor : "transparent"
                opacity: model.month === monthGrid.month ? 1 : 0.3

                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: root.isToday(model.date) ? backgroundColor : fontColor
                    font.family: fontFamily
                    font.bold: root.isToday(model.date)
                    font.pixelSize: 14
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: "ISO week " + root.isoWeekNumber(clock.date)
                + "  \u2022  Day " + root.dayOfYear(clock.date) + " of the year"
            color: tertiaryColor
            font.family: fontFamily
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
