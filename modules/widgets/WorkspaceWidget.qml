import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ColumnLayout {

    property string activeColor: ""
    property string occupiedColor: ""
    property string emptyColor: ""
    property string fontFamily: ""
    property string textBorderColor: ""


    Repeater {
        model: 10

        Text{
            text: index > 8 ? "0" : (index +1)
            property var workspace: Hyprland.workspaces.values.find(w=> w.id === index +1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index +1)
            color: isActive ? activeColor : (workspace ? occupiedColor: emptyColor)
            font{
                pixelSize: 14
                bold: true  
                family: fontFamily
            }
            style: Text.Outline
            styleColor: textBorderColor

            MouseArea{
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index +1) )
            }
        }
    }
}