import Quickshell
import QtQuick
import "../util"
import "../global"

PopupWindow {
    id: popup
    color: "transparent"
    grabFocus: false

    required property QsWindow anchorWindow
    required property var popupController
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
    property int contentPadding: 15
    property int cornerRadius: 16
    property int animationDuration: 300
    
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

    SidebarPopupCard {
        id: popupCard

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: popup.anchorY - (popup.anchorWindow.height / 2)

        contentSource: popupSources.map[popup.displayedPopup] || ""
        maximumWidth: popup.width
        maximumHeight: popup.height
        revealProgress: popup.revealProgress
        contentPadding: popup.contentPadding
        cornerRadius: popup.cornerRadius
        animationDuration: popup.animationDuration
        color: popup.backgroundColor

        onContentLoaded: popup.handleContentLoaded()
    }

    //Animation State and Transitions

    property real revealProgress: 0
    property string requestedPopup: popupController.activePopup
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

    function handleContentLoaded() {
        if (animateNextLoad) {
            animateNextLoad = false
            openAnimation.restart()
        } else {
            revealProgress = 1
        }
    }

    NumberAnimation {
        id: openAnimation
        target: popup
        property: "revealProgress"
        to: 1
        duration: popup.animationDuration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: closeAnimation
        target: popup
        property: "revealProgress"
        to: 0
        duration: popup.animationDuration
        easing.type: Easing.InCubic

        onFinished: {
            if (popup.requestedPopup === "") {
                popup.displayedPopup = ""
            }
        }
    }

}
