import QtQuick 1.1
import Qt.labs.shaders 1.0
import Qt.labs.shaders.effects 1.0

Item {
    id: root

    function start() {
        splashDelay.start()
    }

    function play() {
        topWidthAnim.running = true
    }

    signal finished

    anchors.fill: parent

    onWidthChanged: {
        curtain.animated = false
        settleTimer.start()
    }

    Timer {
        id: splashDelay
        interval: runtime.config.value("splash-lead-time", 500)
        onTriggered:
            confluenceEntry.load()
    }

    Timer {
        id: settleTimer
        interval: 1
        onTriggered:
            curtain.animated = true
    }

    Image {
        id: splash
        anchors.fill: parent
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: "../3rdparty/splash/splash.jpg"
    }

    CurtainEffect {
        id: curtain
        property bool animated: false
        anchors.fill: splash
        bottomWidth: topWidth
        topWidth: parent.width
        source: ShaderEffectSource { sourceItem: splash; hideSource: true }

        Behavior on topWidth {
            enabled: curtain.animated
            SequentialAnimation {
                PropertyAnimation { duration: 1000 }
                PauseAnimation { duration: 2000 }
                ScriptAction { script: root.finished() }
            }
        }

        Behavior on bottomWidth {
            enabled: curtain.animated
            SpringAnimation { easing.type: Easing.OutElastic; velocity: 1500; mass: 1.5; spring: 0.5; damping: 0.15}
        }

        SequentialAnimation on topWidth {
            id: topWidthAnim
            loops: 1
            running: false

            NumberAnimation { to: root.width - 50; duration: 700 }
            PauseAnimation { duration: 500 }
            NumberAnimation { to: root.width + 50; duration: 700 }
            PauseAnimation { duration: 500 }
            ScriptAction { script: curtain.topWidth = 0; }
        }

    }
}
