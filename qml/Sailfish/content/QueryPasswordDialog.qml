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
import "../common"

Dialog {
    id: queryPasswordDialog

    property bool createNewDatabase: true
    property string password: ""

    acceptDestination: Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString()
    acceptDestinationProperties: { "initOnPageConstruction": false,
                                   "pageTitle": "Password groups",
                                   "groupId": 0,
                                   "loadMasterGroups": true }
    acceptDestinationAction: PageStackAction.Replace

    canNavigateForward: createNewDatabase ?
                            passwordField.text !== "" && !confirmPasswordField.errorHighlight :
                            passwordField.text !== ""

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            height: children.height
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: createNewDatabase ? "Create" : "Open"
                title: acceptText
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: createNewDatabase ? "New Password Safe" : "Password Safe"
            }

            SilicaLabel {
                text: createNewDatabase ? "Type in a master password for locking your Keepass Password Safe:" :
                                          "Type in master password for unlocking your Keepass Password Safe:"
            }

            TextField {
                id: passwordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                label: "Password"
                placeholderText: "Enter password"
// TODO remove, only here for faster testing with predefined database file
                text: "qwertz"
                EnterKey.enabled: text !== ""
                EnterKey.highlighted: text !== ""
                EnterKey.onClicked: {
                    if (createNewDatabase) {
                        confirmPasswordField.focus = true
                    } else {
                        accept()
                        close()
                    }
                }
            }

            TextField {
                id: confirmPasswordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                enabled: createNewDatabase
                visible: createNewDatabase
                errorHighlight: passwordField.text !== text
                label: "Confirm Password"
                placeholderText: label
// TODO remove, only here for faster testing with predefined database file
                text: "qwertz"
                EnterKey.enabled: passwordField.text !== "" && !errorHighlight
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: {
                    accept()
                    close()
                }
            }
        }
    }

    Component.onCompleted: passwordField.focus = true

    onDone: {
        if (result === DialogResult.Accepted) {
            password = passwordField.text
            passwordField.text = "blabla"
            confirmPasswordField.text = "blabla"
        }
    }
}
