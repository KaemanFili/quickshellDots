import QtQuick
import QtQuick.Layouts
import "../generics"
import "../global"

Item {
    id: themeChangerConfig

    implicitWidth: content.width
    implicitHeight: content.height

    readonly property var themeNames: Object.keys(ThemeManager.map).sort()

    function isActiveTheme(name) {
        return ThemeManager.curTheme === name
    }

    Column {
        id: content
        spacing: 8
        width: 400
        height: childrenRect.height

        Text {
            text: "Themes"
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true
            style: Text.Outline
            styleColor: textBorderColor
        }

        Repeater {
            model: themeChangerConfig.themeNames

            RowLayout {
                width: content.width
                spacing: 8

                readonly property var themeEntry: ThemeManager.theme(modelData)

                Text {
                    text: modelData
                    color: themeChangerConfig.isActiveTheme(modelData) ? primaryColor : fontColor
                    font.family: fontFamily
                    font.pixelSize: 15
                    font.bold: themeChangerConfig.isActiveTheme(modelData)
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Row {
                    spacing: 4
                    Layout.preferredWidth: childrenRect.width
                    Layout.preferredHeight: 18

                    Repeater {
                        model: [
                            themeEntry.primaryColor,
                            themeEntry.secondaryColor,
                            themeEntry.tertiaryColor,
                            themeEntry.backgroundColor
                        ]

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 4
                            color: modelData
                            border.width: 1
                            border.color: textBorderColor
                        }
                    }
                }

                PopupButton {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 90
                    text: themeChangerConfig.isActiveTheme(modelData) ? "Reapply" : "Apply"

                    onClicked: {
                        ThemeManager.setCurTheme(modelData)
                    }
                }
            }
        }

        Text {
            visible: themeChangerConfig.themeNames.length === 0
            text: "No themes found"
            color: fontColor
            font.family: fontFamily
            font.pixelSize: 15
        }
    }
}
