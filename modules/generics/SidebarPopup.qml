import Quickshell
import QtQuick
import "../util"
import "../global"

PopupWindow {
    id: popup
    color: "transparent"
    grabFocus: false

    required property QsWindow anchorWindow
    property real anchorX: 0
    property real anchorY: anchorWindow.height / 2

    PopupSourcesMap {
        id: popupSources
    }

    property var theme: ThemeManager.getCurTheme()
    property string backgroundColor: theme.backgroundColor
    property string fontColor: theme.defaultTextColor
    property string fontFamily: theme.fontStyle
    property string textBorderColor: theme.textBorderColor
    property string primaryColor: theme.primaryColor
    property string secondaryColor: theme.secondaryColor
    property string tertiaryColor: theme.tertiaryColor
    property int maximumPopupWidth: 450
    property int popupScreenMargin: 40
    
    visible: displayedPopup !== ""
    
    // Keep the native Wayland surface stable. Only popupCard changes size.
    implicitWidth: maximumPopupWidth
    implicitHeight: Math.max(1, anchorWindow.height - popupScreenMargin)

    mask: Region { item: popupCard }
    
    anchor {
        window: popup.anchorWindow
        rect.x: popup.anchorX
        rect.y: (popup.anchorWindow.height - popup.height) / 2
    }

    Rectangle {
        id: popupCard

        anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: popup.anchorY - (popup.anchorWindow.height / 2)

        width: Math.min(popup.width, popupLoader.implicitWidth + 30)
        height: Math.min(popup.height, popupLoader.implicitHeight + 30)

        color: popup.backgroundColor

        topLeftRadius: 16
        bottomLeftRadius: 16
        topRightRadius: 0
        bottomRightRadius: 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        transform: [
            Translate {
                x: (1 - popup.revealProgress) * popupCard.width
            },
            Scale {
                origin.x: popupCard.width / 2
                origin.y: popupCard.height / 2
            }
        ]
        
        Item {
            id: contentWrapper
            anchors.fill: parent
            anchors.margins: 15
            clip: true

            Loader {
                id: popupLoader
                anchors.centerIn: parent
                source: popupSources.map[popup.displayedPopup] || ""

                onLoaded: popup.finishLoadingPopup()
            }
        }
    }

    //Animation State and Transitions

    property real revealProgress: 0
    property real verticalRevealProgress: 0
    property string requestedPopup: activePopup
    property string displayedPopup: ""
    property bool animateNextLoad: false

    onRequestedPopupChanged: {
        if (requestedPopup === "") {
            if (displayedPopup !== "") {
                openAnimation.stop()
                closeAnimation.restart()
            }
            return
        }

        const contentChanged = displayedPopup !== requestedPopup
        const shouldAnimate = displayedPopup === "" || closeAnimation.running

        closeAnimation.stop()
        animateNextLoad = contentChanged && shouldAnimate

        if (contentChanged)
            displayedPopup = requestedPopup
        else if (shouldAnimate)
            openAnimation.restart()

        if (!shouldAnimate)
            revealProgress = 1
    }

    function finishLoadingPopup() {
        if (animateNextLoad) {
            animateNextLoad = false
            openAnimation.restart()
        } else {
            revealProgress = 1
        }
    }

    ParallelAnimation {
        id: openAnimation

        NumberAnimation {
            target: popup
            property: "revealProgress"
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation

        NumberAnimation {
            target: popup
            property: "revealProgress"
            to: 0
            duration: 300
            easing.type: Easing.InCubic
        }

        onFinished: {
            if (popup.requestedPopup === "") {
                popup.displayedPopup = ""
            }
        }
    }

}
