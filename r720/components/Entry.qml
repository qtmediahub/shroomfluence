/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project on Qt Labs.
**
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions contained
** in the Technology Preview License Agreement accompanying this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import QtQuick 1.1

Item {
    id: root
    property string hint: "Entry"
    property alias text: textInp.text
    property alias leftIconSource: leftIcon.source
    property alias rightIconSource: rightIcon.source
    signal rightIconClicked
    signal leftIconClicked
    signal enterPressed

    width: (hintText.state=='hinting'?hintText.width:textInp.width) + 11 + leftIcon.width + rightIcon.width
    height: 13 + 11
    clip: true

    BorderImage {
        source: generalResourcePath + "/mx-images/entry.png"
        anchors.fill:parent
        border { left: 5; right: 5; top: 5; bottom: 5 }
    }
    BorderImage {
        id: focusframe
        opacity:0
        source: generalResourcePath + "/mx-images/entry-active.png"
        anchors.fill:parent
        border { left: 5; right: 5; top: 5; bottom: 5 }
    }

    Text {
        id: hintText
        anchors.centerIn: parent
        anchors.topMargin:5
        anchors.rightMargin:6+rightIcon.width
        anchors.bottomMargin:6
        anchors.leftMargin:5+leftIcon.width
        font.pixelSize: 12
        color: '#A2A2A2'
        text: ''
        states: State{
            name: 'hinting'
            when: textInp.text=="" && textInp.focus==false
            PropertyChanges{target: hintText; text: root.hint}
        }//No cool animated transition, because mx doesn't do that

    }
    TextInput {
        id: textInp
        cursorDelegate: Item {
            Rectangle{
                visible: parent.parent.focus
                color: "#009BCE"
                height: 13
                width: 2
                y: 1
            }
        }
        property int leftMargin: 6 + leftIcon.width
        property int rightMargin: 6 + rightIcon.width
        x: leftMargin
        y: 5
        //Below function implements all scrolling logic
        onCursorPositionChanged: {
            if(cursorRectangle.x < leftMargin - textInp.x){//Cursor went off the front
                textInp.x = leftMargin - Math.max(0, cursorRectangle.x);
            }else if(cursorRectangle.x > parent.width - leftMargin - rightMargin - textInp.x){//Cusor went off the end
                textInp.x = leftMargin - Math.max(0, cursorRectangle.x - (parent.width - leftMargin - rightMargin));
            }
        }

        Keys.onPressed: { if ((event.key == Qt.Key_Enter) || (event.key == Qt.Key_Return))
                              root.enterPressed()
                        }

        text:""
        horizontalAlignment: TextInput.AlignLeft
        font.pixelSize: 12
    }
    MouseArea {
        id: mainMouseArea
        anchors.fill: parent;
        function translateX(x){
            return x - textInp.x
        }
        onPressed: {
            textInp.focus = true;
            textInp.cursorPosition = textInp.positionAt(translateX(mouse.x));
        }
        onPositionChanged: {
            if (!mainMouseArea.pressed)
                return;
            textInp.moveCursorSelection(textInp.positionAt(translateX(mouse.x)));
        }
        onReleased: {
        }
        onDoubleClicked: {
            textInp.selectionStart=0;
            textInp.selectionEnd=textInp.text.length;
        }
        z: textInp.z + 1
    }

    Image {
        id: rightIcon
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        z: mainMouseArea.z+1
        MouseArea {
            anchors.fill: parent
            onClicked: root.rightIconClicked();
        }
    }
    Image {
        id:leftIcon
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        z: mainMouseArea.z+1
        MouseArea {
            anchors.fill: parent
            onClicked: root.leftIconClicked();
        }
    }

    states: [
        State {
            name: "Highlighted"
            when: textInp.focus
            PropertyChanges { target: focusframe; opacity: 1.0}
        },
        State { name: "Disabled" }
    ]
    transitions: [
        Transition {
            from: ""; to: "Highlighted"
            NumberAnimation { properties: "opacity"; duration: 150 }
        },
        Transition {
            from: "Highlighted"; to: ""
            NumberAnimation { properties: "opacity"; duration: 150 }
        }
    ]
}
