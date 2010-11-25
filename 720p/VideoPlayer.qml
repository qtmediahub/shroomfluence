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

import QtQuick 1.0
import QtMultimediaKit 1.1
import "components"

//This serves to isolate import failures if QtMultimedia is not present
FocusScope {
    id: root

    property alias video : videoItem

    anchors.fill: parent

    Keys.onEscapePressed: {
        if (controlOSD.state != "visible") {
            showOSD();
            event.accepted = true;
        } else {
            confluence.state = "showingRootMenu"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPositionChanged: showOSD();
        onClicked: videoItem.togglePlayPause();
    }

    Timer {
        id: osdTimer
        interval: 3000
        running: (controlOSD.state == "visible" || infoOSD.state == "visible")

        repeat: false
        onTriggered: {
            controlOSD.state = "";
            infoOSD.state = "";
        }
    }

    Video {
        id: videoItem
        anchors.fill: parent

        function togglePlayPause() {
            if (Math.abs(videoItem.playbackRate) != 1) {
                videoItem.play()
                videoItem.playbackRate = 1
            } else {
                if (!videoItem.playing || videoItem.paused) {
                    videoItem.play()
                    videoItem.playbackRate = 1
                } else {
                    videoItem.pause()
                    videoItem.playbackRate = 1
                }
            }
        }
    }

    VideoPlayerControlOSD {
        id: controlOSD
    }

    VideoPlayerInfoOSD {
        id: infoOSD
    }

    states: [
        State {
            name: "background"
            PropertyChanges {
                target: root
                opacity: 1
                z: 0
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                opacity: 0
                z: -1
            }
        },
        State {
            name: "maximized"
            PropertyChanges {
                target: root
                opacity: 1
                z: 5000
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { property: "opacity"; duration: confluenceAnimationDuration; easing.type: confluenceEasingCurve }
            PropertyAnimation { target: controlOSD; property: "state"; to: "" }
            PropertyAnimation { target: infoOSD; property: "state"; to: "" }
        }
    ]

    function showOSD() {
        if (root.state == "maximized") {
            controlOSD.state = "visible";
            infoOSD.state = "visible";
        }
    }
}
