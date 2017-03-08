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
    id: editEntryDetailsDialog

    property bool createNewEntry: false
    // ID of the keepass entry to be edited
    property string entryId: ""
    // creation of new entry needs parent group ID
    property string parentGroupId: ""
    // icon for entry (either a default icon or a custom database icon)
//    property string iconUuid: ""

    // The following properties are used to check if text of any entry detail was changed. If so,
    // set cover page accordingly to signal the user unsaved changes
/*    property string origTitle: ""
    property string origUrl: ""
    property string origUsername: ""
    property string origPassword: ""
    property string origComment: ""
    property string origIconUuid : ""
    property bool titleChanged: false
    property bool urlChanged: false
    property bool usernameChanged: false
    property bool passwordChanged: false
    property bool commentChanged: false
    property bool iconUuidChanged: false
*/
/*    function setTextFields(keys, values, aIconUuid) {
        var maxKeys = keys.length
        var i = 5
        customKeyValueList.clear()
        while (i < maxKeys) {
            customKeyValueList.append({"key": keys[i], "value": values[i], "oldValue": values[i]})
            ++i
        }
        entryTitleTextField.text          = origTitle    = values[KeepassDefault.TITLE]
        entryUrlTextField.text            = origUrl      = values[KeepassDefault.URL]
        entryUsernameTextField.text       = origUsername = values[KeepassDefault.USERNAME]
        entryPasswordTextField.text       =
        entryVerifyPasswordTextField.text = origPassword = values[KeepassDefault.PASSWORD]
        entryCommentTextField.text        = origComment  = values[KeepassDefault.NOTES]
        iconUuid = origIconUuid = aIconUuid
    }
*/
    // This function should be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState(value) {
        if (value) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
        } else {
            applicationWindow.cover.state = "ENTRY_VIEW"
        }
    }

    // Get all values from the various text input fields and feed into the kdbEntry object
    function prepareSaveEntryDetails() {
        kdbEntry.title    = entryTitleTextField.text
        kdbEntry.url      = entryUrlTextField.text
        kdbEntry.userName = entryUsernameTextField.text
        kdbEntry.password = entryPasswordTextField.text
        kdbEntry.notes    = entryCommentTextField.text
    }

    // set group icon for image element
//    onIconUuidChanged: {
//        iconUuidChanged = origIconUuid !== iconUuid ? true : false
//        entryIcon.source = "image://KeepassIcon/" + iconUuid
//    }

    // forbit page navigation if title is not set and password is not verified and icon not set
    canNavigateForward: !entryTitleTextField.errorHighlight && !entryVerifyPasswordTextField.errorHighlight
    allowedOrientations: applicationWindow.orientationSetting

