/***************************************************************************
**
** Copyright (C) 2013 - 2015 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass 1.0

Dialog {
    id: queryPasswordDialog

    // set default state
    state: "CreateNewDatabase"

    allowedOrientations: applicationWindow.orientationSetting

    // These data is coming-in in case for opening a recent database and passed further
    // in all cases/states after accepting this dialog
    property alias dbFileLocation: dbLoading.locationIndex
    property alias dbFilePath: dbLoading.relativePath
    property alias useKeyFile: useKeyFileSwitch.checked
    property alias keyFileLocation: keyLoading.locationIndex
    property alias keyFilePath: keyLoading.relativePath

    // Password is only going out and will be passed to ownKeepass database interface to open the database
    property string password: ""

    acceptDestination: Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString()
    acceptDestinationProperties: { "initOnPageConstruction": false, "groupId": "0" }
    acceptDestinationAction: PageStackAction.Replace

    onDone: {
        if (result === DialogResult.Accepted) {
            password = passwordFieldCombo.password
            // set database name for pulley menu on opening database
            Global.activeDatabase = Global.getLocationName(dbFileLocation) + " " + dbFilePath
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width
        contentHeight: col.height

        PullDownMenu {
            id: queryPasswordMenu
            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
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
                cancelText: qsTr("Cancel")
            }

            Column {
                id: dbFileColumn
                visible: enabled
                width: parent.width
                spacing: Theme.paddingLarge

                SilicaLabel {
                    id: dbLoadingInfo
                }

                FileQueryListItem {
                    id: dbLoading
                    createNewFile: true
                    fileFilter: "*.kdb *.kdbx"
                }
            }

            Column {
                id: keyFileColumn
                visible: enabled
                width: parent.width
                height: keyLoading.enabled ? useKeyFileSwitch.height + keyLoading.height : useKeyFileSwitch.height
                spacing: 0

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                TextSwitch {
                    id: useKeyFileSwitch
                    checked: false
                    text: qsTr("Use key file")
                    description: qsTr("Switch this on to use a key file together with a master password for your new Keepass database")
                }

                FileQueryListItem {
                    id: keyLoading
                    enabled: useKeyFileSwitch.checked
                    opacity: enabled ? 1.0 : 0.0
                    createNewFile: false
                    fileFilter: "*.key"

                    Behavior on opacity { FadeAnimation { duration: 200; easing.type: Easing.OutQuad } }
                }
            }

            PasswordFieldCombo {
                id: passwordFieldCombo
                width: parent.width

                onPasswordClicked: {
                    parent.focus = true
                    accept()
                    close()
                }

                onPasswordConfirmClicked: {
                    parent.focus = true
                    accept()
                    close()
                }
            }
        }
    }

    states: [
        State {
            name: "CreateNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: qsTr("Create") }
            PropertyChanges { target: queryPasswordDialogHeader; title: qsTr("New Password Safe") }
            PropertyChanges { target: dbLoadingInfo; text: qsTr("Please specify a new Keepass database file:") }
            PropertyChanges { target: dbLoading; createNewFile: true }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordFieldCombo
                passwordDescriptionText: qsTr("Type in a master password for locking your new Keepass Password Safe:")
                passwordErrorHighlightEnabled: true
                passwordConfirmEnabled: true
                passwordFieldFocus: false
                passwordEnterKeyEnabled: true
                passwordConfirmEnterKeyEnabled: dbLoading.absolutePath.length !== 0 &&
                                                (useKeyFile ? keyLoading.absolutePath.length !== 0 : true )
            }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordFieldCombo.passwordFieldHasError &&
                                    !passwordFieldCombo.passwordFieldConfirmHasError &&
                                    dbLoading.absolutePath.length !== 0 &&
                                    (useKeyFile ? keyLoading.absolutePath.length !== 0 : true )
            }
            PropertyChanges { target: queryPasswordMenu; enabled: false; visible: false }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "CreateNewDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "CREATE_NEW_DATABASE" }
        },
        State {
            name: "OpenNewDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: qsTr("Open") }
            PropertyChanges { target: queryPasswordDialogHeader; title: qsTr("Password Safe") }
            PropertyChanges { target: dbLoadingInfo; text: qsTr("Please choose an existing Keepass database file:") }
            PropertyChanges { target: dbLoading; createNewFile: false }
            PropertyChanges { target: dbFileColumn; enabled: true }
            PropertyChanges { target: keyFileColumn; enabled: true }
            PropertyChanges { target: passwordFieldCombo;
                passwordDescriptionText: qsTr("Type in master password for unlocking your Keepass Password Safe:")
                passwordErrorHighlightEnabled: false
                passwordConfirmEnabled: false
                passwordFieldFocus: false
                passwordEnterKeyEnabled: queryPasswordDialog.canNavigateForward
                passwordConfirmEnterKeyEnabled: false
            }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordFieldCombo.passwordFieldHasError &&
                                    dbLoading.absolutePath.length !== 0 &&
                                    (useKeyFile ? keyLoading.absolutePath.length !== 0 : true )
            }
            PropertyChanges { target: queryPasswordMenu; enabled: false; visible: false }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "OpenNewDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "OPEN_DATABASE" }
        },
        State {
            name: "OpenRecentDatabase"
            PropertyChanges { target: queryPasswordDialogHeader; acceptText: qsTr("Open") }
            PropertyChanges { target: queryPasswordDialogHeader; title: qsTr("Password Safe") }
            PropertyChanges { target: dbFileColumn; enabled: false }
            PropertyChanges { target: keyFileColumn; enabled: false }
            PropertyChanges { target: passwordFieldCombo;
                passwordDescriptionText: qsTr("Type in master password for unlocking your Keepass Password Safe:")
                passwordErrorHighlightEnabled: false
                passwordConfirmEnabled: false
                passwordFieldFocus: true
                passwordEnterKeyEnabled: true
                passwordConfirmEnterKeyEnabled: false
            }
            PropertyChanges { target: queryPasswordDialog; canNavigateForward: !passwordFieldCombo.passwordFieldHasError }
            PropertyChanges { target: queryPasswordMenu; enabled: true; visible: true }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "OpenRecentDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "OPEN_DATABASE"
                title: queryPasswordDialog.dbFilePath.substring(
                                  queryPasswordDialog.dbFilePath.lastIndexOf("/") + 1, queryPasswordDialog.dbFilePath.length)
            }
        }
    ]
}
