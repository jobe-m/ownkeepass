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
import "../scripts/Global.js" as Global
import "../common"

Dialog {
    id: editSettingsDialog

    // save cover state because database settings page can be opened from various
    // pages like list view or edit dialogs, which have different cover states
    property int saveCoverState: -1
    property bool defaultDatabaseFilePathChanged: false
    property bool defaultKeyFilePathChanged: false
    property bool defaultCryptAlgorithmChanged: false
    property bool defaultKeyTransfRoundsChanged: false
    property bool inactivityLockTimeChanged: false
    property bool showUserNamePasswordInListViewChanged: false
    property bool showUserNamePasswordOnCoverChanged: false
    property bool lockDatabaseFromCoverChanged: false
    property bool copyNpasteFromCoverChanged: false

    function updateCoverState() {
        if (saveCoverState === -1) // save initial state
            editSettingsDialog.saveCoverState = applicationWindow.cover.coverState
        if (defaultDatabaseFilePathChanged || defaultKeyFilePathChanged ||
                defaultCryptAlgorithmChanged || defaultKeyTransfRoundsChanged ||
                inactivityLockTimeChanged || showUserNamePasswordInListViewChanged ||
                showUserNamePasswordOnCoverChanged || lockDatabaseFromCoverChanged ||
                copyNpasteFromCoverChanged) {
            applicationWindow.cover.coverState = Global.constants.databaseUnsavedChanges
        } else {
            applicationWindow.cover.coverState = editSettingsDialog.saveCoverState
        }
    }

    // forbit page navigation if path to keepass database and key file (if used) is not set
    canNavigateForward: !defaultDatabaseFilePath.errorHighlight && (useKeyFile.checked ? !defaultKeyFilePath.errorHighlight : true)

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
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
                text: "Keepass Settings"
            }

            SilicaLabel {
                text: "Change default settings of your ownKeepass application here"
            }

// TODO We have currently only simple mode
//                            TextSwitch {
//                                id: simpleMode
//                                checked: Global.env.keepassSettings.simpleMode
//                                text: "Use Simple Mode"
//                                description: "In simple mode below default Keepass database is automatically loaded on application start. " +
//                                             " If you switch this off you get a list of recently opened Keepass database files instead."
//                            }

