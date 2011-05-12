/****************************************************************************
**
** This file is part of Weather
**
** Copyright (c) 2010 Nokia Corporation and/or its subsidiary(-ies).*
** All rights reserved.
** Contact:  Nokia Corporation (qt-info@nokia.com)
**
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in the
**     documentation and/or other materials provided with the distribution.
**
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
**  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
**  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
**  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
**  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
**  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
**  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
**  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
**  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
**  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
**  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
**  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
**  POSSIBILITY OF SUCH DAMAGE."
**
****************************************************************************/

import Qt 4.7

Item {
    id: root

    property string currentTemperature
    property string currentHumidity
    property string currentWindCondition
    property string folder: "../../images/"

    Row {
        anchors.bottomMargin: 58
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: line.horizontalCenter

        Text {
            id: temperatureText
            text: currentTemperature
            font.family: "Nokia Sans"
            font.pixelSize: 170
            font.bold: true
            color: "white"
        }

        Image {
            source: folder + "centigrades.png"
            anchors.bottom: temperatureText.bottom
            anchors.bottomMargin: 34
        }
    }

    Image {
        id: line
        source: folder + "division_line.png"
        anchors.top: parent.top
        anchors.topMargin: 104
        anchors.left: parent.left
        anchors.leftMargin: 50
    }

    Column {
        anchors.top: line.bottom

        Text {
            text: currentHumidity
            font.family: "Nokia Sans"
            font.pixelSize: 32
            font.bold: true
            color: "white"
        }

        Text {
            text: currentWindCondition
            font.family: "Nokia Sans"
            font.pixelSize: 32
            font.bold: true
            color: "white"
        }
    }
}