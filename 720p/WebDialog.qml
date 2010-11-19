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
import QtWebKit 1.0
import "components"

Dialog {
    id: webDialog
    property alias url: webView.url
    property string defaultUrl: "http://www.google.com"

    transitions: Transition {
        to: "visible"
        ParallelAnimation {
            NumberAnimation { property: "opacity"; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { property: "width"; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { property: "height"; duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    function onVisibleTransitionComplete() {
        webView.forceActiveFocus()
    }

    function loadPage(url) {
        webView.url = url
        webViewport.contentY = 0

        confluence.selectedElement = webDialog
        confluence.state = "showingSelectedElement"
    }

    Flickable {
        id: webViewport
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection:  Flickable.VerticalFlick
        //revolting magical numbers, god bless non symmetrical pixmaps
        width: webDialog.width - 60; height: webDialog.height - 40
        contentWidth: webView.width; contentHeight: webView.height
        anchors.centerIn: parent
        WebView {
            id: webView
            anchors.centerIn: parent
            url: defaultUrl
        }
    }

    Engine { name: "Web"; role: "web"; visualElement: webDialog; visualElementProperties: ["url", defaultUrl] }
    Engine { name: "Maps"; role: "maps"; visualElement: webDialog; visualElementProperties: ["url", generalResourcePath + "/Google\ Maps/Nokia.html"] }
}