// TODO feature/save_dkb2_entry
    ListModel {
        id: customKeyValueList
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        PullDownMenu {
            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
            }
        }

        ApplicationMenu {
            disableSettingsItem: true
        }

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
            }

            SilicaLabel {
                text: qsTr("Change icon:")
            }

            Item {
                width: parent.width
                height: entryIconBackground.height

                Image {
                    id: entryIconBackground
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.itemSizeMedium
                    height: Theme.itemSizeMedium
                    source: "image://IconBackground"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    MouseArea {
                        id: entryIconMouseArea
                        anchors.fill: parent
                        onClicked: {
                            // open new dialog with grid of all icons
                            pageStack.push( editItemIconDialog,
                                           { "newIconUuid": kdbEntry.iconUuid })
                        }
                    }
                }

                Image {
                    id: entryIcon
                    anchors.centerIn: parent
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    opacity: entryIconMouseArea.pressed ? 0.5 : 1.0
                    source: "image://KeepassIcon/" + kdbEntry.iconUuid
                }

                Rectangle {
                    anchors.fill: entryIconBackground
                    color: entryIconMouseArea.pressed ?
                               Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                             : "transparent"
                }
            }

            SilicaLabel {
                text: editEntryDetailsDialog.createNewEntry ? qsTr("Create new password entry:") :
                                                              qsTr("Edit password entry:")
            }

            TextField {
                id: entryTitleTextField
                width: parent.width
                inputMethodHints: Qt.ImhSensitiveData
                label: qsTr("Title")
                text: kdbEntry.title
                placeholderText: qsTr("Set title (mandatory)")
                errorHighlight: text.length === 0
                EnterKey.enabled: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entryUrlTextField.focus = true
                onTextChanged: {
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1 // This doesn't let the eye button steal focus
            }

            TextField {
                id: entryUrlTextField
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhSensitiveData
                label: qsTr("URL")
                text: kdbEntry.url
                placeholderText: qsTr("Set URL")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entryUsernameTextField.focus = true
                onTextChanged: {
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1
            }

            TextField {
                id: entryUsernameTextField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                label: qsTr("Username")
                text: kdbEntry.userName
                placeholderText: qsTr("Set username")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: entryPasswordTextField.focus = true
                onTextChanged: {
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1
            }

            Item {
                width: parent.width
                height: entryPasswordTextField.height

                TextField {
                    id: entryPasswordTextField
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    label: qsTr("Password")
                    text: kdbEntry.password
                    font.family: 'monospace'
                    placeholderText: qsTr("Set password")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: entryVerifyPasswordTextField.focus = true
                    onTextChanged: {
                        updateCoverState(kdbEntry.edited)
                    }
                    focusOutBehavior: -1
                }

                IconButton {
                    id: showPasswordButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    icon.source: entryPasswordTextField.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" : "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        if (entryPasswordTextField.echoMode === TextInput.Normal) {
                            entryPasswordTextField.echoMode =
                                    entryVerifyPasswordTextField.echoMode = TextInput.Password
                        } else {
                            entryPasswordTextField.echoMode =
                                    entryVerifyPasswordTextField.echoMode = TextInput.Normal
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: entryVerifyPasswordTextField.height

                TextField {
                    id: entryVerifyPasswordTextField
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: generatePasswordButton.left
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    label: qsTr("Verify password")
                    text: ""
                    font.family: 'monospace'
                    placeholderText: qsTr("Verify password")
                    errorHighlight: entryPasswordTextField.text !== text
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        // if password not yet verified go back to password field
                        if (entryPasswordTextField.text !== text) {
                            entryPasswordTextField.focus = true
                        } else {
                            entryCommentTextField.focus = true
                        }
                    }
                    focusOutBehavior: -1
                }

                IconButton {
                    id: generatePasswordButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    icon.source: "../../wallicons/icon-l-generator.png"
                    onClicked: {
                        var pwGenDialog = pageStack.push("PasswordGeneratorDialog.qml")
                        pwGenDialog.accepted.connect(function() {
                            entryPasswordTextField.text =
                                    entryVerifyPasswordTextField.text = pwGenDialog.generatedPassword
                        })
                    }
                }
            }

            TextArea {
                id: entryCommentTextField
                width: parent.width
                label: qsTr("Comment")
                text: kdbEntry.notes
                placeholderText: qsTr("Set comment")
                onTextChanged: {
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1
            }

            Repeater {
                model: customKeyValueList

                TextArea {
                    width: parent.width
                    label: key
                    text: value
                    onTextChanged: {
// TODO feature/save_dkb2_entry
// Check if text has changed...
                        console.log("Changed text for: " + index)
                    }
                }
            }
        }
    }

    EditItemIconDialog {
        id: editItemIconDialog
        itemType: DatabaseItemType.ENTRY

        onAccepted: {
            entryIcon.source = "image://KeepassIcon/" + newIconUuid
            kdbEntry.iconUuid = newIconUuid
        }
    }

    Component.onCompleted: {
        // set reference in kdbListItemInternal object
//        kdbListItemInternal.editEntryDetailsDialogRef = editEntryDetailsDialog

        kdbEntry.entryId = entryId
        if (!createNewEntry) {
            kdbEntry.loadEntryData()
        }
        entryTitleTextField.focus = true
    }

    Component.onDestruction: {
        // unset again
//        kdbListItemInternal.editEntryDetailsDialogRef = null
    }

    // user wants to save new entry data
    onAccepted: {
        // first save locally Kdb entry details then trigger save to backend
        prepareSaveEntryDetails()
        kdbListItemInternal.saveKdbEntryDetails(createNewEntry)
    }
    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // first save locally Kdb entry details then trigger check for unsaved changes
            prepareSaveEntryDetails()
            kdbListItemInternal.checkForUnsavedKdbEntryChanges()
        }
    }
}
