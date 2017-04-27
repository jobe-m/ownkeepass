/***************************************************************************
**
** Copyright (C) 2015 - 2017 Marko Koschak (marko.koschak@tisno.de)
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

    property string passwordDescriptionText: ""

    // predefined password field texts
    property string passwordLabelText: qsTr("Enter master password")
    property string passwordPlaceholderText: qsTr("Master password")
    property string passwordConfirmLabelText: qsTr("Confirm master password")
    property string passwordConfirmedLabelText: qsTr("Master password confirmed")
    property string passwordConfirmPlaceholderText: qsTr("Confirm password")

    property bool passwordErrorHighlightEnabled: true
    property bool passwordEnterKeyEnabled: true
    property bool passwordConfirmEnabled: false
    property bool passwordConfirmEnterKeyEnabled: true

    property alias passwordFieldFocus: passwordField.focus
    property alias password: passwordField.text

    readonly property bool passwordFieldHasError: passwordErrorHighlightEnabled ?
                                                      (passwordField.text.length >= 0 && passwordField.text.length < 3) :
                                                      passwordField.text.length === 0
    readonly property bool passwordFieldConfirmHasError:  passwordField.text !== confirmPasswordField.text ||
                                                          confirmPasswordField.text.length === 0

    // These both signals will be issues if the user touches the return button and the whole password field thing is in a well state
    signal passwordClicked(string password)
    signal passwordConfirmClicked(string password)

    spacing: 0

    SilicaLabel {
        enabled: passwordDescriptionText.length !== 0
        visible: enabled
        text: passwordDescriptionText + "\n"
    }

    PasswordField {
        id: passwordField
        width: parent.width
        showEchoModeToggle: true
        horizontalAlignment: TextInput.AlignLeft
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
        errorHighlight: passwordErrorHighlightEnabled ? (text.length > 0 && text.length < 3) : false
        label: passwordLabelText
        placeholderText: passwordPlaceholderText
        text: ""
        font.family: 'monospace'
        EnterKey.enabled: text.length === 0 || (!errorHighlight && (passwordEnterKeyEnabled || passwordConfirmEnabled))
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
        onEchoModeChanged: confirmPasswordField.echoMode = echoMode
        focusOutBehavior: -1
    }

    PasswordField {
        id: confirmPasswordField
        width: parent.width
        horizontalAlignment: TextInput.AlignLeft
        enabled: passwordConfirmEnabled
        visible: enabled
        showEchoModeToggle: false
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
        errorHighlight: passwordField.text !== text && text.length !== 0
        label: errorHighlight ? passwordConfirmLabelText : passwordConfirmedLabelText
        placeholderText: passwordConfirmPlaceholderText
        text: ""
        font.family: 'monospace'
        EnterKey.enabled: text.length === 0 || (passwordField.text.length >= 3 && !errorHighlight && passwordConfirmEnterKeyEnabled)
        EnterKey.highlighted: true
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
