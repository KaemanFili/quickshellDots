import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

// An empty click mask prevents the window from blocking mouse events.
//mask: Region {}

//we might want to change this to allow to go up to the actual max output, but I'm fine with 100 for right now.
//also might want to allow for changing devices from here. I'm not to bothered about that right now
//this also maps to the default device. Not anything else. We should really be able to set default here to make sure that we can adjust audio

Item{
    id: audioConfig 

    implicitWidth: 400
	implicitHeight: 200

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode mic:  Pipewire.defaultAudioSource

    readonly property string headphonesIcon: ""
    readonly property string micIcon: "󰍬"
    readonly property string volumeIcon: ""

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
    }

    Connections {
        target: Pipewire.defaultAudioSink
    }
    Connections {
        target: Pipewire.defaultAudioSource
    }
    function isAudioSourceNode(n) {
        return (n.type & PwNodeType.AudioSource) === PwNodeType.AudioSource
    }
    function isAudioSinkNode(n) {
        return (n.type & PwNodeType.AudioSink) === PwNodeType.AudioSink
    }
    function safeVolume(node) {
        const v = node?.audio?.volume
        if (!Pipewire.ready || !node?.ready) return 0
        if (v === null || Number.isNaN(v)) return 0
        return v
    }
    function setVolume(node, x){
        if(x<=1){
             node.audio.volume = x
        }
    }
    function getDisplayVolume(node){
       return Math.ceil(safeVolume(node) * 100)    
    }

    Rectangle {
        anchors.fill: parent
        radius: height/ 2
        color: backgroundColor
        width: parent.width
        ColumnLayout {
            anchors.fill: parent
            Text { 
                text: "Audio"
                color: primaryColor
                font.family: fontFamily
                font.pixelSize: 20
                font.bold: true 
                style: Text.Outline
                styleColor: textBorderColor
            }
            Text {
                text: audioConfig.headphonesIcon + " " +audioConfig.sink?.description + " : " + audioConfig.getDisplayVolume(Pipewire.defaultAudioSink) + "%"
            }
            RowLayout {
                spacing: 8
                width: parent.width

                Text {
                    minimumPixelSize:30
                    text: audioConfig.volumeIcon
                }

                Rectangle {
                    id: sinkSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 10   // IMPORTANT
                    radius: 20
                    color: backgroundColor
                    clip: true                  // optional, but nice

                    readonly property string sinkVolume: audioConfig.safeVolume(Pipewire.defaultAudioSink)

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        color: primaryColor

                        width: parent.width * sinkSlider.sinkVolume
                        radius: parent.radius
                        clip: true
                    }
                    Rectangle {
                        id: knob
                        width: 18
                        height: 18
                        radius: 9
                        color: secondaryColor
                        anchors.verticalCenter: parent.verticalCenter

                        // correct knob position
                        x: (sinkSlider.width - width) * sinkSlider.sinkVolume

                        z: 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (m) => {audioConfig.setVolume(Pipewire.defaultAudioSink,m.x/parent.width)}
                        onPositionChanged: (m) => {
                            if(pressed){
                                audioConfig.setVolume(Pipewire.defaultAudioSink, m.x/parent.width)
                            }
                        }
                    }

                }
                
            }
            Text {
                text: audioConfig.micIcon + " " +audioConfig.mic?.nickname + " : " + audioConfig.getDisplayVolume(Pipewire.defaultAudioSource) + "%"
            }
            RowLayout {
                spacing: 8
                width: parent.width

                Text {
                    minimumPixelSize:30
                    text: audioConfig.volumeIcon
                }

                Rectangle {
                    id: micSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 10   // IMPORTANT
                    radius: 20
                    color: backgroundColor
                    clip: true                  // optional, but nice

                    readonly property string sourceVolume: audioConfig.safeVolume(Pipewire.defaultAudioSource)

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        color: primaryColor

                        width: parent.width * micSlider.sourceVolume
                        radius: parent.radius
                        clip: true
                    }
                    Rectangle {
                        id: micKnob
                        width: 18
                        height: 18
                        radius: 9
                        color: secondaryColor
                        anchors.verticalCenter: parent.verticalCenter

                        // correct knob position
                        x: (micSlider.width - width) * micSlider.sourceVolume

                        z: 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (m) => {audioConfig.setVolume(Pipewire.defaultAudioSource,m.x/parent.width)}
                        onPositionChanged: (m) => {
                            if(pressed){
                                audioConfig.setVolume(Pipewire.defaultAudioSource, m.x/parent.width)
                            }
                        }
                    }

                }
                
            }
        }
    }

}