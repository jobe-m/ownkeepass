/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

// Enhanced with image component by Marko Koschak

import QtQuick 2.0
import Sailfish.Silica 1.0
//import "private/Util.js" as Util

Item {
    id: placeholder
    property Item flickable
    property alias image: wallImage
    property alias text: mainLabel.text
    property alias hintText: hintLabel.text
    property real verticalOffset

    // workaround: copied from private Util.js
    function findFlickable(item) {
        var parentItem = item.parent
        while (parentItem) {
            if (parentItem.maximumFlickVelocity && !parentItem.hasOwnProperty('__silica_hidden_flickable')) {
                return parentItem
            }
            parentItem = parentItem.parent
        }
        return null
    }

    // stay centered in screen
    y: (flickable ? flickable.originY : 0) + (__silica_applicationwindow_instance.contentItem.height - height) / 2 + verticalOffset
    width: (flickable ? flickable.width : screen.width) - 2*Theme.paddingLarge
    height: wallImage.height + mainLabel.height + hintLabel.height
    anchors.horizontalCenter: parent.horizontalCenter
    enabled: false
    opacity: enabled ? 1.0 : 0

    onEnabledChanged: {
        if (enabled && !_content) {
            _content = activeContent.createObject(placeholder)
        }
    }

    property Item _content
    property real _menuInactivePos: (flickable !== null && flickable.pullDownMenu) ? flickable.pullDownMenu._inactivePosition : 0

    Behavior on opacity { FadeAnimation { duration: 300 } }

    Image {
        id: wallImage
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: mainLabel
        anchors.top: wallImage.bottom
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        color: Theme.highlightColor
        opacity: 0.6
    }
    Text {
        id: hintLabel
        anchors.top: mainLabel.bottom
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        font {
            pixelSize: Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
        }
        color: Theme.highlightColor
        opacity: 0.4
    }

    Component {
        // content we don't need until we're active
        id: activeContent
        MouseArea {
            width: parent.width
            height: width
            anchors.centerIn: parent

            onClicked: {
                if (flickable !== null
                 && flickable.pullDownMenu !== null
                 && flickable.pullDownMenu.enabled
                 && flickable.pullDownMenu.visible) {
                    pullDownActive.target = flickable.pullDownMenu
                    pullDownDeactive.target = flickable.pullDownMenu
                    menuPeek.start()
                }
            }
            SequentialAnimation {
                id: menuPeek
                PropertyAction {
                    id: pullDownActive
                    property: "active"
                    value: true
                }
                NumberAnimation {
                    target: flickable
                    property: "contentY"
                    to: _menuInactivePos - 30
                    duration: 300
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: flickable
                    property: "contentY"
                    to: _menuInactivePos
                    duration: 80
                    easing.type: Easing.OutCubic
                }
                PropertyAction {
                    id: pullDownDeactive
                    property: "active"
                    value: false
                }
            }
        }
    }

    Component.onCompleted: {
// Workaround for private Silical stuff not accessable from here
//        var item = Util.findFlickable(placeholder)
        var item = findFlickable(placeholder)
        if (item) {
            flickable = item
            parent = item.contentItem
        } else {
            console.log("ViewPlaceholder requires a SilicaFlickable parent")
        }
    }
}
