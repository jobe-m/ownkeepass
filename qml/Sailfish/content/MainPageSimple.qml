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
import KeepassPlugin 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        KpPushUpMenu {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            KeepassPageHeader {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

            SectionHeader {
                text: internal.createNewDatabase ? "Create new Password Safe" : "Open Password Safe"
            }

            SilicaLabel {
                text: internal.createNewDatabase ? "Type in a master password for locking your Keepass Password Safe:" :
                                            "Type in master password for unlocking your Keepass Password Safe:"
            }

            TextField {
                id: passwordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                label: "Password"
                placeholderText: "Enter password"
                text: "qwertz"
                EnterKey.enabled: text !== ""
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    if (internal.createNewDatabase)
                        confirmPasswordField.focus = true
                    else
                        internal.openKeepassDatabase(passwordField.text, internal.createNewDatabase)
                }
            }

            TextField {
                id: confirmPasswordField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                enabled: internal.createNewDatabase && passwordField.text || text
                visible: internal.createNewDatabase
                errorHighlight: passwordField.text !== text
                label: "Confirm Password"
                placeholderText: label
                text: "qwertz"
                opacity: enabled ? 1 : 0.5
                Behavior on opacity { NumberAnimation { } }
                EnterKey.enabled: text !== ""
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    if (errorHighlight)
                        passwordField.focus = true
                    else
                        internal.openKeepassDatabase(confirmPasswordField.text, internal.createNewDatabase)
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: internal.createNewDatabase ? passwordField.text !== "" && !confirmPasswordField.errorHighlight : passwordField.text !== ""
                opacity: internal.createNewDatabase ? passwordField.text !== "" && !confirmPasswordField.errorHighlight ? 1.0 : 0.2 : passwordField.text !== "" ? 1.0 : 0.2
                text: internal.createNewDatabase ? "Create" : "Open"
                onClicked: internal.openKeepassDatabase(passwordField.text, internal.createNewDatabase)

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    KdbDatabase {
        id: kdbDatabase
        showUserNamePasswordsInListView: true
        onPreCheckDone: internal.preCheckDoneHandler(result)
        onDatabaseOpened: internal.databaseOpenedHandler(result, errorMsg)
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler(result, errorMsg)
        onDatabaseClosed: internal.databaseClosedHandler(result, errorMsg)
    }

    InfoDialogPage {
        id: infoDialogPage
// Usage:
//        pageStack.push(infoDialogPage, {
//                           "headerText": "Info",
//                           "titleText": "",
//                           "message": ""
//                       })
    }

    Component.onCompleted: {
        kdbDatabase.preCheck(keepassSettings.databasePath, keepassSettings.keyFilePath)
    }

    QtObject {
        id: keepassSettings
// TODO create real settings object
        property string databasePath: "/home/nemo/Documents/notes.kdb"
        property string keyFilePath: ""
        // Default encryption: AES/Rijndael = 0, Twofish = 1
        property int defaultEncryption: 0
        // LockTime: min = 5, max = 300 seconds, default = 30
        property int locktime: 30
        // ShowEmptyEntries, default = true
        property bool showEmptyEntries: true
        // ShowUserPasswordInListView, default = false
        property bool showUserPasswordInListView: false
    }

    // internal stuff
    QtObject {
        id: internal
        property bool createNewDatabase: true
        property string databaseFilePath: ""
        property string keyFilePath: ""

        function openKeepassDatabase(password, createNewDatabase) {
            // reset password fields
            passwordField.text = ""
            confirmPasswordField.text = ""
            if (createNewDatabase) {
                // create new Keepass database
                console.log("Password: '" + password + "'")
                kdbDatabase.create(keepassSettings.databasePath, keepassSettings.keyFilePath, password, keepassSettings.defaultEncryption)
            } else {
                // open existing Keepass database
                console.log("Password: '" + password + "'")
                kdbDatabase.open(keepassSettings.databasePath, keepassSettings.keyFilePath, password, false)
            }
        }

        function preCheckDoneHandler(result) {
            console.log("onPreCheckDone: " + result)
//            settings_databasePath.save()
//            settings_keyFilePath.save()

            switch (result) {
            case KdbDatabase.RE_OK: {
                // files exists so activate password field
                internal.createNewDatabase = false
// TODO WORKAROUND - uncomment following in final version, on emulator the keyboard is wrongly displayed on startup
//                passwordField.focus = true
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_ERROR: {
                // in this case the database file does not exists so let the user create a new keepass database
                internal.createNewDatabase = true
                passwordField.focus = true
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_ERROR: {
                // in this case database file exists but not key file
                internal.createNewDatabase = true
                passwordField.focus = false
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Key File Error",
                                   "message": "Database path is ok, but your key file is not present. Please check ownKeepass Settings for correct path to the key file or leave key file path empty if you don't use a key file with your database."
                               })
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_CREATION_ERROR: {
                console.log("ERROR: Cannot create path directories to database file, check your file permissions")
                internal.createNewDatabase = true
                passwordField.focus = false
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Permission Error",
                                   "message": "Cannot create directories for your Keepass database file. Please choose another path."
                               })
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_CREATION_ERROR: {
                internal.createNewDatabase = true
                passwordField.focus = false
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Permission Error",
                                   "message": "Cannot create directories for your key file. Please choose another path."
                               })
                break; }
            default: {
                console.log("ERROR: unknown result on onPreCheckDone")
                break; }
            }
        }

        function databaseOpenedHandler(result, errorMsg) {
            console.log("onDatabaseOpened: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // open database groups main page and replace password page in page stack
                pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                               { pageTitle: "Password groups",
                                 groupId: 0,
                                 loadMasterGroups: true }, false, true);
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Database Error",
                                   "message": "Could not close the previous opened database. Error message: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Password Error",
                                   "message": "The following error occured during opening of database: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Keyfile Error",
                                   "message": "The following error occured during opening of database: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_LOAD_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Password Error",
                                   "message": errorMsg + " Please try again."
                               })
                break }
            default:
                console.log("ERROR: unknown result on databaseOpened")
                break
            }
        }

        function newDatabaseCreatedHandler(result, errorMsg) {
            console.log("onNewDatabaseCreated: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // open database groups main page and replace password page in page stack
                pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                               { pageTitle: "Password groups",
                                 groupId: 0,
                                 loadMasterGroups: true }, false, true);
                // database is now created
                internal.createNewDatabase = false
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Database Error",
                                   "message": "Could not close the previous opened database. Error message: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_FILE_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal File Error",
                                   "message": "The following error occured during creation of database: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Password Error",
                                   "message": "The following error occured during creation of database: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Keyfile Error",
                                   "message": "The following error occured during creation of database: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_CREATE_BACKUPGROUP_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Internal Database Error",
                                   "message": "Creation of backup group failed with following error: " + errorMsg
                               })
                break }
            case KdbDatabase.RE_DB_SAVE_ERROR: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Save Database Error",
                                   "message": "Could not save database with following error: " + errorMsg
                               })
                break }
            default:
                console.log("ERROR: unknown result on databaseCreated")
                break
            }
        }

        function databaseClosedHandler(result, errorMsg) {
            switch (result) {
            case KdbDatabase.RE_OK:
                console.log("Database closed")
                break
            case KdbDatabase.RE_DB_ALREADY_CLOSED: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Database Error",
                                   "message": "Database was already closed. Nothing serious, but please submit a bug report."
                               })
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                pageStack.push(infoDialogPage, {
                                   "headerText": "Info",
                                   "titleText": "Database Error",
                                   "message": "An error occured on closing your database: " + errorMsg
                               })
                break }
            default:
                console.log("ERROR: unknown result on databaseClosed")
                break
            }
        }
    }
}


