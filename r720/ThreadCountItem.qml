import QtQuick 2.5
import "components/"

Rectangle {
    id: root
    property int threadCount: -1
    color: "red"
    z: 1000
    width: childrenRect.width; height: childrenRect.height
    anchors { top: dateTimeHeader.bottom; right: fpsItem.left }
    visible: threadCount != -1
    ConfluenceText {
        id: fpsText
        animated: false
        text: "Threads:" + root.threadCount
        font.pixelSize: 60
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.threadCount = metrics.threadCount()
        }
    }
}
