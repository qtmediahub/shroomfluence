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
//import "testing"

FocusScope {
    id: confluence

    property string generalResourcePath: backend.resourcePath
    property string themeResourcePath: backend.skinPath + "/confluence/3rdparty/skin.confluence"

    //FIXME: QML const equivalent?
    property variant confluenceEasingCurve: Easing.InQuad
    property variant confluenceAnimationDuration: 350

    property variant selectedEngine
    property variant selectedElement
    property variant videoPlayer
    property variant videoWindow
    property variant qtcube
    property variant browserWindow
    property variant ticker
    property variant weatherWindow

    height: 720; width: 1280
    focus: true
    clip: true

    states: [
        State {
            name: "showingRootBlade"
            PropertyChanges {
                target: mainBlade
                state: "open"
                focus: true
            }
            PropertyChanges {
                target: qtcube
                visible: true
                x: confluence.width - qtcube.width
            }
            PropertyChanges {
                target: ticker
                state: "visible"
            }
            PropertyChanges {
                target: videoPlayer
                state: "background"
            }
            PropertyChanges {
                target: dateTimeHeader
                x: confluence.width - dateTimeHeader.width
                showDate: true
            }
        },
        State {
            name: "showingSelectedElement"
            PropertyChanges {
                target: mainBlade
                state: "closed"
                x: 0
            }
            PropertyChanges {
                target: qtcube
                //FIXME: Gross, use of createComponent prevents
                //x: from tracking confluence.width
                //I wish I had a choice
                x: confluence.width
                visible: true
            }
            PropertyChanges {
                target: dateTimeHeader
                x: confluence.width - dateTimeHeader.width
                showDate: false
            }
            PropertyChanges {
                target: weatherHeader
                opacity: 0
            }
            PropertyChanges {
                target: homeHeader
                opacity: 1
            }
            PropertyChanges {
                target: currentContextHeader
                opacity: 1
            }
            PropertyChanges {
                target: selectedElement
                state: "visible"
            }
            PropertyChanges {
                target: videoPlayer
                state: "background"
            }
            StateChangeScript { script: selectedElement.forceActiveFocus() }
        },
        State {
            name: "showingSelectedElementMaximized"
            extend: "showingSelectedElement"
            PropertyChanges {
                target: mainBlade
                state: "hidden"
            }
            PropertyChanges {
                target: selectedElement
                state: "maximized"
            }
            PropertyChanges {
                target: videoPlayer
                state: selectedElement == transparentVideoOverlay ? "maximized" : "hidden"
            }
            PropertyChanges {
                target: dateTimeHeader
                opacity: 0
            }
            StateChangeScript { script: selectedElement.forceActiveFocus() }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "showingRootBlade"
            NumberAnimation { targets: [qtcube, dateTimeHeader]; properties: "x,y"; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration }
            SequentialAnimation {
                NumberAnimation { target: dateTimeHeader; properties: "x"; to: confluence.width; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration/2 }
                PropertyAction { target: dateTimeHeader; property: "showDate"; value: true }
                NumberAnimation { target: dateTimeHeader; properties: "x"; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration/2 }
                PropertyAction { target: weatherHeader; property: "opacity"; value: 1 }
            }
        },
        Transition {
            from: "*"
            to: "showingSelectedElement"
            NumberAnimation { target: qtcube; properties: "x,y"; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration }
            SequentialAnimation {
                NumberAnimation { target: mainBlade; properties: "x"; to: -mainBlade.width - mainBlade.closedBladePeek; duration: confluenceAnimationDuration/2; easing.type: confluenceEasingCurve }
                PropertyAction { target: homeHeader; property: "opacity"; value: 1 }
            }
            SequentialAnimation {
                NumberAnimation { target: dateTimeHeader; properties: "x"; to: confluence.width; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration/2 }
                PropertyAction { target: dateTimeHeader; property: "showDate"; value: false }
                NumberAnimation { target: dateTimeHeader; properties: "x"; easing.type: confluenceEasingCurve; duration: confluenceAnimationDuration/2 }
            }
        }
    ]

    Keys.onPressed: {
        if(event.key == Qt.Key_Escape) {
            if(selectedElement && selectedElement.maximized)
                selectedElement.maximized = false
            else if(confluence.state == "showingRootBlade" && !!selectedElement)
                show(selectedElement)
            else
                show(mainBlade)
        } else if(event.key == Qt.Key_F12)
            selectedElement && state == "showingSelectedElement" && selectedElement.maximizable && (selectedElement.maximized = true);
        else if(event.key == Qt.Key_F11) {
            showModal(aboutDialogComponent)
        }
    }

    //FIXME: function failing here simply skips rest of init, wish they had exceptions
    Component.onCompleted: {
        //Create items which may or may not be present
        var customCursorLoader = Qt.createComponent("../components/Cursor.qml")
        if (customCursorLoader.status == Component.Ready)
            customCursorLoader.createObject(confluence)
        else if (customCursorLoader.status == Component.Error)
            backend.log(customCursorLoader.errorString())

        musicEngine.pluginProperties.musicModel.setThemeResourcePath(themeResourcePath); // ## Shouldn't be here
        var musicWindowLoader = Qt.createComponent("MusicWindow.qml")
        if (musicWindowLoader.status == Component.Ready) {
            var musicWindow = musicWindowLoader.createObject(confluence)
            musicWindow.z = background.z + 2
        } else if (musicWindowLoader.status == Component.Error)
            backend.log(musicWindowLoader.errorString())

        //FIXME: function failing here simply skips rest of init, wish they had exceptions
        videoEngine.pluginProperties.videoModel.setThemeResourcePath(themeResourcePath); // ## Shouldn't be here
        var videoWindowLoader = Qt.createComponent("VideoWindow.qml")
        if (videoWindowLoader.status == Component.Ready) {
            videoWindow = videoWindowLoader.createObject(confluence)
            videoWindow.z = background.z + 2
        } else if (videoWindowLoader.status == Component.Error)
            backend.log(videoWindowLoader.errorString())

        pictureEngine.pluginProperties.pictureModel.setThemeResourcePath(themeResourcePath); // ## Shouldn't be here
        var pictureWindowLoader = Qt.createComponent("PictureWindow.qml")
        if (pictureWindowLoader.status == Component.Ready) {
            var pictureWindow = pictureWindowLoader.createObject(confluence)
            pictureWindow.z = background.z + 2
        } else if (pictureWindowLoader.status == Component.Error)
            backend.log(pictureWindowLoader.errorString())

        var videoPlayerComponent = Qt.createComponent("VideoPlayer.qml");
        if (videoPlayerComponent.status == Component.Ready) {
            videoPlayer = videoPlayerComponent.createObject(confluence)
            // FIXME: nothing to get video-path during runtime, yet
            videoPlayer.state = "hidden"
        } else if (videoPlayerComponent.status == Component.Error) {
            backend.log(videoPlayerComponent.errorString())
            videoPlayer = dummyItem
        }

        var dashboardLoader = Qt.createComponent("DashboardWindow.qml");
        if (dashboardLoader.status == Component.Ready) {
            var dashboard = dashboardLoader.createObject(confluence)
            dashboard.z = background.z + 2
        } else if (dashboardLoader.status == Component.Error) {
            backend.log(dashboardLoader.errorString())
        }

        //No webkit
        var webLoader = Qt.createComponent("WebWindow.qml");
        if (webLoader.status == Component.Ready) {
            browserWindow = webLoader.createObject(confluence)
            browserWindow.z = background.z + 2
        } else if (webLoader.status == Component.Error) {
            backend.log(webLoader.errorString())
        }

        //No XML patterns
        var weatherLoader = Qt.createComponent("WeatherWindow.qml");
        if (weatherLoader.status == Component.Ready) {
            weatherWindow = weatherLoader.createObject(confluence)
            weatherWindow.z = background.z = 2
        } else if (weatherLoader.status == Component.Error) {
            backend.log(weatherLoader.errorString())
        }

        var tickerLoader = Qt.createComponent("Ticker.qml");
        if (tickerLoader.status == Component.Ready) {
            ticker = tickerLoader.createObject(confluence)
            ticker.anchors.top = confluence.bottom
            ticker.anchors.topMargin = 0
            ticker.z = background.z + 1
            ticker.anchors.right = confluence.right
        } else if (tickerLoader.status == Component.Error) {
            backend.log(tickerLoader.errorString())
            ticker = dummyItem
        }

        //no qt3d
        var qtCubeLoader = Qt.createComponent(generalResourcePath + "/misc/cube/cube.qml")
        if (qtCubeLoader.status == Component.Ready) {
            qtcube = qtCubeLoader.createObject(confluence)
            qtcube.anchors.top = confluence.top
            qtcube.z = background.z + 1
            qtcube.visible = false
        } else if (qtCubeLoader.status == Component.Error) {
            backend.log(qtCubeLoader.errorString())
            qtcube = dummyItem
        }

        var remoteAppLoader = Qt.createComponent("RemoteAppWindow.qml");
        if (remoteAppLoader.status == Component.Ready) {
            remoteAppLoader.createObject(confluence)
        } else if (remoteAppLoader.status == Component.Error) {
            backend.log(remoteAppLoader.errorString())
        }

        var systemInfoLoader = Qt.createComponent("SystemInfoWindow.qml");
        if (systemInfoLoader.status == Component.Ready) {
            var systemInfoWindow = systemInfoLoader.createObject(confluence)
            systemInfoWindow.z = background.z + 2
        } else if (systemInfoLoader.status == Component.Error) {
            backend.log(systemInfoLoader.errorString())
        }

        //Why would you ever want to do this from QML!
        //One property API FTW
        var screensaverLoader = Qt.createComponent("ScreenSaver.qml");
        if (screensaverLoader.status == Component.Ready) {
            var screensaver = screensaverLoader.createObject(confluence)
            !!screensaver ? screensaver.screenSaverDelayed = true : undefined
        } else if (screensaverLoader.status == Component.Error) {
            backend.log(screensaverLoader.errorString())
        }

        confluence.show(mainBlade)
    }

    function setActiveEngine(engine)
    {
        selectedEngine = engine
        selectedElement = engine.visualElement
        var elementProperties = engine.visualElementProperties
        for(var i = 0; i + 2 <= elementProperties.length; i += 2)
            selectedElement[elementProperties[i]] = elementProperties[i+1]
        show(selectedElement)
    }

    function show(element)
    {
        if (element == mainBlade) {
            state = "showingRootBlade"
        } else if(element == videoPlayer) {
            if(videoPlayer.video.source == "") {
                show(videoWindow)
            } else {
                show(transparentVideoOverlay)
            }
        } else if (element == transparentVideoOverlay) {
            selectedElement = transparentVideoOverlay
            state = "showingSelectedElementMaximized"
            videoPlayer.play()
        } else {
            selectedElement = element
            state = "showingSelectedElement"
        }
    }

    // dummyItem useful to avoid error ouput on component loader failures
    Item {
        id: dummyItem
        visible: false
    }

    Background {
        id: background
        anchors.fill: parent;
        z: 1
        visible: !(!!videoPlayer.video && videoPlayer.video.playing)
    }

    MainBlade { 
        id: mainBlade; 
        focus: true 
        z: background.z + 1
        onClicked: confluence.show(mainBlade)
    }

    Header {
        id: homeHeader
        flip : false

        anchors { top: confluence.top; left: confluence.left }
        z: currentContextHeader.z + 1
        width: homeImage.width + 80
        opacity: 0
        Image {
            id: homeImage
            x: 40
            sourceSize { width: height; height: homeHeader.height-4; }
            source: themeResourcePath + "/media/HomeIcon.png"
            MouseArea { anchors.fill: parent; onClicked: confluence.state = "showingRootBlade" }
        }
    }

    Header {
        id: currentContextHeader
        flip: false

        width: contextText.width + 50
        anchors { top: homeHeader.top; left: homeHeader.right; leftMargin: -25 }
        z: background.z + 1
        opacity: 0
        Text { 
            x: 25
            id: contextText 
            anchors.verticalCenter: parent.verticalCenter
            text: selectedEngine ? selectedEngine.name : ""; color: "white"
        }
    }

    DateTimeHeader {
        id: dateTimeHeader
        z: weatherHeader.z + 1
        x: confluence.width
        anchors.top: confluence.top
    }

    WeatherHeader {
        id: weatherHeader
        z: background.z + 1
        x: confluence.width
        anchors.top: confluence.top
        anchors.right: dateTimeHeader.left
        anchors.rightMargin: -25;
        city: weatherWindow.city

        MouseArea {
            anchors.fill: parent
            onClicked: confluence.show(weatherWindow)
        }
    }

    Component {
        id: aboutDialogComponent
        AboutDialog { }
    }

    Rectangle {
        id: mouseGrabber
        color: "black"
        anchors.fill: parent;
        z: mainBlade.z + 1
        opacity: 0

        Behavior on opacity {
            NumberAnimation { }
        }

        MouseArea {
            anchors.fill: parent;
            hoverEnabled: true
        }
    }

    Window {
        id: transparentVideoOverlay
        onFocusChanged:
            activeFocus ? videoPlayer.forceActiveFocus() : undefined
    }

    function showContextMenu(item, x, y) {
        mouseGrabber.opacity = 0.9
        item.closed.connect(function() { mouseGrabber.opacity = 0 })
        item.parent = confluence // ## restore parent?
        item.z = background.z + 2
        item.x = x
        item.y = y
        item.opacity = 1
    }

    function showModal(component) {
        var item = component.createObject(mouseGrabber)
        mouseGrabber.opacity = 0.9 // FIXME: this should probably become a confluence state
        item.closed.connect(function() { mouseGrabber.opacity = 0; delete item })
        item.open()
        return item
    }

    function showFullScreen(item) {
        item.z = background.z + 2
        item.parent = confluence
        item.opacity = 1
        item.forceActiveFocus()
    }
}

