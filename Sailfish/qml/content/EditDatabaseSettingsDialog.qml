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
    id: editDatabaseSettingsDialog

    // save cover state because database settings page can be opened from various
    // pages like list view or edit dialogs, which have different cover states
    property int saveCoverState: -1
    property bool masterPasswordChanged: false
    property bool cryptAlgorithmChanged: false
    property bool keyTransfRoundsChanged: false

    function updateCoverState() {
        if (saveCoverState === -1) // save initial state
            editDatabaseSettingsDialog.saveCoverState = applicationWindow.cover.coverState
        if (masterPasswordChanged || cryptAlgorithmChanged || keyTransfRoundsChanged) {
            applicationWindow.cover.coverState = Global.constants.databaseUnsavedChanges
        } else {
            applicationWindow.cover.coverState = editDatabaseSettingsDialog.saveCoverState
        }
    }

    // forbit page navigation if master password is not confirmed
    canNavigateForward: !confirmDatabaseMasterPassword.errorHighlight

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: "Save"
                title: "Save"
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: "Database Settings"
            }

            SilicaLabel {
                text: "Change settings of your currently opened Keepass database here"
            }

            Column {
                width: parent.width
                spacing: 0

                SilicaLabel {
                    text: "Note: By changing the master password here, you will need to remember it next time when opening the Keepass database!"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                TextField {
                    id: databaseMasterPassword
                    width: parent.width
                    inputMethodHints: Qt.ImhNoPredictiveText
                    echoMode: TextInput.Password
                    label: "Master Password"
                    text: ""
                    placeholderText: "Change Master Password"
                    EnterKey.enabled: text !== ""
                    EnterKey.highlighted: text !== ""
                    EnterKey.onClicked: {
                        confirmDatabaseMasterPassword.focus = true
                    }
                    onTextChanged: {
                        editDatabaseSettingsDialog.masterPasswordChanged =
                                (text !== "" ? true : false)
                        editDatabaseSettingsDialog.updateCoverState()
                    }
                }
            }

            TextField {
                id: confirmDatabaseMasterPassword
                enabled: databaseMasterPassword.text !== ""
                opacity: databaseMasterPassword.text !== "" ? 1.0 : 0.0
                height: databaseMasterPassword.text !== "" ? implicitHeight : 0
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                errorHighlight: databaseMasterPassword.text !== text
                label: !errorHighlight ? "Master Password confirmed" : "Confirm Master Password"
                text: ""
                placeholderText: "Confirm Master Password"
                EnterKey.enabled: databaseMasterPassword.text !== "" && !errorHighlight
                EnterKey.highlighted: databaseMasterPassword.text !== "" && !errorHighlight
                EnterKey.onClicked: {
                    parent.focus = true
                }
                Behavior on opacity { NumberAnimation { duration: 500 } }
                Behavior on height { NumberAnimation { duration: 500 } }
            }

            ComboBox {
                id: databaseCryptAlgorithm
                width: parent.width
                label: "Encryption currently in use:"
                currentIndex: Global.env.kdbDatabase.cryptAlgorithm
                menu: ContextMenu {
                    MenuItem { text: "AES/Rijndael" }
                    MenuItem { text: "Twofish" }
                }
                onCurrentIndexChanged: {
                    editDatabaseSettingsDialog.cryptAlgorithmChanged =
                            (currentIndex !== Global.env.kdbDatabase.cryptAlgorithm ? true : false)
                    editDatabaseSettingsDialog.updateCoverState()
                }
            }

            Column {
                width: parent.width
                spacing: 0

                TextField {
                    id: databaseKeyTransfRounds
                    width: parent.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: RegExpValidator { regExp: /^[1-9][0-9]*$/ }
                    label: "Key Transformation Rounds"
                    placeholderText: label
                    text: Global.env.kdbDatabase.keyTransfRounds
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editDatabaseSettingsDialog.keyTransfRoundsChanged =
                                (text !== Global.env.kdbDatabase.keyTransfRounds ? true : false)
                        editDatabaseSettingsDialog.updateCoverState()
                    }
                }

                SilicaLabel {
                    text: "Setting this value higher increases opening time of the Keepass database but makes it more robust against brute force attacks"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }
        }
    } // SilicaFlickable

    // user wants to save new Settings
    onAccepted: {
        // first save locally database settings then trigger saving
        kdbListItemInternal.setDatabaseSettings(databaseMasterPassword.text,
                                     databaseCryptAlgorithm.currentIndex,
                                     Number(databaseKeyTransfRounds.text))
        kdbListItemInternal.saveDatabaseSettings()
    }
    // user has rejected changing database settings, check if there are unsaved details
    onRejected: {
        // no need for saving if input field for master password is invalid
        if (canNavigateForward) {
            // first save locally database settings then trigger check for unsaved changes
            kdbListItemInternal.setDatabaseSettings(databaseMasterPassword.text,
                                         databaseCryptAlgorithm.currentIndex,
                                         Number(databaseKeyTransfRounds.text))
            kdbListItemInternal.checkForUnsavedDatabaseSettingsChanges()
        }
    }
}
