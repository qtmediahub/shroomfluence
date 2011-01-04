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
import confluence.components 1.0
import "../components/"

Window {
    id: root

    PictureInformationSheet { id: pictureInformationSheet }

    PictureSlideShow {
        id: slideShow
        running: false
        pictureModel: pictureEngine.pluginProperties.pictureModel
        anchors.fill: parent
        opacity: 0
        Keys.onPressed:
            if (event.key == Qt.Key_Escape) {
                opacity = 0
                running = false
                event.accepted = true
            }

    }

    function startSlideShow(autoPlay) {
        slideShow.start(viewLoader.item.rootIndex, viewLoader.item.currentIndex)
        slideShow.autoPlay = !!autoPlay
        confluence.showFullScreen(slideShow)
    }

    MediaScanInfo {
        x: 765
        currentPath: pictureEngine.pluginProperties.pictureModel.currentScanPath
    }

    bladeComponent: MediaWindowBlade {
        id: pictureWindowBlade
        parent: root
        visible: true
        actionList: [viewAction, sortByAction, slideShowAction]
        property alias viewAction: viewAction

        resources: [
            // standard actions shared by all views
            ConfluenceAction {
                id: viewAction
                text: qsTr("VIEW")
                options: [qsTr("LIST"), qsTr("BIG LIST"), qsTr("THUMBNAIL"), qsTr("PIC THUMBS"), qsTr("POSTER")]
                onTriggered: root.setCurrentView(currentOption)
            },
            ConfluenceAction {
                id: sortByAction
                text: qsTr("SORT BY")
                options: [qsTr("NAME"), qsTr("SIZE"), qsTr("DATE")]
                onTriggered: pictureEngine.pluginProperties.pictureModel.sort(viewLoader.item.rootIndex, currentOption())
            },
            ConfluenceAction {
                id: slideShowAction
                text: qsTr("SLIDESHOW")
                onTriggered: root.startSlideShow(true /*autoPlay */)
            }]

        onClosed: if (root.visible) viewLoader.forceActiveFocus()
    }

    function setCurrentView(viewType) {
        if (viewType == "THUMBNAIL" || viewType == "PIC THUMBS") {
            viewLoader.sourceComponent = thumbnailView
            viewLoader.item.hidePreview = viewType == "PIC THUMBS"
        } else if (viewType == "LIST" || viewType == "BIG LIST") {
            viewLoader.sourceComponent = listView
            viewLoader.item.hidePreview = viewType == "BIG LIST"
        } else if (viewType == "POSTER") {
            viewLoader.sourceComponent = posterView
        }
        blade.viewAction.currentOptionIndex = blade.viewAction.options.indexOf(viewType)
        config.setValue("picturewindow-currentview", viewType)
    }

    Component {
        id: thumbnailView
        MediaThumbnailView {
            engineName: pictureEngine.name
            engineModel: pictureEngine.pluginProperties.pictureModel
            informationSheet: pictureInformationSheet
        }
    }

    Component {
        id: listView
        MediaListView {
            engineName: pictureEngine.name
            engineModel: pictureEngine.pluginProperties.pictureModel
            informationSheet: pictureInformationSheet
            onItemActivated: root.startSlideShow(false /* autoPlay */)
        }
    }

    Component {
        id: posterView
        MediaPosterView {
            engineName: pictureEngine.name
            engineModel: pictureEngine.pluginProperties.pictureModel
            informationSheet: pictureInformationSheet
            Keys.onDownPressed: { blade.open(); blade.forceActiveFocus() }
        }
    }

    Loader {
        id: viewLoader
        focus: true
        anchors.fill: parent
    }

    Component.onCompleted: {
        pictureEngine.visualElement = root;
        pictureEngine.pluginProperties.pictureModel.setThemeResourcePath(themeResourcePath);
        setCurrentView(config.value("picturewindow-currentview", "LIST"))
    }

    Keys.onRightPressed: { blade.open(); blade.forceActiveFocus() }
}

