pragma ComponentBehavior: Bound

import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import "../generics" as Generics

Generics.PopupSection {
    id: root

    property PwNode sink
    property color barColor: "white"
    property color accentColor: "gray"
    property color labelColor: "white"
    property color panelColor: "black"
    title: "Audio visualizer"
    titleColor: labelColor
    showCount: false
    expanded: false

    Loader {
        width: parent.width
        height: active ? 140 : 0
        visible: active
        active: root.expanded && root.visible && (root.Window.window?.visible ?? false)

        sourceComponent: Item {
            id: spectrum
            property var levels: []
            property string status: "Waiting for audio…"
            property double lastFrame: 0
            readonly property string targetName: root.sink?.name || ""
            readonly property bool captureActive: visible && root.sink?.ready === true && targetName !== ""

            function startCapture() {
                levels = []
                status = captureActive ? "Waiting for audio…" : "No audio output"
                if (captureActive) {
                    const config = decodeURIComponent(Qt.resolvedUrl("../../config/cava-visualizer.conf").toString().replace(/^file:\/\//, ""))
                    capture.exec(["cava", "-p", config])
                } else {
                    capture.running = false
                }
            }

            onCaptureActiveChanged: startCapture()
            onTargetNameChanged: startCapture()
            Component.onCompleted: startCapture()

            Process {
                id: capture
                stdout: SplitParser {
                    onRead: data => {
                        try {
                            const values = data.trim().split(";").filter(value => value !== "").map(Number)
                            if (values.length === 32 && values.every(value => Number.isFinite(value) && value >= 0 && value <= 1000)) {
                                const frame = values.map(value => value / 1000)
                                spectrum.levels = frame
                                spectrum.lastFrame = Date.now()
                                spectrum.status = frame.some(value => value > 0.01) ? "" : "Waiting for audio…"
                            }
                        } catch (error) {
                            spectrum.status = "Audio visualizer unavailable"
                        }
                    }
                }
                onExited: {
                    spectrum.levels = []
                    if (spectrum.captureActive)
                        spectrum.status = "CAVA audio capture unavailable"
                }
            }

            Timer {
                interval: 2000
                running: spectrum.captureActive && !capture.running
                repeat: true
                onTriggered: spectrum.startCapture()
            }

            Timer {
                interval: 250
                running: spectrum.captureActive
                repeat: true
                onTriggered: {
                    if (spectrum.lastFrame > 0 && Date.now() - spectrum.lastFrame > 500) {
                        spectrum.levels = []
                        spectrum.status = "Waiting for audio…"
                    }
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 108
                spacing: 4

                Repeater {
                    model: 32
                    delegate: Item {
                        id: bar
                        required property int index
                        width: Math.max(1, (spectrum.width - 31 * 4) / 32)
                        height: 108
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: Math.max(2, (spectrum.levels[bar.index] || 0) * parent.height)
                            radius: 2
                            gradient: Gradient {
                                GradientStop { position: 0; color: root.accentColor }
                                GradientStop { position: 1; color: root.barColor }
                            }
                            Behavior on height { NumberAnimation { duration: 65 } }
                        }
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: spectrum.status || "Current output audio"
                color: root.labelColor
                font.family: root.fontName
                font.pixelSize: 14
                elide: Text.ElideRight
            }
        }
    }
}
