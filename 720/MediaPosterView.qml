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
import "../components/"

Item {
    id: root
    anchors.fill: parent

    property variant engineName
    property variant engineModel

    signal itemTriggered(variant filePath)

    BorderImage {
        id: background
        source: themeResourcePath + "/media/ContentPanel2.png"
        anchors.fill: parent
        border.left: 5; border.top: 5
        border.right: 5; border.bottom: 5
    }

    PathView {
        id: pathView
        property alias rootIndex : visualDataModel.rootIndex
        property int delegateWidth : 200
        property int delegateHeight : 200
        property string currentSelectedName : ""
        property string currentSelectedPath : ""
        property int currentSelectedSize : -1

        signal clicked(string filePath)
        signal rootIndexChanged() // this should be automatic, but doesn't trigger :/

        function currentModelIndex() {
            //console.log(currentItem.itemdata.filePath);
            return visualDataModel.modelIndex(currentIndex);
        }

        width: parent.width
        height: 300
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true
        focus: true;
        model : visualDataModel
        pathItemCount: (width+2*delegateWidth)/delegateWidth
        preferredHighlightBegin : 0.5
        preferredHighlightEnd : 0.5

        onClicked: {
            videoPlayer.play(filePath)
        }

        path: Path {
            startX: -pathView.delegateWidth; startY: pathView.height/2.0
            PathAttribute { name: "scale"; value: 1 }
            PathAttribute { name: "z"; value: 1 }
            PathAttribute { name: "opacity"; value: 0.2 }
            PathLine { x: pathView.width/2.5; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.0 }
            PathLine { x: pathView.width/2.0; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.5 }
            PathAttribute { name: "z"; value: 2 }
            PathAttribute { name: "opacity"; value: 1.0 }
            PathLine { x: pathView.width/1.5; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.0 }
            PathLine { x: pathView.width+pathView.delegateWidth; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1 }
            PathAttribute { name: "z"; value: 1 }
            PathAttribute { name: "opacity"; value: 0.2 }
        }
        Keys.onRightPressed: { pathView.incrementCurrentIndex(); }
        Keys.onLeftPressed: { pathView.decrementCurrentIndex(); }

        VisualDataModel {
            id: visualDataModel
            model: engineModel

            delegate : Item {
                property variant itemdata : model
                width: pathView.delegateWidth
                height: pathView.delegateHeight
                clip: true
                scale: PathView.scale
                opacity : PathView.opacity
                z: PathView.z

                // this needs to be fixed but I have no clue how to access current selected item from outside the delegate
                property variant foo : PathView.isCurrentItem ? bar() : undefined

                function bar() {
                    pathView.currentSelectedName = display;
                    pathView.currentSelectedPath = filePath;
                    pathView.currentSelectedSize = (type == "File") ? fileSize : -1;
                }

                BorderImage {
                    id: border
                    anchors.fill: parent
                    source: themeResourcePath + "/media/" + "ThumbBorder.png"
                    border.left: 10; border.top: 10
                    border.right: 10; border.bottom: 10

                    Image {
                        id: backgroundImage
                        anchors.fill: parent
                        source: model.previewUrl
                        anchors.margins: 6

                        Image {
                            id: glassOverlay
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: parent.width*0.7
                            height: parent.height*0.6
                            source: themeResourcePath + "/media/" + "GlassOverlay.png"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent;

                    onClicked: {
                        if (model.hasModelChildren) {
                            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
                            pathView.rootIndexChanged();
                        } else if (model.type == "DotDot") { // FIXME: Make this MediaModel.DotDot when we put the model code in a library
                            visualDataModel.rootIndex = visualDataModel.parentModelIndex();
                            pathView.rootIndexChanged();
                        } else {
                            pathView.currentIndex = index;
                            pathView.clicked(filePath)
                        }
                    }
                }
            }
        }
    }

    ConfluenceText {
        anchors.top:  pathView.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: pathView.currentSelectedName
    }

    ConfluenceText {
        anchors.top:  pathView.bottom
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 15
        font.bold: false
        color: "steelblue"
        text: pathView.currentSelectedSize < 0 ? "" : (pathView.currentSelectedSize/1000000).toFixed(2) + " MB"
    }
}
