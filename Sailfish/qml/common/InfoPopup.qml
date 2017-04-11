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

            acknowledgeButton.enabled = false
        } else {
            _timeout = 0 // set default "0" to disable timeout

            acknowledgeButton.enabled = true
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
    width: Screen.width
    height: infoPopupBackground.height
    z: 1
    transformOrigin: Item.TopLeft

    onClicked: { /* intentionally do nothing */ }

    states: [
        State {
            name: "PORTRAIT"
            PropertyChanges {
                target: infoPopup
                width: parent ? parent.width : Screen.width
                x: 0
                y: 0
                rotation: 0
                opacity: 0.0
            }
            StateChangeScript{
                script: hidePopupTimer.restart()
            }
        },
        State {
            name: "PORTRAIT_INVERTED"
            PropertyChanges {
                target: infoPopup
                width: parent ? parent.width : Screen.width
                x: parent ? parent.width : Screen.width
                y: parent ? parent.height : Screen.height
                rotation: 180
                opacity: 0.0
            }
            StateChangeScript{
                script: hidePopupTimer.restart()
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
                opacity: 0.0
            }
            StateChangeScript{
                script: hidePopupTimer.restart()
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
                opacity: 0.0
            }
            StateChangeScript{
                script: hidePopupTimer.restart()
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
        case Orientation.PortraitInverted:
            state = "PORTRAIT_INVERTED"
            break
        default:
            state = "PORTRAIT"
            break
        }
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
        height: column.height + Theme.paddingMedium * 3 + (acknowledgeButton.enabled ? acknowledgeButton.height + Theme.paddingLarge : 0)
        opacity: 0.8
        color: "black"
    }

    Image {
        id: infoPopupIcon
        x: Theme.paddingSmall
        y: Theme.paddingLarge
        width: Screen.sizeCategory >= Screen.Large ? 72 : 48
        height: Screen.sizeCategory >= Screen.Large ? 54 : 36
        fillMode: Image.PreserveAspectFit

        states: [
            State {
                when: popupType === Global.none
                PropertyChanges { target: infoPopupIcon; source: "" }
            },
            State {
                when: popupType === Global.info
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-info_" + (Screen.sizeCategory >= Screen.Large ? "72x54" : "48x36") + ".png" }
            },
            State {
                when: popupType === Global.warning
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-warning_" + (Screen.sizeCategory >= Screen.Large ? "72x54" : "48x36") + ".png" }
            },
            State {
                when: popupType === Global.error
                PropertyChanges { target: infoPopupIcon; source: "../../wallicons/icon-infobanner-error_" + (Screen.sizeCategory >= Screen.Large ? "72x54" : "48x36") + ".png" }
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
            height: text.length !== 0 ? contentHeight : 0
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            color: "white"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Label {
            id: messageLabel
            width: parent.width
            horizontalAlignment: Text.AlignLeft
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeExtraSmall
            color: "white"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    IconButton {
        id: acknowledgeButton
        visible: enabled
        anchors.top: column.bottom
        anchors.topMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        icon.source: "image://theme/icon-m-acknowledge?" + (pressed
                     ? Theme.highlightColor
                     : Theme.primaryColor)

        onClicked: infoPopup.cancel()
    }

    Timer {
        id: hidePopupTimer
        running: false
        repeat: false
        interval: 300

        function restart() {
            running = false
            running = true
        }

        onTriggered: infoPopup.opacity = 1.0
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
