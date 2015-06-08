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

Dialog {
    id: queryPasswordDialog

    // set default state
    state: "CreateNewDatabase"

    // These data is coming-in in case for opening a recent database and passed further
    // in all cases/states after accepting this dialog
    property alias dbFileLocation: dbLoading.locationIndex
    property alias dbFilePath: dbLoading.relativePath
    property alias useKeyFile: useKeyFileSwitch.checked
    property alias keyFileLocation: keyLoading.locationIndex
    property alias keyFilePath: keyLoading.relativePath
    // Password is only going out and will be passed to kdbDatabase object open the database
    property alias password: passwordField.text

    acceptDestination: Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString()
    acceptDestinationProperties: { "initOnPageConstruction": false, "groupId": 0 }
    acceptDestinationAction: PageStackAction.Replace

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

                Item {
                    id: dbLoading

                    property int locationIndex: 0
                    property string relativePath: ""
                    property string absolutePath: ""
                    property bool createNewFile: true

                    width: parent.width
                    height: dbFilePathArea.height > dbFilePathIcon.height ? dbFilePathArea.height : dbFilePathIcon.height

                    Label {
                        id: dbFilePathArea

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.right: dbFilePathIcon.left
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        text: Global.getLocationName(dbLoading.locationIndex) + dbLoading.relativePath
                        opacity: 0.6
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.Wrap
                    }

                    Image {
                        id: dbFilePathIcon
                        source: "image://theme/icon-m-right"
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var dialog = pageStack.push(Qt.resolvedUrl("../common/FileSystemDialog.qml").toString(),
                                                        { "locationIndex": dbLoading.locationIndex,
                                                          "absolutePath": dbLoading.absolutePath,
                                                          "state": dbLoading.createNewFile ? "CREATE_NEW_FILE" : "OPEN_FILE" })
                            dialog.accepted.connect(function() {
                                dbLoading.locationIndex = dialog.locationIndex
                                dbLoading.relativePath = dialog.relativePath
                                dbLoading.absolutePath = dialog.absolutePath
                            })
                        }
                    }
                }
            }

            Column {
                id: keyFileColumn
                visible: enabled
                width: parent.width
                height: keyLoading.enabled ? useKeyFileSwitch.height + keyLoading.height : useKeyFileSwitch.height
                spacing: 0

                Behavior on height { NumberAnimation { duration: 500 } }

                TextSwitch {
                    id: useKeyFileSwitch
                    checked: false
                    text: qsTr("Use key file")
                    description: qsTr("Switch this on to use a key file together with a master password for your new Keepass database")
                }

                Item {
                    id: keyLoading
                    enabled: useKeyFileSwitch.checked
                    opacity: enabled ? 1.0 : 0.0

                    property int locationIndex: 0
                    property string relativePath: ""
                    property string absolutePath: ""
                    property bool createNewFile: false

                    width: parent.width
                    height: keyFilePathArea.height > keyFilePathIcon.height ? keyFilePathArea.height : keyFilePathIcon.height

                    Behavior on opacity { FadeAnimation { duration: 500 } }

                    Label {
                        id: keyFilePathArea

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.right: keyFilePathIcon.left
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        text: Global.getLocationName(keyLoading.locationIndex) + keyLoading.relativePath
                        opacity: 0.6
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.Wrap
                    }

                    Image {
                        id: keyFilePathIcon
                        source: "image://theme/icon-m-right"
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var dialog = pageStack.push(Qt.resolvedUrl("../common/FileSystemDialog.qml").toString(),
                                                        { "locationIndex": keyLoading.locationIndex,
                                                            "absolutePath": keyLoading.absolutePath,
                                                            "state": keyLoading.createNewFile ? "CREATE_NEW_FILE" : "OPEN_FILE" })
                            dialog.accepted.connect(function() {
                                keyLoading.locationIndex = dialog.locationIndex
                                keyLoading.relativePath = dialog.relativePath
                                keyLoading.absolutePath = dialog.absolutePath
                            })
                        }
                    }
                }
            }

            SilicaLabel {
                id: passwordTitle
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
                    errorHighlight: text.length === 0
                    label: qsTr("Master password")
                    placeholderText: qsTr("Enter master password")
                    text: ""
                    EnterKey.enabled: !errorHighlight
                    EnterKey.highlighted: queryPasswordDialog.state !== "CreateNewDatabase" && text !== ""
                    EnterKey.iconSource: queryPasswordDialog.state === "CreateNewDatabase" ?
                                             "image://theme/icon-m-enter-next" :
                                             "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        if (queryPasswordDialog.state === "CreateNewDatabase") {
                            confirmPasswordField.focus = true
                        } else {
                            // set database name for pulley menu on opening database
                            Global.activeDatabase = Global.getLocationName(dbFileLocation) + " " + dbFilePath
                            parent.focus = true
                            accept()
                            close()
                        }
                    }
                    focusOutBehavior: -1
                }

                IconButton {
                    id: showPasswordButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: passwordField.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" : "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        if (passwordField.echoMode === TextInput.Normal) {
                            passwordField.echoMode =
                                    confirmPasswordField.echoMode = TextInput.Password
                        } else {
                            passwordField.echoMode =
                                    confirmPasswordField.echoMode = TextInput.Normal
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
                errorHighlight: passwordField.text !== text
                label: qsTr("Confirm password")
                placeholderText: label
                text: ""
                EnterKey.enabled: !passwordField.errorHighlight && !errorHighlight
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    // set database name for pulley menu on creating database
                    Global.activeDatabase = Global.getLocationName(dbFileLocation) + " " + dbFilePath
                    parent.focus = true
                    accept()
                    close()
                }
                focusOutBehavior: -1
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
            PropertyChanges { target: passwordTitle; text: qsTr("Type in a master password for locking your new Keepass Password Safe:") }
            PropertyChanges { target: confirmPasswordField; enabled: true }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordField.errorHighlight &&
                                    !confirmPasswordField.errorHighlight &&
                                    !dbLoading.absolutePath !== "" && (useKeyFile ? !keyLoading.absolutePath !== "" : true )
            }
            PropertyChanges { target: passwordField; focus: false }
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
            PropertyChanges { target: passwordTitle; text: qsTr("Type in master password for unlocking your Keepass Password Safe:") }
            PropertyChanges { target: confirmPasswordField; enabled: false }
            PropertyChanges { target: queryPasswordDialog
                canNavigateForward: !passwordField.errorHighlight &&
                                    !dbLoading.absolutePath !== "" && (useKeyFile ? !keyLoading.absolutePath !== "" : true )
            }
            PropertyChanges { target: passwordField; focus: false }
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
            PropertyChanges { target: passwordTitle; text: qsTr("Type in master password for unlocking your Keepass Password Safe:") }
            PropertyChanges { target: confirmPasswordField; enabled: false }
            PropertyChanges { target: queryPasswordDialog; canNavigateForward: passwordField.text !== "" }
            PropertyChanges { target: passwordField; focus: true }
            PropertyChanges { target: queryPasswordMenu; enabled: true; visible: true }
            PropertyChanges { target: queryPasswordDialogAppMenu; helpContent: "OpenRecentDatabase" }
            PropertyChanges { target: applicationWindow.cover; state: "OPEN_DATABASE"
                title: queryPasswordDialog.dbFilePath.substring(
                                  queryPasswordDialog.dbFilePath.lastIndexOf("/") + 1, queryPasswordDialog.dbFilePath.length)
            }
        }
    ]
}
