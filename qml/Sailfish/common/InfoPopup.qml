/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: infoPopup

    property bool enableTimeout: false
    property alias title: titleLabel.text
    property alias message: messageLabel.text

    function show(title, message, timeout, enableTimeout) {
        infoPopup.title = title
        infoPopup.message = message
        infoPopup.enableTimeout = enableTimeout
        if (timeout !== undefined)
            _timeout = timeout
        else
            _timeout = 5000 // set default
        if (infoPopup.enableTimeout) countdown.restart()
        state = "active"
    }
    function cancel() {
        _close()
        closed()
    }

    function _close() {
        if (enableTimeout) countdown.stop()
        state = ""
    }

    property int _timeout: 5000

    signal closed

    opacity: 0.0
    visible: false
    width: parent ? parent.width : Screen.width
    height: column.height + Theme.paddingMedium * 2
    z: 1

    onClicked: cancel()

    states: State {
        name: "active"
        PropertyChanges { target: infoPopup; opacity: 1.0; visible: true }
    }
    transitions: [
        Transition {
            to: "active"
            SequentialAnimation {
                PropertyAction { target: infoPopup; properties: "visible" }
                FadeAnimation {}
            }
        },
        Transition {
            SequentialAnimation {
                FadeAnimation {}
                PropertyAction { target: infoPopup; property: "visible" }
            }
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
    }

    Column {
        id: column
        x: Theme.paddingLarge
        y: Theme.paddingMedium
        width: parent.width - Theme.paddingLarge * 2
        height: children.height
        Label {
            id: titleLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            font.bold: true
            color: "white"
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: messageLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeExtraSmall
            font.bold: true
            color: "white"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Timer {
        id: countdown
        running: false
        repeat: false
        interval: infoPopup._timeout

        function restart() {
            running = false
            running = true
        }

        function stop() {
            running = false
        }

        onTriggered: _close()
    }
}
