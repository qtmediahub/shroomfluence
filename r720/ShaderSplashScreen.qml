import QtQuick 2.5

import Qt.labs.shaders.effects 2.0

Item {
    id: root

    opacity: 1

    function start() {}

    function play() {
        root.opacity = 0
    }

    signal finished

    anchors.fill: parent

    ShaderEffectSource {
        id: viewSource
        sourceItem: splash
        live: false
        hideSource: true
    }

    RadialWaveEffect {
        id: waveLayer
        visible: true
        anchors.fill: parent;
        source: viewSource

        wave: 0.0
        waveOriginX: 0.5
        waveOriginY: 0.5
        waveWidth: 0.01

        NumberAnimation on wave {
            id: waveAnim
            running: waveLayer.visible
            easing.type: "InQuad"
            from: 0.0000; to: 0.2000;
            duration: 1500
        }
    }

    Rectangle {
        id: splash
        width: root.width; height: root.height
        color: "black"

        Image {
            anchors.centerIn: parent
            source: "../3rdparty/skin.confluence/media/Confluence_Logo.png"
            asynchronous: false
        }
    }

    Component.onCompleted:
        splashDelay.start()

    Timer {
        id: splashDelay
        interval: 1500
        onTriggered:
            confluenceEntry.load()
    }

    Behavior on opacity {
        SequentialAnimation {
            ScriptAction { script: waveLayer.visible = false }
            PauseAnimation { duration: 500 }
            PropertyAnimation{ duration: 1000 }
        }
    }
    onOpacityChanged:
        if(root.opacity == 0)
            root.finished()
}
