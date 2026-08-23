import QtQuick

Rectangle {
    id: root

    required property url contentSource
    required property real maximumWidth
    required property real maximumHeight
    required property real revealProgress

    property int contentPadding: 15
    property int cornerRadius: 16
    property int animationDuration: 300

    signal contentLoaded()

    width: Math.min(maximumWidth, popupLoader.implicitWidth + contentPadding * 2)
    height: Math.min(maximumHeight, popupLoader.implicitHeight + contentPadding * 2)

    topLeftRadius: cornerRadius
    bottomLeftRadius: cornerRadius
    topRightRadius: 0
    bottomRightRadius: 0
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    transform: Translate {
        x: (1 - root.revealProgress) * root.width
    }

    Item {
        anchors.fill: parent
        anchors.margins: root.contentPadding
        clip: true

        Loader {
            id: popupLoader
            anchors.centerIn: parent
            source: root.contentSource

            onLoaded: root.contentLoaded()
        }
    }
}
