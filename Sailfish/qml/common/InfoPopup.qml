/***************************************************************************
**
** Copyright (C) 2013-2015 Marko Koschak (marko.koschak@tisno.de)
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
import "../scripts/Global.js" as Global

MouseArea {
    id: infoPopup

    property int popupType: Global.none
    property alias popupTitle: titleLabel.text
    property alias popupMessage: messageLabel.text
    property int orientation: Orientation.Portrait

    // internal
    property int _timeout: 0

    signal closed

    function show(type, title, message, timeout) {
        popupType = type
        popupTitle = title
        popupMessage = message
        if (timeout !== undefined) {
            _timeout = timeout * 1000
        } else {
            _timeout = 0 // set default "0" to disable timeout
        }
        if (_timeout !== 0) {
            countdown.restart()
        }
        fadeInAnimation.start()
    }

    function cancel() {
        _close()
        closed()
    }

    function _close() {
        if (_timeout !== 0) countdown.stop()
        fadeOutAnimation.start()
    }

    opacity: 0.0
    visible: false
    width: parent ? parent.width : Screen.width
    height: column.height + Theme.paddingMedium * 2 + colorShadow.height
    z: 1
    transformOrigin: Item.TopLeft

    onClicked: cancel()

    states: [
        State {
            name: "PORTRAIT"
            PropertyChanges {
                target: infoPopup
                width: parent ? parent.width : Screen.width
                x: 0
                y: 0
                rotation: 0
            }
        },
        State {
            name: "LANDSCAPE"
            PropertyChanges {
                target: infoPopup
                width: parent ? parent.height : Screen.height
                x: parent ? parent.width : Screen.width
                y: 0
                rotation: 90
            }
        },
        State {
            name: "LANDSCAPE_INVERTED"
            PropertyChanges {
                target: infoPopup
                width: parent ? parent.height : Screen.height
                x: 0
                y: parent ? parent.height : Screen.height
                rotation: -90
            }
        }
    ]

    onOrientationChanged: {
        switch (orientation) {
        case Orientation.Landscape:
            state = "LANDSCAPE"
            break
        case Orientation.LandscapeInverted:
            state = "LANDSCAPE_INVERTED"
            break
        default:
            state = "PORTRAIT"
            break
        }
    }

    transitions: Transition {
        FadeAnimation { properties: "x,y,rotation" }
    }

    SequentialAnimation {
        id: fadeOutAnimation
        FadeAnimation { target: infoPopup; to: 0.0 }
        PropertyAction { target: infoPopup; property: "visible"; value: false }
    }

    SequentialAnimation {
        id: fadeInAnimation
        PropertyAction { target: infoPopup; property: "visible"; value: true }
        FadeAnimation { target: infoPopup; to: 1.0 }
    }

    Rectangle {
        id: infoPopupBackground
        anchors.top: parent.top
        width: parent.width
        height: column.height + Theme.paddingMedium * 2
        color: Theme.highlightBackgroundColor
    }

    Rectangle {
        id: colorShadow
        anchors.top: infoPopupBackground.bottom
        width: parent.width
        height: column.height
        color: Theme.highlightBackgroundColor
    }

    OpacityRampEffect {
        sourceItem: colorShadow
        slope: 0.5
        offset: 0.0
        clampFactor: -0.5
        direction: 2 // TtB
    }

    Image {
        id: infoPopupIcon
        x: Theme.paddingSmall
        y: Theme.paddingLarge
        width: 48
        height: 36
        fillMode: Image.PreserveAspectFit

        states: [
            State {
                when: popupType === Global.none
                PropertyChanges { target: infoPopupIcon; source: "" }
            },
            State {
                when: popupType === Global.info
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-info.png" }
            },
            State {
                when: popupType === Global.warning
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-warning.png" }
            },
            State {
                when: popupType === Global.error
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-error.png" }
            }
        ]
    }

    Column {
        id: column
        x: Theme.paddingSmall + infoPopupIcon.width + Theme.paddingMedium
        y: Theme.paddingMedium
        width: parent.width - Theme.paddingLarge - Theme.paddingSmall - infoPopupIcon.width - Theme.paddingMedium
        height: children.height
        Label {
            id: titleLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            color: "black"
            opacity: 0.6
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Label {
            id: messageLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeExtraSmall
            color: "black"
            opacity: 0.5
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Timer {
        id: countdown
        running: false
        repeat: false
        interval: _timeout

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
