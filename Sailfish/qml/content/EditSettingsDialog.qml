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
import harbour.ownkeepass 1.0
import "../scripts/Global.js" as Global
import "../common"

Dialog {
    id: editSettingsDialog

    // save cover state because database settings page can be opened from various
    // pages like list view or edit dialogs, which have different cover states
    property string saveCoverState: ""
    property string saveCoverTitle: ""
    property bool defaultCryptAlgorithmChanged: false
    property bool defaultKeyTransfRoundsChanged: false
    property bool inactivityLockTimeChanged: false
    property bool fastUnlockChanged: false
    property bool fastUnlockRetryCountChanged: false
    property bool sortAlphabeticallyInListViewChanged: true
    property bool showUserNamePasswordInListViewChanged: false
    property bool focusSearchBarOnStartupChanged: false
    property bool showUserNamePasswordOnCoverChanged: false
    property bool lockDatabaseFromCoverChanged: false
    property bool copyNpasteFromCoverChanged: false
    property bool clearClipboardChanged: false
    property bool expertModeChanged: false
    property bool languageChanged: false
    property bool uiOrientationChanged: false

    function updateCoverState() {
        if (saveCoverState === "") // save initial state
            saveCoverState = applicationWindow.cover.state
        if (saveCoverTitle === "") // save initial state
            saveCoverTitle = applicationWindow.cover.title
        if (expertModeChanged || defaultCryptAlgorithmChanged || defaultKeyTransfRoundsChanged ||
                inactivityLockTimeChanged || fastUnlockChanged || fastUnlockRetryCountChanged ||
                sortAlphabeticallyInListViewChanged ||
                showUserNamePasswordInListViewChanged || focusSearchBarOnStartupChanged ||
                showUserNamePasswordOnCoverChanged || lockDatabaseFromCoverChanged ||
                copyNpasteFromCoverChanged || clearClipboardChanged || languageChanged ||
                uiOrientationChanged ) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
            applicationWindow.cover.title = "Settings"
        } else {
            applicationWindow.cover.state = saveCoverState
            applicationWindow.cover.title = saveCoverTitle
        }
    }

    allowedOrientations: applicationWindow.orientationSetting

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        ApplicationMenu {
            disableSettingsItem: true
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
                title: qsTr("ownKeepass Settings")
            }

            SilicaLabel {
                text: qsTr("Change default settings of your ownKeepass application here")
            }

            SectionHeader {
                text: qsTr("Database")
            }

            ComboBox {
                id: defaultCryptAlgorithm
                width: editSettingsDialog.width
                label: qsTr("Default encryption")
                description: qsTr("This is the encryption which will be used as default when creating a new Keepass 1 database.")
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

            Column {
                width: parent.width
                spacing: 0

                TextField {
                    id: defaultKeyTransfRounds
                    width: parent.width
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: RegExpValidator { regExp: /^[0-9]*$/ }
                    errorHighlight: Number(text) === 0
                    label: qsTr("Default key transformation rounds")
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
                    text: qsTr("Setting this value higher increases opening time of the Keepass database but makes it more robust against brute force attacks")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: qsTr("Security")
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
                label: qsTr("Inactivity lock time")
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
                        return qsTr("Immediately")
                    case 1:
                        return "5 " + qsTr("seconds")
                    case 2:
                        return "10 " + qsTr("seconds")
                    case 3:
                        return "30 " + qsTr("seconds")
                    case 4:
                        return "1 " + qsTr("minute")
                    case 5:
                        return "2 " + qsTr("minutes")
                    case 6:
                        return "5 " + qsTr("minutes")
                    case 7:
                        return "10 " + qsTr("minutes")
                    case 8:
                        return "30 " + qsTr("minutes")
                    case 9:
                        return "60 " + qsTr("minutes")
                    case 10:
                        return qsTr("Unlimited")
                    }
                }
                onValueChanged: {
                    editSettingsDialog.inactivityLockTimeChanged = inactivityLockTime.value !== ownKeepassSettings.locktime
                    editSettingsDialog.updateCoverState()
                }
            }

            Column {
                width: parent.width
                height: fastUnlockRetryCount.enabled ? fastUnlock.height + fastUnlockRetryCount.height : fastUnlock.height
                spacing: 0

                Behavior on height { NumberAnimation { duration: 500 } }

                TextSwitch {
                    id: fastUnlock
                    checked: ownKeepassSettings.fastUnlock
                    text: qsTr("Fast unlock")
                    description: qsTr("Enable this to unlock your database quickly with just the first 3 characters of your master password.")
                    onCheckedChanged: {
                        editSettingsDialog.fastUnlockChanged = fastUnlock.checked !== ownKeepassSettings.fastUnlock
                        editSettingsDialog.updateCoverState()
                    }
                }

                Slider {
                    id: fastUnlockRetryCount
                    enabled: fastUnlock.checked
                    opacity: enabled ? 1.0 : 0.0
                    value: ownKeepassSettings.fastUnlockRetryCount
                    minimumValue: 0
                    maximumValue: 5
                    stepSize: 1
                    width: parent.width - Theme.paddingLarge * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    valueText: value
                    label: qsTr("Number of fast unlock retries")
                    onValueChanged: {
                        editSettingsDialog.fastUnlockRetryCountChanged = fastUnlockRetryCount.value !== ownKeepassSettings.fastUnlockRetryCount
                        editSettingsDialog.updateCoverState()
                    }

                    Behavior on opacity { FadeAnimation { duration: 500 } }
                }
            }

            TextSwitch {
                id: clearClipboard
                checked: ownKeepassSettings.clearClipboard !== 0
                text: qsTr("Clear clipboard")
                description: qsTr("If enabled the clipboard will be cleared after 10 seconds when username or password is copied")
                onCheckedChanged: {
                    // This workaround makes it possible to replace this simple switch later with a slider setting which will control timer value
                    var clearClipboardTimer = clearClipboard.checked ? 10 : 0
                    editSettingsDialog.clearClipboardChanged = clearClipboardTimer !== ownKeepassSettings.clearClipboard
                    editSettingsDialog.updateCoverState()
                }
            }

            SectionHeader {
                text: qsTr("UI settings")
            }

            ComboBox {
                id: uiOrientation
                width: editSettingsDialog.width
                label: qsTr("Orientation")
                description: qsTr("Change here orientation of the display")
                currentIndex: ownKeepassSettings.uiOrientation
                menu: ContextMenu {
                    //: Dynamic means that the display orientation is changed according how the device is hold by the user
                    MenuItem { text: "Dynamic" } // 0
                    MenuItem { text: "Portrait" } // 1
                    MenuItem { text: "Landscape" } // 2
                }

                onCurrentIndexChanged: {
                    editSettingsDialog.uiOrientationChanged =
                            uiOrientation.currentIndex !== ownKeepassSettings.uiOrientation
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: sortAlphabeticallyInListView
                checked: ownKeepassSettings.sortAlphabeticallyInListView
                text: qsTr("Sort in alphabetical order")
                description: qsTr("Switching this on will sort all entries in the list view in alphabetical order otherwise database internal order is used (reopen database to activate this setting)")
                onCheckedChanged: {
                    editSettingsDialog.sortAlphabeticallyInListViewChanged =
                            sortAlphabeticallyInListView.checked !== ownKeepassSettings.sortAlphabeticallyInListView
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: showUserNamePasswordInListView
                checked: ownKeepassSettings.showUserNamePasswordInListView
                text: qsTr("Extended list view")
                description: qsTr("If you switch this on username and password are shown below entry title in list views (reopen database to activate this setting)")
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordInListViewChanged =
                            showUserNamePasswordInListView.checked !== ownKeepassSettings.showUserNamePasswordInListView
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: focusSearchBarOnStartup
                checked: ownKeepassSettings.focusSearchBarOnStartup
                text: qsTr("Focus search bar")
                description: qsTr("If enabled the search bar will be focused on application startup")
                onCheckedChanged: {
                    editSettingsDialog.focusSearchBarOnStartupChanged =
                            focusSearchBarOnStartup.checked !== ownKeepassSettings.focusSearchBarOnStartup
                    editSettingsDialog.updateCoverState()
                }
            }

            ComboBox {
                id: language
                width: editSettingsDialog.width
                label: qsTr("Language")
                description: qsTr("Change of language will be active in ownKeepass after restarting the application")
                currentIndex: toCurrentIndex(ownKeepassSettings.language)
                menu: ContextMenu {
                    MenuItem { text: qsTr("System default") } // 0
                    MenuItem { text: "Bokmål" } // 1 (Norwegian Bokmål)
                    MenuItem { text: "Català" } // 2 (Catalan)
                    MenuItem { text: "Čeština" } // 3 (Czech)
                    MenuItem { text: "Dansk" } // 4 (Danish)
                    MenuItem { text: "Deutsch" } // 5 (German)
                    MenuItem { text: "English" } // 6 (English)
                    MenuItem { text: "Español" }  // 7 (Spanish)
                    MenuItem { text: "Français" } // 8 (French)
                    MenuItem { text: "Italiano" } // 9 (Italian)
                    MenuItem { text: "Nederlands" } // 10 (Dutch)
                    MenuItem { text: "Pу́сский" } // 11 (Russian)
                    MenuItem { text: "Suomi" } // 12 (Finnish)
                    MenuItem { text: "Svenska" } // 13 (Swedish)
                    MenuItem { text: "中文" } // 14 (Chinese)
                }

                // The next two converter functions decouple the alphabetical language list
                // index from the internal settings index, which cannot be changed for legacy reasons
                function toCurrentIndex(value) {
                    switch (value) {
                    case Language.SYSTEM_DEFAULT:
                        return Global.system_default
                    case Language.EN: // English
                        return Global.english
                    case Language.SV_SE: // Swedish
                        return Global.swedish
                    case Language.FI_FI: // Finnish
                        return Global.finnish
                    case Language.DE_DE: // German
                        return Global.german
                    case Language.CS_CZ: // Czech
                        return Global.czech
                    case Language.CA: // Catalan
                        return Global.catalan
                    case Language.NL_NL: // Dutch
                        return Global.dutch
                    case Language.ES: // Spanish
                        return Global.spanish
                    case Language.FR_FR: // French
                        return Global.french
                    case Language.IT: // Itanian
                        return Global.italian
                    case Language.RU: // Russian
                        return Global.russian
                    case Language.DA: // Danish
                        return Global.danish
                    case Language.PL_PL: // Polish
                        return Global.polish
                    case Language.ZH_CN: // Chinese
                        return Global.chinese
                    case Language.UK_UA: // Ukrainian
                        return Global.ukrainian
                    case Language.NB_NO: // Norwegian Bokmål
                        return Global.norwegian_bokmal
                    default:
                        return Global.english
                    }
                }

                function toSettingsIndex(value) {
                    switch (value) {
                    case Global.system_default:
                        return Language.SYSTEM_DEFAULT
                    case Global.english:
                        return Language.EN // English
                    case Global.swedish:
                        return Language.SV_SE // Swedish
                    case Global.finnish:
                        return Language.FI_FI // Finnish
                    case Global.german:
                        return Language.DE_DE // German
                    case Global.czech:
                        return Language.CS_CZ // Czech
                    case Global.catalan:
                        return Language.CA // Catalan
                    case Global.dutch:
                        return Language.NL_NL // Dutch
                    case Global.spanish:
                        return Language.ES // Spanish
                    case Global.french:
                        return Language.FR_FR // French
                    case Global.italian:
                        return Language.IT // Italian
                    case Global.russian:
                        return Language.RU // Russian
                    case Global.danish:
                        return Language.DA // Danish
                    case Global.polish:
                        return Language.PL_PL // Polish
                    case Global.chinese:
                        return Language.ZH_CN // Chinese
                    case Global.ukrainian:
                        return Language.UK_UA // Ukrainian
                    case Global.norwegian_bokmal:
                        return Language.NB_NO // Norwegian Bokmål
                    default:
                        return Language.EN // English
                    }
                }

                onCurrentIndexChanged: {
                    editSettingsDialog.languageChanged =
                            toSettingsIndex(language.currentIndex) !== ownKeepassSettings.language
                    editSettingsDialog.updateCoverState()
                }
            }

            SectionHeader {
                text: qsTr("Cover settings")
            }

            TextSwitch {
                id: showUserNamePasswordOnCover
                checked: ownKeepassSettings.showUserNamePasswordOnCover
                text: qsTr("Show username and password")
                description: qsTr("Switching this on will show username and password of the currently opened Keepass entry on the cover")
                onCheckedChanged: {
                    editSettingsDialog.showUserNamePasswordOnCoverChanged =
                            showUserNamePasswordOnCover.checked !== ownKeepassSettings.showUserNamePasswordOnCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: lockDatabaseFromCover
                checked: ownKeepassSettings.lockDatabaseFromCover
                text: qsTr("Lock database from cover")
                description: qsTr("This lets you lock the database with the left cover action")
                onCheckedChanged: {
                    editSettingsDialog.lockDatabaseFromCoverChanged =
                            lockDatabaseFromCover.checked !== ownKeepassSettings.lockDatabaseFromCover
                    editSettingsDialog.updateCoverState()
                }
            }

            TextSwitch {
                id: copyNpasteFromCover
                checked: ownKeepassSettings.copyNpasteFromCover
                text: qsTr("Copy'n'paste from cover")
                description: qsTr("Enable this to copy username and password into clipboard from cover")
                onCheckedChanged: {
                    editSettingsDialog.copyNpasteFromCoverChanged =
                            copyNpasteFromCover.checked !== ownKeepassSettings.copyNpasteFromCover
                    editSettingsDialog.updateCoverState()
                }
            }
/*
            SectionHeader {
                text: qsTr("Advanced settings")
            }

            TextSwitch {
                id: expertMode
                checked: !ownKeepassSettings.simpleMode
                text: qsTr("Expert user mode")
                description: qsTr("This enables advanced functionality like handling multiple databases on main page")
                onCheckedChanged: {
                    expertModeChanged = checked === ownKeepassSettings.simpleMode
                    updateCoverState()
                }
            }
*/
        }
    }

    onAccepted: {
        // First save locally ownKeepass settings then trigger saving
        kdbListItemInternal.setKeepassSettings(
                    defaultCryptAlgorithm.currentIndex,
                    Number(defaultKeyTransfRounds.text),
                    inactivityLockTime.value,
                    sortAlphabeticallyInListView.checked,
                    showUserNamePasswordInListView.checked,
                    focusSearchBarOnStartup.checked,
                    showUserNamePasswordOnCover.checked,
                    lockDatabaseFromCover.checked,
                    copyNpasteFromCover.checked,
                    clearClipboard.checked ? 10 : 0,
                    language.toSettingsIndex(language.currentIndex),
                    fastUnlock.checked,
                    fastUnlockRetryCount.value,
                    uiOrientation.currentIndex)
        kdbListItemInternal.saveKeepassSettings()
    }

    onRejected: {
        // Save ownKeepass settings to check for unsaved changes
        kdbListItemInternal.setKeepassSettings(
                    defaultCryptAlgorithm.currentIndex,
                    Number(defaultKeyTransfRounds.text),
                    inactivityLockTime.value,
                    sortAlphabeticallyInListView.checked,
                    showUserNamePasswordInListView.checked,
                    focusSearchBarOnStartup.checked,
                    showUserNamePasswordOnCover.checked,
                    lockDatabaseFromCover.checked,
                    copyNpasteFromCover.checked,
                    clearClipboard.checked ? 10 : 0,
                    language.toSettingsIndex(language.currentIndex),
                    fastUnlock.checked,
                    fastUnlockRetryCount.value,
                    uiOrientation.currentIndex)
        kdbListItemInternal.checkForUnsavedKeepassSettingsChanges()
    }
}
