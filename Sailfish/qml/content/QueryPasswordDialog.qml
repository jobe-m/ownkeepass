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
import "../scripts/Global.js" as Global

Dialog {
    id: queryPasswordDialog

    // set default state
    state: "CreateNewDatabase"

    // These data is coming-in in case for opening a recent database and passed further
    // in all cases/states after accepting this dialog
    property alias dbFileLocation: dbFileLocationComboBox.currentIndex
    property alias dbFilePath: dbFilePathField.text
    property alias useKeyFile: useKeyFileSwitch.checked
    property alias keyFileLocation: keyFileLocationComboBox.currentIndex
    property alias keyFilePath: keyFilePathField.text
    property alias loadAsDefault: loadAsDefaultSwitch.checked
    // Password is only going out and will be passed to kdbDatabase object open the database
    property alias password: passwordField.text

    acceptDestination: Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString()
    acceptDestinationProperties: { "initOnPageConstruction": false,
                                   "pageTitle": "Password groups",
                                   "groupId": 0,
                                   "loadMasterGroups": true }
    acceptDestinationAction: PageStackAction.Replace

    canNavigateForward: (state === "CreateNewDatabase") || (state === "OpenNewDatabase") ?
                            passwordField.text !== "" &&
                            !confirmPasswordField.errorHighlight &&
                            dbFilePath !== "" && (useKeyFile ? keyFilePath !== "" : true ) :
                            passwordField.text !== ""

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        ApplicationMenu {}

        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            height: children.height
            spacing: Theme.paddingLarge

            DialogHeader {
                id: queryPasswordDialogHeader
                title: acceptText
            }

            SilicaLabel {
                id: dialogTitle
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            Column {
                id: dbFileColumn
                visible: enabled
                width: parent.width
                spacing: 0

                SilicaLabel {
                    text: "Specify location, path and file name of your new Keepass database:"
                }

                ComboBox {
                    id: dbFileLocationComboBox
                    width: parent.width
                    label: "Database location:"
                    currentIndex: 0
                    menu: ContextMenu {
                        MenuItem { text: "Documents on Phone" }
                        MenuItem { text: "SD Card" }
                        MenuItem { text: "Android Storage" }
                    }
                }

                TextField {
                    id: dbFilePathField
                    width: parent.width
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    label: "Path and name of database file"
                    placeholderText: "Set path and name of database file"
                    errorHighlight: text === ""
                    EnterKey.onClicked: parent.focus = true
                }
            }

            Column {
                id: keyFileColumn
                visible: enabled
                width: parent.width
                spacing: 0

                TextSwitch {
                    id: useKeyFileSwitch
                    checked: false
                    text: "Use Key File"
                    description: "Switch this on to use a key file together with a master password for your new Keepass Database"
                }

                Column {
                    enabled: useKeyFile
                    opacity: enabled ? 1.0 : 0.0
                    height: enabled ? children.height : 0
                    width: parent.width
                    spacing: 0
                    Behavior on opacity { NumberAnimation { duration: 500 } }
                    Behavior on height { NumberAnimation { duration: 500 } }

                    ComboBox {
                        id: keyFileLocationComboBox
                        width: parent.width
                        label: "Key File location:"
                        currentIndex: 0
                        menu: ContextMenu {
                            MenuItem { text: "Documents on Phone" }
                            MenuItem { text: "SD Card" }
                            MenuItem { text: "Android Storage" }
                        }
                    }

                    TextField {
                        id: keyFilePathField
                        width: parent.width
                        inputMethodHints: Qt.ImhUrlCharactersOnly
                        label: "Path and name of key file"
                        placeholderText: "Set path and name of key file"
                        errorHighlight: text === ""
                        EnterKey.onClicked: parent.focus = true
                    }
                }
            }

            SilicaLabel {
                id: passwordTitle
            }

            TextField {
                id: passwordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                label: "Password"
                placeholderText: "Enter password"
                // Development mode here for faster testing with predefined database file
//                text: Global.developmentMode === 1 ? "qwertz" : ""
                EnterKey.enabled: text !== ""
                EnterKey.highlighted: text !== ""
                EnterKey.onClicked: {
                    if (state === "CreateNewDatabase") {
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
                visible: enabled
                errorHighlight: passwordField.text !== text
                label: "Confirm Password"
                placeholderText: label
                // Development mode here for faster testing with predefined database file
                text: Global.developmentMode === 1 ? "qwertz" : ""
                EnterKey.enabled: passwordField.text !== "" && !errorHighlight
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: {
                    accept()
                    close()
                }
            }

            TextSwitch {
                id: loadAsDefaultSwitch
                text: "Open automatically"
            }
        }
    }

    Component.onCompleted: if (state === "OpenRecentDatabase") passwordField.focus = true

//    onDone: {
//        if (result === DialogResult.Accepted) {
//            password = passwordField.text
//            // Delete password after passing further
//            // Don't set empty string because otherwise canNavigateForward will blink the screen
//            passwordField.text = "blabla"
//            confirmPasswordField.text = "blabla"
//        }
//    }

    states: [
        State {
            name: "CreateNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Create" }
            PropertyChanges { target: dialogTitle; text: "New Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordTitle; text: "Type in a master password for locking your new Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: true }
        },
        State {
            name: "OpenNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Open" }
            PropertyChanges { target: dialogTitle; text: "Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordTitle; text: "Type in master password for unlocking your Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: false }
        },
        State {
            name: "OpenRecentDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Open" }
            PropertyChanges { target: dialogTitle; text: "Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: false }
            PropertyChanges { target: keyFileColumn; enabled: false }
            PropertyChanges { target: passwordTitle; text: "Type in master password for unlocking your Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: false }
        }
    ]
}
