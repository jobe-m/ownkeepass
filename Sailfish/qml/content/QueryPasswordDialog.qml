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
    property alias loadLastDb: openAutomaticallySwitch.checked
    // Password is only going out and will be passed to kdbDatabase object open the database
    property alias password: passwordField.text

    acceptDestination: Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString()
    acceptDestinationProperties: { "initOnPageConstruction": false,
                                   "pageTitle": "Password groups",
                                   "groupId": 0,
                                   "loadMasterGroups": true }
    acceptDestinationAction: PageStackAction.Replace

    function showWarning() {
        applicationWindow.infoPopupRef.show("Warning", "Please make sure to use a key file for \
additional security for your Keepass database when storing it online!", 0, false)
    }

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width
        contentHeight: col.height

        PullDownMenu {
            id: queryPasswordMenu
            MenuLabel {
                text: Global.databaseUiName
            }
        }

        ApplicationMenu {
            id: queryPasswordDialogAppMenu
        }

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
                        MenuItem { text: "Documents on phone" }
                        MenuItem { text: "SD card" }
                        MenuItem { enabled: false; visible: false; text: "Android storage" } // for backwards compatibility this needs to stay here
                        MenuItem { text: "Sailbox local storage" }
                    }
                    onCurrentIndexChanged: {
                        // When opening database from dropbox storage show warning if no key file is used
                        if ((queryPasswordDialog.state === "OpenNewDatabase") &&
                                (!useKeyFileSwitch.checked) && (currentIndex === 3)) {
                            showWarning()
                        }
                        // When creating database on dropbox storage force usage of key file
                        else if ((queryPasswordDialog.state === "CreateNewDatabase") &&
                                (currentIndex === 3)) {
                            useKeyFileSwitch.enabled = false
                            useKeyFileSwitch.checked = true
                            applicationWindow.infoPopupRef.show("Advice", "You choosed to place your new \
Keepass database in the Dropbox cloud. Please make sure to use a unique password for Dropbox \
and enable two-step verification to increase security of your online storage! \
ownKeepass does enforce to use a locally stored key \
file when storing your Keepass database online.", 0, false)
                        } else {
                            useKeyFileSwitch.enabled = true
                        }
                    }
                }

                TextField {
                    id: dbFilePathField
                    width: parent.width
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    label: "Path and name of database file"
                    placeholderText: "Set path and name of database file"
                    errorHighlight: text === ""
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        if (useKeyFileSwitch.checked) {
                            keyFilePathField.focus = true
                        } else {
                            passwordField.focus = true
                        }
                    }
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
                    onCheckedChanged: {
                        // When opening database from dropbox storage show warning if no key file is used
                        if ((queryPasswordDialog.state === "OpenNewDatabase") &&
                                (!checked) && (dbFileLocationComboBox.currentIndex === 3)) {
                            showWarning()
                        }
                    }
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
                            MenuItem { text: "Documents on phone" }
                            MenuItem { text: "SD card" }
//                            MenuItem { text: "Android storage" }
                        }
                    }

                    TextField {
                        id: keyFilePathField
                        width: parent.width
                        inputMethodHints: Qt.ImhUrlCharactersOnly
                        label: "Path and name of key file"
                        placeholderText: "Set path and name of key file"
                        errorHighlight: text === ""
                        EnterKey.enabled: text.length > 0
                        EnterKey.iconSource: "image://theme/icon-m-enter-next"
                        EnterKey.onClicked: passwordField.focus = true
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
                errorHighlight: text.length === 0
                label: "Password"
                placeholderText: "Enter password"
                EnterKey.enabled: !errorHighlight
                EnterKey.highlighted: queryPasswordDialog.state !== "CreateNewDatabase" && text !== ""
                EnterKey.iconSource: queryPasswordDialog.state === "CreateNewDatabase" ?
                                         "image://theme/icon-m-enter-next" :
                                         "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if (queryPasswordDialog.state === "CreateNewDatabase") {
                        confirmPasswordField.focus = true
                    } else {
                        parent.focus = true
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
                EnterKey.enabled: !passwordField.errorHighlight && !errorHighlight
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    parent.focus = true
                    accept()
                    close()
                }
            }

            TextSwitch {
                id: openAutomaticallySwitch
                text: "Open automatically"
            }
        }
    }

    Component.onCompleted: {
//        // Get database name and set on cover page
//        applicationWindow.cover.coverTitle = queryPasswordDialog.dbFilePath.substring(
//                    queryPasswordDialog.dbFilePath.lastIndexOf("/") + 1, queryPasswordDialog.dbFilePath.length)
//        applicationWindow.cover.state = "DATABASE_LOCKED"
    }

    states: [
        State {
            name: "CreateNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Create" }
            PropertyChanges { target: dialogTitle; text: "New Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordTitle; text: "Type in a master password for locking your new Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: true }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordField.errorHighlight &&
                                    !confirmPasswordField.errorHighlight &&
                                    !dbFilePathField.errorHighlight && (useKeyFile ? !keyFilePathField.errorHighlight : true )
            }
            PropertyChanges { target: passwordField; focus: false }
            PropertyChanges { target: queryPasswordMenu; enabled: false; visible: false }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "CreateNewDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "CREATE_NEW_DATABASE" }
        },
        State {
            name: "OpenNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Open" }
            PropertyChanges { target: dialogTitle; text: "Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordTitle; text: "Type in master password for unlocking your Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: false }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordField.errorHighlight &&
                                    !dbFilePathField.errorHighlight && (useKeyFile ? !keyFilePathField.errorHighlight : true )
            }
            PropertyChanges { target: passwordField; focus: false }
            PropertyChanges { target: queryPasswordMenu; enabled: false; visible: false }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "OpenNewDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "OPEN_DATABASE" }
        },
        State {
            name: "OpenRecentDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: "Open" }
            PropertyChanges { target: dialogTitle; text: "Password Safe" }
            PropertyChanges { target: dbFileColumn; enabled: false }
            PropertyChanges { target: keyFileColumn; enabled: false }
            PropertyChanges { target: passwordTitle; text: "Type in master password for unlocking your Keepass Password Safe:" }
            PropertyChanges { target: confirmPasswordField; enabled: false }
            PropertyChanges { target: queryPasswordDialog; canNavigateForward: passwordField.text !== "" }
            PropertyChanges { target: passwordField; focus: true }
            PropertyChanges { target: queryPasswordMenu; enabled: true; visible: true }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "OpenRecentDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "DATABASE_LOCKED"
                coverTitle: queryPasswordDialog.dbFilePath.substring(
                                  queryPasswordDialog.dbFilePath.lastIndexOf("/") + 1, queryPasswordDialog.dbFilePath.length)
            }
        }
    ]
}