//                            SectionHeader {
//                                text: "Database"
//                            }

            Column {
                width: parent.width
                spacing: 0

                SilicaLabel {
                    text: Global.env.keepassSettings.simpleMode ?
                              "This is the name and path of your Keepass database file:" :
                              "This is the path where new Keepass database files will be stored:"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                TextField {
                    id: defaultDatabaseFilePath
                    width: parent.width
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    label: "Keepass database file path"
                    placeholderText: "Set Keepass database file path"
                    errorHighlight: text === ""
                    text: Global.env.keepassSettings.defaultDatabasePath
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editSettingsDialog.defaultDatabaseFilePathChanged =
                                (text !== Global.env.keepassSettings.defaultDatabasePath ? true : false)
                        editSettingsDialog.updateCoverState()
                    }
                }
            }

            TextSwitch {
                id: useKeyFile
                checked: Global.env.keepassSettings.defaultKeyFilePath !== ""
                text: "Use Key File"
                description: Global.env.keepassSettings.simpleMode ?
                                 "Switch this on to use a key file together with a master password for your Keepass database" :
                                 "Switch this on to use a key file together with a master password when creating a new Keepass database"
            }

            TextField {
                id: defaultKeyFilePath
                enabled: useKeyFile.checked
                opacity: useKeyFile.checked ? 1.0 : 0.0
                height: useKeyFile.checked ? implicitHeight : 0
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                label: "Path and filename of key file"
                placeholderText: "Set path and filename of key file"
                errorHighlight: text === ""
                text: Global.env.keepassSettings.defaultKeyFilePath
                EnterKey.onClicked: parent.focus = true
                onTextChanged: {
                    editSettingsDialog.defaultKeyFilePathChanged =
                            (text !== Global.env.keepassSettings.defaultKeyFilePath ? true : false)
                    editSettingsDialog.updateCoverState()
                }
                Behavior on opacity { NumberAnimation { duration: 500 } }
                Behavior on height { NumberAnimation { duration: 500 } }
            }

            Column {
                width: parent.width
                spacing: 0

                SilicaLabel {
                    text: "This is the encryption which will be used as default when creating a new Keepass database:"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                ComboBox {
                    id: defaultCryptAlgorithm
                    width: editSettingsDialog.width
                    label: "Default Encryption:"
                    currentIndex: Global.env.keepassSettings.defaultCryptAlgorithm
                    menu: ContextMenu {
                        MenuItem { text: "AES/Rijndael" }
                        MenuItem { text: "Twofish" }
                    }
                    onCurrentIndexChanged: {
                        editSettingsDialog.defaultCryptAlgorithmChanged =
                                (currentIndex !== Global.env.keepassSettings.defaultCryptAlgorithm ? true : false)
                        editSettingsDialog.updateCoverState()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 0

                TextField {
                    id: defaultKeyTransfRounds
                    width: parent.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: RegExpValidator { regExp: /^[1-9][0-9]*$/ }
                    label: "Default Key Transformation Rounds"
                    placeholderText: label
                    text: Global.env.keepassSettings.defaultKeyTransfRounds
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editSettingsDialog.defaultKeyTransfRoundsChanged =
                                (Number(text) !== Global.env.keepassSettings.defaultKeyTransfRounds ? true : false)
                        editSettingsDialog.updateCoverState()
                    }
                }

                SilicaLabel {
                    text: "Setting this value higher increases opening time of the Keepass database but makes it more robust against brute force attacks"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: "UI Settings"
            }

            Slider {
                id: inactivityLockTime
                value: Global.env.keepassSettings.locktime
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                valueText: calculateInactivityTime(value)
                label: "Inactivity Lock Time"
                /*
                  0 = immediately
                  1 = 5 seconds
                  2 = 10 seconds
                  3 = 30 seconds
                  4 = 1 minute
                  5 = 2 minutes
                  6 = 5 minutes
                  7 = 10 minutes
                  8 = 30 minutes
                  9 = 60 minutes
                  10 = unlimited
                  */
                function calculateInactivityTime(value) {
                    switch (value) {
                    case 0:
                        return "Immediately"
                    case 1:
                        return "5 Seconds"
                    case 2:
                        return "10 Seconds"
                    case 3:
                        return "30 Seconds"
                    case 4:
                        return "1 Minute"
                    case 5:
                        return "2 Minutes"
                    case 6:
                        return "5 Minutes"
                    case 7:
                        return "10 Minutes"
                    case 8:
                        return "30 Minutes"
                    case 9:
                        return "60 Minutes"
                    case 10:
                        return "Unlimited"
                    }
                }
                onValueChanged: {
                    editSettingsDialog.inactivityLockTimeChanged =
                            (value !== Global.env.keepassSettings.locktime ? true : false)
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: showUserNamePasswordInListView
                checked: Global.env.keepassSettings.showUserNamePasswordInListView
                text: "Extended List View"
                description: "If you switch this on username and password are shown below entry title in list views"
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordInListViewChanged =
                            (checked !== Global.env.keepassSettings.showUserNamePasswordInListView ? true : false)
                    editSettingsDialog.updateCoverState()
                }
            }

            SectionHeader {
                text: "Cover Settings"
            }

            TextSwitch {
                id: showUserNamePasswordOnCover
                checked: Global.env.keepassSettings.showUserNamePasswordOnCover
                text: "Show Username and Password"
                description: "Switching this on will show username and password of the currently opened Keepass entry on the cover"
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordOnCoverChanged =
                            (checked !== Global.env.keepassSettings.showUserNamePasswordOnCover ? true : false)
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: lockDatabaseFromCover
                checked: Global.env.keepassSettings.lockDatabaseFromCover
                text: "Lock Database from Cover"
                description: "This lets you lock the database with the left cover action"
                onCheckedChanged: {
                    editSettingsDialog.lockDatabaseFromCoverChanged =
                            (checked !== Global.env.keepassSettings.lockDatabaseFromCover ? true : false)
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: copyNpasteFromCover
                checked: Global.env.keepassSettings.copyNpasteFromCover
                text: "Copy'n'paste from Cover"
                description: "Enable this to copy username and password into clipboard from cover"
                onCheckedChanged: {
                    editSettingsDialog.copyNpasteFromCoverChanged =
                            (checked !== Global.env.keepassSettings.copyNpasteFromCover ? true : false)
                    editSettingsDialog.updateCoverState()
                }
            }
        }
    }

    onAccepted: {
        // first save locally database settings then trigger saving
        var defaultKeyFilePathTemp = ""
        if (useKeyFile.checked)
            defaultKeyFilePathTemp = defaultKeyFilePath.text
        kdbListItemInternal.setKeepassSettings(defaultDatabaseFilePath.text,
                                               defaultKeyFilePathTemp,
                                               defaultCryptAlgorithm.currentIndex,
                                               Number(defaultKeyTransfRounds.text),
                                               inactivityLockTime.value,
                                               showUserNamePasswordInListView.checked,
                                               showUserNamePasswordOnCover.checked,
                                               lockDatabaseFromCover.checked,
                                               copyNpasteFromCover.checked)
        kdbListItemInternal.saveKeepassSettings()
    }

    onRejected: {
        // no need for saving if input field for master password is invalid
        if (canNavigateForward) {
            // first save locally database settings then trigger check for unsaved changes
            var defaultKeyFilePathTemp = ""
            if (useKeyFile.checked)
                defaultKeyFilePathTemp = defaultKeyFilePath.text
            kdbListItemInternal.setKeepassSettings(defaultDatabaseFilePath.text,
                                                   defaultKeyFilePathTemp,
                                                   defaultCryptAlgorithm.currentIndex,
                                                   Number(defaultKeyTransfRounds.text),
                                                   inactivityLockTime.value,
                                                   showUserNamePasswordInListView.checked,
                                                   showUserNamePasswordOnCover.checked,
                                                   lockDatabaseFromCover.checked,
                                                   copyNpasteFromCover.checked)
            kdbListItemInternal.checkForUnsavedKeepassSettingsChanges()
        }
    }
}
