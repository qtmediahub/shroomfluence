/****************************************************************************

This file is part of the QtMediaHub project on http://www.gitorious.org.

Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).*
All rights reserved.

Contact:  Nokia Corporation (qt-info@nokia.com)**

You may use this file under the terms of the BSD license as follows:

"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

****************************************************************************/

import QtQuick 1.1
import QtMobility.location 1.2
import "components/"

Window {
    id: root
    anchors.fill: parent
    maximizable: true
    focalWidget: panel

    resources: [
        // standard actions
        ConfluenceAction {
            id: viewAction
            text: qsTr("VIEW")
            options: [qsTr("Street View"), qsTr("Satellite View")]
            onTriggered: root.setCurrentView(currentOption)
        },
        ConfluenceAction {
            id: zoomInAction
            text: qsTr("ZOOM IN")
            onTriggered: map.zoomLevel = map.zoomLevel + 1
        },
        ConfluenceAction {
            id: zoomOutAction
            text: qsTr("ZOOM OUT")
            onTriggered: map.zoomLevel = map.zoomLevel - 1
        }]

    Panel {
        id: panel
        decorateFrame: !root.maximized
        anchors.fill: parent
        anchors.margins: 50
        focus: true

        Map {
            id: map
            anchors.fill: parent

            plugin : Plugin {
                name : "nokia"
            }
            mapType: Map.StreetMap

            ContextMenu {
                id: contextMenu
                title: qsTr("Actions")
                model: [viewAction, zoomInAction, zoomOutAction]
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool mouseDown : false
            property int lastX : -1
            property int lastY : -1

            onPressed : {
                mouseDown = true
                lastX = mouse.x
                lastY = mouse.y
            }
            onReleased : {
                mouseDown = false
            }
            onPositionChanged: {
                if (mouseDown) {
                    var dx = mouse.x - lastX
                    var dy = mouse.y - lastY
                    map.pan(-dx, -dy)
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
            onClicked: {
                if (mouse.button == Qt.RightButton) {
                    var scenePos = panel.mapToItem(null, mouseX, mouseY)
                    confluence.showContextMenu(contextMenu, scenePos.x, scenePos.y)
                }
            }
        }

        Keys.onPressed: {
            event.accepted = true
            if (event.key == Qt.Key_PageDown) {
                map.zoomLevel = map.zoomLevel - 1
            } else if (event.key == Qt.Key_PageUp) {
                map.zoomLevel = map.zoomLevel + 1
            } else {
                event.accepted = false
            }
        }

        Keys.EnterPressed: root.blade.open()
        Keys.onUpPressed: map.pan(0, -100)
        Keys.onDownPressed: map.pan(0, 100)
        Keys.onLeftPressed: map.pan(-100, 0)
        Keys.onRightPressed: map.pan(100, 0)
    }

    bladeComponent: MediaWindowBlade {
        id: mapsWindowBlade
        parent: root
        visible: true
        actionList: [viewAction, zoomInAction, zoomOutAction]
    }

    function setCurrentView(viewType) {
        if (viewType == qsTr("Satellite View")) {
            map.mapType = Map.SatelliteMapDay
        } else if (viewType == qsTr("Street View")) {
            map.mapType = Map.StreetMap
        }
        runtime.config.setValue("mapwindow-currentview", viewType)
    }

    Component.onCompleted: {
        setCurrentView(runtime.config.value("mapwindow-currentview", qsTr("Street View")))
    }
}
