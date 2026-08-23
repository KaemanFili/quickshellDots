import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property real spacerTop
    required property real spacerBottom
    required property color backgroundColor

    property int fullWidth: 40
    property int slimWidth: 15
    property int spacerCurveRadius: 16
    property int outerCornerRadius: 16
    property int sectionExtension: 8

    readonly property real middleInnerEdgeX: fullWidth - slimWidth
    readonly property real middleCenterY: middleBar.y + middleBar.height / 2

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.fullWidth
        height: root.spacerTop + root.sectionExtension
        color: root.backgroundColor
        bottomLeftRadius: root.outerCornerRadius
    }

    Shape {
        id: middleBar
        anchors.right: parent.right
        y: root.spacerTop + root.sectionExtension
        width: root.fullWidth
        height: Math.max(0, root.spacerBottom - root.spacerTop - root.sectionExtension * 2)

        ShapePath {
            fillColor: root.backgroundColor
            strokeWidth: 0
            startX: root.outerCornerRadius
            startY: 0

            PathLine { x: root.fullWidth; y: 0 }
            PathLine { x: root.fullWidth; y: middleBar.height }
            PathLine { x: root.outerCornerRadius; y: middleBar.height }
            PathQuad {
                x: root.middleInnerEdgeX
                y: middleBar.height - root.spacerCurveRadius
                controlX: root.middleInnerEdgeX
                controlY: middleBar.height
            }
            PathLine {
                x: root.middleInnerEdgeX
                y: root.spacerCurveRadius
            }
            PathQuad {
                x: root.outerCornerRadius
                y: 0
                controlX: root.middleInnerEdgeX
                controlY: 0
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.fullWidth
        height: root.height - root.spacerBottom + root.sectionExtension
        color: root.backgroundColor
        topLeftRadius: root.outerCornerRadius
    }
}
