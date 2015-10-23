/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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

Column {
    id: passwordFieldCombo

    // Adjust all texts of the password combo
    property string passwordDescriptionText: ""
    property string passwordLabelText: ""
    property string passwordPlaceholderText: ""
    property string passwordConfirmLabelText: ""
    property string passwordConfirmPlaceholderText: ""
    property bool passwordErrorHighlight: false
    property bool passwordConfirmEnabled: false

    // These both signals will be issues if the user touches the return button and the whole password field thing is in a well state
    signal passwordClicked(string password)
    signal passwordConfirmClicked(string password)

    spacing: 0

    SilicaLabel {
        enabled: confirmPasswordField.enabled
        visible: enabled
        text: passwordDescriptionText
    }

    Item {
        width: parent.width
        height: passwordField.height

        TextField {
            id: passwordField
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: showPasswordButton.left
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
            echoMode: TextInput.Password
            errorHighlight: passwordErrorHighlight
            label: passwordLabelText
            placeholderText: passwordPlaceholderText
            text: ""
            font.family: 'monospace'
            EnterKey.enabled: !errorHighlight
            EnterKey.highlighted: true
            EnterKey.iconSource: text.length === 0 ?
                                     "image://theme/icon-m-enter-close" :
                                     passwordConfirmEnabled ?
                                         "image://theme/icon-m-enter-next" :
                                         "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: {
                if (text.length === 0) {
                    parent.focus = true
                } else if (passwordConfirmEnabled) {
                    confirmPasswordField.focus = true
                } else {
                    parent.focus = true
                    // All right now do some stuff outside with the password
                    passwordClicked(passwordField.text)
                    // reset password text again
                    passwordField.text = ""
                }
            }
            focusOutBehavior: -1
        }

        IconButton {
            id: showPasswordButton
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            icon.source: passwordField.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" :
                                                                       "../../wallicons/icon-l-closeeye.png"
            onClicked: {
                if (passwordField.echoMode === TextInput.Normal) {
                    passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Password
                } else {
                    passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Normal
                }
            }
        }
    }

    TextField {
        id: confirmPasswordField
        width: parent.width
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
        echoMode: TextInput.Password
        visible: enabled
        errorHighlight: passwordField.text !== text && text.length !== 0
        label: passwordConfirmLabelText
        placeholderText: passwordConfirmPlaceholderText
        text: ""
        font.family: 'monospace'
        EnterKey.enabled: text.length === 0 || (passwordField.text.length >= 3 && !errorHighlight)
        EnterKey.highlighted: text.length === 0 || !errorHighlight
        EnterKey.iconSource: text.length === 0 ?
                                 "image://theme/icon-m-enter-close" :
                                 "image://theme/icon-m-enter-accept"
        EnterKey.onClicked: {
            parent.focus = true
            if (text.length !== 0) {
                // All right now do some stuff outside with the password
                passwordConfirmClicked(passwordField.text)
                // reset password fields again
                passwordField.text = ""
                confirmPasswordField.text = ""
            }
        }
        focusOutBehavior: -1
    }
}
