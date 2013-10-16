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

    property alias title: titleLabel.text
    property alias message: messageLabel.text

    function execute(title, message, timeout) {
        _checkParent()
        infoPopup.title = title
        infoPopup.message = message
        _timeout = timeout === undefined ? 10000 : timeout
        countdown.restart()
        state = "active"
    }
    function cancel() {
        _close()
        canceled()
    }

    function _close() {
        countdown.stop()
        state = ""
    }

    function _checkParent() {
        if (parent.hasOwnProperty('_navigation')) {
            _page = parent
            return
        }

        var parentItem = parent
        while (parentItem) {
            if (parentItem.hasOwnProperty('_navigation')) {
                _page = parentItem
                parent = _page
            }
            parentItem = parentItem.parent
        }
    }

    property int _timeout: 10000
    property Item _page

    signal canceled

    opacity: 0.0
    visible: false
    width: parent ? parent.width : Screen.width
    height: column.height
    z: 1

    onClicked: cancel()

    // Don't allow backstepping until the operation has executed.
    states: State {
        name: "active"
        PropertyChanges { target: _page; backNavigation: false }
        PropertyChanges { target: infoPopup; opacity: 1.0; visible: true }
    }
    transitions: [
        Transition {
            to: "active"
            SequentialAnimation {
                PropertyAction { target: _page; property: "backNavigation" }
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

//    Connections {
//        target: _page
//        onStatusChanged: {
//            if (status === PageStatus.Inactive && countdown.running) {
//                // if the page is changed then execute immediately
//                _close()
//                if (Remorse.callback !== undefined) {
//                    remorsePopup.triggered()
//                    Remorse.callback.call()
//                }
//            }
//        }
//    }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
    }

//    Image {
//        anchors.top: parent.bottom
//        width: parent.width
//        source: "image://theme/graphic-system-gradient?" + Theme.highlightBackgroundColor
//    }

    Column {
        id: column
        x: Theme.paddingLarge
        width: parent.width - Theme.paddingLarge * 2
        height: children.height
//        opacity: 0.7
        Label {
            id: titleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            horizontalAlignment: Text.AlignLeft
            color: "black"
            truncationMode: TruncationMode.Fade
        }
        Label {
            id: messageLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            color: "black"
            font.pixelSize: Theme.fontSizeSmall
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
