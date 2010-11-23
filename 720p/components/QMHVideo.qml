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

//This serves to isolate import failures if QtMultimedia is not present
Video {
    id: root

    anchors.fill: parent

    PixmapButton {
        id: visibleButton
        anchors.centerIn: parent
        basePixmap: "OSDBookmarksNF"
        focusedPixmap: "OSDBookmarksFO"
        onClicked: { controlOSD.state = "visible"; infoOSD.state = "visible" }
    }


    PixmapButton {
        anchors.left: visibleButton.right
        anchors.top: visibleButton.top
        basePixmap: "OSDBookmarksNF"
        focusedPixmap: "OSDBookmarksFO"
        onClicked: { controlOSD.state = ""; infoOSD.state= ""; }
    }

    BorderImage {
        id: controlOSD
        source: themeResourcePath + "/media/MediaInfoBackUpper.png"

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -controlOSD.height

        ButtonList {
            id: controlOSDButtonList
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            PixmapButton { basePixmap: "OSDBookmarksNF"; focusedPixmap: "OSDBookmarksFO" }
            PixmapButton { basePixmap: "OSDAudioNF"; focusedPixmap: "OSDAudioFO" }
            PixmapButton { basePixmap: "OSDVideoNF"; focusedPixmap: "OSDVideoFO" }
            PixmapButton { basePixmap: "OSDPrevTrackNF"; focusedPixmap: "OSDPrevTrackFO" }
            PixmapButton { basePixmap: "OSDRewindNF"; focusedPixmap: "OSDRewindFO" }
            PixmapButton { basePixmap: "OSDPauseNF"; focusedPixmap: "OSDPauseFO"; onClicked: root.pause();}
            PixmapButton { basePixmap: "OSDPlayNF"; focusedPixmap: "OSDPlayFO"; onClicked: root.play(); }
            PixmapButton { basePixmap: "OSDForwardNF"; focusedPixmap: "OSDForwardFO" }
            PixmapButton { basePixmap: "OSDNextTrackNF"; focusedPixmap: "OSDNextTrackFO" }
            PixmapButton { basePixmap: "OSDDvdNF"; focusedPixmap: "OSDDvdFO" }
            PixmapButton { basePixmap: "OSDRecordNF"; focusedPixmap: "OSDRecordFO" }
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: controlOSD.anchors
                    topMargin: -controlOSD.height + controlOSDButtonList.height + controlOSDButtonList.anchors.bottomMargin
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { property: "topMargin"; duration: 500; easing.type: Easing.InOutQuad }
            }
        ]
    }

    BorderImage {
        id: infoOSD
        source: themeResourcePath + "/media/InfoMessagePanel.png"

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -infoOSD.height

        width: 450
        height: 100

        border { left: 30; top: 30; right: 30; bottom: 30 }

        Row {
            width: childrenRect.width
            height: childrenRect.height
            anchors.centerIn: parent

            Column {
                anchors.verticalCenter: seekOSD.verticalCenter

                Text {
                    text: root.paused ? "Paused" : "Playing"
                    color: "steelblue"
                }
                Text {
                    text: root.ms2string(root.position) + " - " + root.ms2string(root.duration)
                    color: "white"
                }
                ProgressBar {
                    width: 200
                    mProgress: root.position/root.duration
                }
            }

            Item {
                id: seekOSD
                width: childrenRect.width
                height: childrenRect.height

                Image {
                    id: seekOSDRewind
                    source:  themeResourcePath + "/media/OSDSeekRewind.png"
                    anchors.left: parent.left
                    anchors.verticalCenter: seekOSDCentral.verticalCenter
                }

                Image {
                    id: seekOSDCentral
                    source:  themeResourcePath + "/media/OSDSeekFrame.png"
                    anchors.left: seekOSDRewind.right
                    anchors.leftMargin: -10
                    anchors.top: parent.top
                }

                Image {
                    id: seekOSDForward
                    source:  themeResourcePath + "/media/OSDSeekForward.png"
                    anchors.left: seekOSDCentral.right
                    anchors.leftMargin: -10
                    anchors.verticalCenter: seekOSDCentral.verticalCenter
                }

                Image {
                    source:  root.paused ? themeResourcePath + "/media/OSDPause.png" : themeResourcePath + "/media/OSDPlay.png"
                    anchors.centerIn: seekOSDCentral
                }
            }
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: infoOSD.anchors
                    bottomMargin: -5
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { property: "bottomMargin"; duration: 500; easing.type: Easing.InOutQuad }
            }
        ]
    }

    function ms2string(ms)
    {
        var ret = "";

        if (ms == 0)
            return "00:00:00";

        var h = (ms/(1000*60*60)).toFixed(0);
        var m = ((ms%(1000*60*60))/(1000*60)).toFixed(0);
        var s = (((ms%(1000*60*60))%(1000*60))/1000).toFixed(0);

        if (h >= 1) {
            ret += h < 10 ? "0" + h : h + "";
            ret += ":";
        }

        ret += m < 10 ? "0" + m : m + "";
        ret += ":";
        ret += s < 10 ? "0" + s : s + "";

        return ret;
    }
}
