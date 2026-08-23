import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    required property int workspaceId
    property var workspace: null
    property bool active: false
    property var activeToplevel: null
    property string activeColor: ""
    property string occupiedColor: ""
    property string emptyColor: ""
    property string fontFamily: ""
    property string textBorderColor: ""
    readonly property string appIcon: iconFor(activeToplevel)

    function iconFor(toplevel) {
        if (!toplevel)
            return ""

        const ipc = toplevel.lastIpcObject ?? {}
        const appId = ipc.class ?? ipc.initialClass ?? toplevel.wayland?.appId ?? ""
        if (appId === "")
            return ""

        const entry = DesktopEntries.heuristicLookup(appId)
        return entry ? Quickshell.iconPath(entry.icon, "application-x-executable") : ""
    }

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: active && appIcon !== "" ? 34 : 22
    implicitHeight: active && appIcon !== "" ? 38 : 22
    Behavior on implicitWidth { NumberAnimation { duration: 120 } }
    Behavior on implicitHeight { NumberAnimation { duration: 120 } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 1

        IconImage {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 18
            implicitHeight: 18
            source: root.appIcon
            visible: root.active && source !== ""
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: root.activeColor
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.workspaceId === 10 ? "0" : root.workspaceId
            color: root.active
                ? root.activeColor
                : (root.workspace ? root.occupiedColor : root.emptyColor)
            font.pixelSize: root.active && root.appIcon !== "" ? 11 : 14
            font.bold: true
            font.family: root.fontFamily
            style: Text.Outline
            styleColor: root.textBorderColor
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + root.workspaceId + '" })')
    }
}
