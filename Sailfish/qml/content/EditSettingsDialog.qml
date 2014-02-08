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
        if (defaultCryptAlgorithmChanged || defaultKeyTransfRoundsChanged ||
                inactivityLockTimeChanged || showUserNamePasswordInListViewChanged ||
                showUserNamePasswordOnCoverChanged || lockDatabaseFromCoverChanged ||
                copyNpasteFromCoverChanged) {
            applicationWindow.cover.coverState = Global.constants.databaseUnsavedChanges
        } else {
            applicationWindow.cover.coverState = editSettingsDialog.saveCoverState
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        ApplicationMenu {
            helpContent: "Settings"
            disableSettingsItem: true
        }

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
                text: "ownKeepass Settings"
            }

            SilicaLabel {
                text: "Change default settings of your ownKeepass Application here"
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
                    currentIndex: ownKeepassSettings.defaultCryptAlgorithm
                    menu: ContextMenu {
                        MenuItem { text: "AES/Rijndael" }
                        MenuItem { text: "Twofish" }
                    }
                    onCurrentIndexChanged: {
                        editSettingsDialog.defaultCryptAlgorithmChanged =
                                defaultCryptAlgorithm.currentIndex !== ownKeepassSettings.defaultCryptAlgorithm
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
                    validator: RegExpValidator { regExp: /^[0-9]*$/ }
                    errorHighlight: Number(text) === 0
                    label: "Default Key Transformation Rounds"
                    placeholderText: label
                    text: String(ownKeepassSettings.defaultKeyTransfRounds)
                    EnterKey.enabled: !errorHighlight
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: parent.focus = true
                    onTextChanged: {
                        editSettingsDialog.defaultKeyTransfRoundsChanged =
                                Number(defaultKeyTransfRounds.text) !== ownKeepassSettings.defaultKeyTransfRounds
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
                value: ownKeepassSettings.locktime
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
                    editSettingsDialog.inactivityLockTimeChanged = inactivityLockTime.value !== ownKeepassSettings.locktime
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: showUserNamePasswordInListView
                checked: ownKeepassSettings.showUserNamePasswordInListView
                text: "Extended List View"
                description: "If you switch this on username and password are shown below entry title in list views"
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordInListViewChanged =
                            showUserNamePasswordInListView.checked !== ownKeepassSettings.showUserNamePasswordInListView
                    editSettingsDialog.updateCoverState()
                }
            }

            SectionHeader {
                text: "Cover Settings"
            }

            TextSwitch {
                id: showUserNamePasswordOnCover
                checked: ownKeepassSettings.showUserNamePasswordOnCover
                text: "Show Username and Password"
                description: "Switching this on will show username and password of the currently opened Keepass entry on the cover"
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordOnCoverChanged =
                            showUserNamePasswordOnCover.checked !== ownKeepassSettings.showUserNamePasswordOnCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: lockDatabaseFromCover
                checked: ownKeepassSettings.lockDatabaseFromCover
                text: "Lock Database from Cover"
                description: "This lets you lock the database with the left cover action"
                onCheckedChanged: {
                    editSettingsDialog.lockDatabaseFromCoverChanged =
                            lockDatabaseFromCover.checked !== ownKeepassSettings.lockDatabaseFromCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: copyNpasteFromCover
                checked: ownKeepassSettings.copyNpasteFromCover
                text: "Copy'n'paste from Cover"
                description: "Enable this to copy username and password into clipboard from cover"
                onCheckedChanged: {
                    editSettingsDialog.copyNpasteFromCoverChanged =
                            copyNpasteFromCover.checked !== ownKeepassSettings.copyNpasteFromCover
                    editSettingsDialog.updateCoverState()
                }
            }
        }
    }

    onAccepted: {
        // First save locally ownKeepass settings then trigger saving
        kdbListItemInternal.setKeepassSettings(
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
        // Save ownKeepass settings to check for unsaved changes
        kdbListItemInternal.setKeepassSettings(
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
