import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root

    width: 1920
    height: 1080
    color: config.backgroundColor || "#111827"

    readonly property color accent: config.accentColor || "#60a5fa"
    readonly property color card: config.cardColor || "#d91f2937"
    readonly property color foreground: config.textColor || "#f9fafb"
    readonly property color muted: config.mutedTextColor || "#9ca3af"
    readonly property color error: config.errorColor || "#fca5a5"
    readonly property string uiFont: config.fontFamily || "sans-serif"
    property bool authenticating: false

    function submitLogin() {
        if (authenticating || passwordField.text.length === 0)
            return

        authenticating = true
        messageLabel.color = muted
        messageLabel.text = qsTr("Signing in…")
        sddm.login(userBox.currentText, passwordField.text, sessionBox.currentIndex)
    }

    Image {
        anchors.fill: parent
        source: config.backgroundImage || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.18) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.48) }
        }
    }

    SDDM.TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            messageLabel.color = root.accent
            messageLabel.text = textConstants.loginSucceeded
        }

        function onLoginFailed() {
            root.authenticating = false
            passwordField.selectAll()
            passwordField.forceActiveFocus()
            messageLabel.color = root.error
            messageLabel.text = textConstants.loginFailed
        }

        function onInformationMessage(message) {
            messageLabel.color = root.muted
            messageLabel.text = message
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "dddd, MMMM d  ·  h:mm AP")
    }

    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 42
        spacing: 5

        Text {
            id: clock
            color: root.foreground
            font.pixelSize: 22
            font.weight: Font.DemiBold
            font.family: root.uiFont
        }

        Text {
            visible: config.showHostname !== "false"
            text: sddm.hostName
            color: root.muted
            font.pixelSize: 14
            font.family: root.uiFont
        }
    }

    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: Math.min(400, parent.width - 48)
        height: loginColumn.implicitHeight + 64
        radius: 18
        color: root.card
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.09)
        visible: primaryScreen

        ColumnLayout {
            id: loginColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 32
            spacing: 14

            Label {
                Layout.fillWidth: true
                text: config.welcomeText || qsTr("Welcome back")
                color: root.foreground
                font.pixelSize: 28
                font.weight: Font.DemiBold
                font.family: root.uiFont
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Sign in to continue")
                color: root.muted
                font.pixelSize: 14
                font.family: root.uiFont
                bottomPadding: 8
            }

            ComboBox {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                enabled: !root.authenticating
                font.family: root.uiFont
                KeyNavigation.tab: passwordField
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                passwordCharacter: "●"
                enabled: !root.authenticating
                focus: true
                selectByMouse: true
                font.family: root.uiFont
                onAccepted: root.submitLogin()
                KeyNavigation.tab: sessionBox
                KeyNavigation.backtab: userBox
            }

            ComboBox {
                id: sessionBox
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                enabled: !root.authenticating
                font.family: root.uiFont
                KeyNavigation.tab: loginButton
                KeyNavigation.backtab: passwordField
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: root.authenticating ? qsTr("Signing in…") : qsTr("Sign in")
                enabled: !root.authenticating && passwordField.text.length > 0
                highlighted: true
                font.family: root.uiFont
                onClicked: root.submitLogin()
                KeyNavigation.backtab: sessionBox

                background: Rectangle {
                    radius: 8
                    color: loginButton.down ? Qt.darker(root.accent, 1.2)
                                            : loginButton.enabled ? root.accent : Qt.darker(root.accent, 1.8)
                }

                contentItem: Text {
                    text: loginButton.text
                    color: "#08111f"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    font.family: root.uiFont
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Label {
                id: messageLabel
                Layout.fillWidth: true
                Layout.minimumHeight: 20
                text: ""
                color: root.muted
                font.pixelSize: 13
                font.family: root.uiFont
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 30
        spacing: 8

        Button {
            visible: sddm.canSuspend
            text: qsTr("Suspend")
            flat: true
            font.family: root.uiFont
            onClicked: sddm.suspend()
        }

        Button {
            visible: sddm.canReboot
            text: qsTr("Restart")
            flat: true
            font.family: root.uiFont
            onClicked: sddm.reboot()
        }

        Button {
            visible: sddm.canPowerOff
            text: qsTr("Shut down")
            flat: true
            font.family: root.uiFont
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: {
        if (loginCard.visible)
            passwordField.forceActiveFocus()
    }
}
