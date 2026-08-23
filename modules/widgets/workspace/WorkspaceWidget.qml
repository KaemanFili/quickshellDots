import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "." as WorkspaceComponents

ColumnLayout {
    id: root

    property string activeColor: ""
    property string occupiedColor: ""
    property string emptyColor: ""
    property string fontFamily: ""
    property string textBorderColor: ""

    Repeater {
        model: 10

        WorkspaceComponents.WorkspaceItem {
            required property int index

            workspaceId: index + 1
            workspace: Hyprland.workspaces.values.find(item => item.id === workspaceId)
            active: Hyprland.focusedWorkspace?.id === workspaceId
            activeToplevel: active ? Hyprland.activeToplevel : null
            activeColor: root.activeColor
            occupiedColor: root.occupiedColor
            emptyColor: root.emptyColor
            fontFamily: root.fontFamily
            textBorderColor: root.textBorderColor
        }
    }
}
