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

    function updateCoverState() {
        if (saveCoverState === -1) // save initial state
            editSettingsDialog.saveCoverState = applicationWindow.cover.coverState
        if (defaultDatabaseFilePathChanged || defaultKeyFilePathChanged ||
                defaultCryptAlgorithmChanged || defaultKeyTransfRoundsChanged ||
                inactivityLockTimeChanged || showUserNamePasswordInListViewChanged) {
            applicationWindow.cover.coverState = Global.constants.databaseUnsavedChanges
        } else {
            applicationWindow.cover.coverState = editSettingsDialog.saveCoverState
        }
    }

    // forbit page navigation if master password is not confirmed
    canNavigateForward: !defaultDatabaseFilePath.errorHighlight

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

            SectionHeader {
                text: "Keepass Settings"
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

                TextField {
                    id: defaultDatabaseFilePath
                    width: parent.width
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    label: "Default database file path"
                    placeholderText: label
                    errorHighlight: text === ""
                    text: Global.env.keepassSettings.defaultDatabasePath
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editSettingsDialog.defaultDatabaseFilePathChanged =
                                (text !== Global.env.keepassSettings.defaultDatabasePath ? true : false)
                        editSettingsDialog.updateCoverState()
                    }
                }

                SilicaLabel {
                    text: Global.env.keepassSettings.simpleMode ?
                              "This is the name and path of default Keepass database file" :
                              "This is the path where new Keepass Password Safe files will be stored"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            TextSwitch {
                id: useKeyFile
                checked: Global.env.keepassSettings.defaultKeyFilePath !== ""
                text: "Create Key File"
                description: "Switch this on if you want to create a key file together with a new Keepass Password Safe file"
            }

            TextField {
                id: defaultKeyFilePath
                enabled: useKeyFile.checked
                opacity: useKeyFile.checked ? 1.0 : 0.0
                height: useKeyFile.checked ? implicitHeight : 0
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                label: "Default key file path"
                placeholderText: label
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

                ComboBox {
                    id: defaultCryptAlgorithm
                    width: editSettingsDialog.width
                    label: "Default Encryption in use:"
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

                SilicaLabel {
                    text: "Choose encryption which will be used as default for a new Keepass Password Safe file"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            Column {
                width: parent.width

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
                                    showUserNamePasswordInListView.checked)
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
                                        showUserNamePasswordInListView.checked)
            kdbListItemInternal.checkForUnsavedKeepassSettingsChanges()
        }
    }
}
