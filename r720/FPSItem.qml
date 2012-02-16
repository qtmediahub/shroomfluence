import QtQuick 2.0
import "components/"

Rectangle {
    id: root
    property bool descriptive: false
    property int fpsCount
    color: "black"
    z: 1000
    width: childrenRect.width; height: childrenRect.height
    anchors { top: dateTimeHeader.bottom; right: confluence.right }
    visible: fpsCount != -1
    ConfluenceText {
        id: fpsText
        animated: false
        text: "FPS:" + root.fpsCount
        font.pixelSize: 60
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.fpsCount = metrics.swaplogFPS()
        }
    }
}
