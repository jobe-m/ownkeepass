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
    id: editEntryDetailsDialog

    property bool createNewEntry: false
    // ID of the keepass entry to be edited
    property int entryId: 0
    // creation of new entry needs parent group ID
    property int parentGroupId: 0

    // The following properties are used to check if text of any entry detail was changed. If so,
    // set cover page accordingly to signal the user unsaved changes
    property string origTitle: ""
    property string origUrl: ""
    property string origUsername: ""
    property string origPassword: ""
    property string origComment: ""
    property bool titleChanged: false
    property bool urlChanged: false
    property bool usernameChanged: false
    property bool passwordChanged: false
    property bool commentChanged: false

    function setTextFields(title, url, username, password, comment) {
        entryTitleTextField.text = origTitle = title
        entryUrlTextField.text = origUrl = url
        entryUsernameTextField.text = origUsername = username
        entryPasswordTextField.text = entryVerifyPasswordTextField.text = origPassword = password
        entryCommentTextField.text = origComment = comment
    }

    // This function should be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState() {
        if (titleChanged || urlChanged || usernameChanged || passwordChanged || commentChanged) {
            applicationWindow.cover.coverState = Global.constants.databaseUnsavedChanges
        } else {
            applicationWindow.cover.coverState = Global.constants.databaseEntryOpened
        }
    }

    // forbit page navigation if title is not set and password is not verified
    canNavigateForward: entryTitleTextField.text !== "" &&
                        entryPasswordTextField.text === entryVerifyPasswordTextField.text

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
                text: editEntryDetailsDialog.createNewEntry ? "Create new Password Entry:" :
                                                              "Edit Password Entry:"
            }

            TextField {
                id: entryTitleTextField
                width: parent.width
                label: "Title"
                text: ""
                placeholderText: "Set Title (mandatory)"
                errorHighlight: text === ""
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: entryUrlTextField.focus = true
                onTextChanged: {
                    editEntryDetailsDialog.titleChanged =
                            (editEntryDetailsDialog.origTitle !== text ? true : false)
                    editEntryDetailsDialog.updateCoverState()
                }
            }

            TextField {
                id: entryUrlTextField
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                label: "Url"
                text: ""
                placeholderText: "Set Url"
                EnterKey.onClicked: entryUsernameTextField.focus = true
                onTextChanged: {
                    console.log("url updated: " + text)
                    editEntryDetailsDialog.urlChanged =
                            (editEntryDetailsDialog.origUrl !== text ? true : false)
                    editEntryDetailsDialog.updateCoverState()
                }
            }

            TextField {
                id: entryUsernameTextField
                width: parent.width
                label: "Username"
                text: ""
                placeholderText: "Set Username"
                EnterKey.onClicked: entryPasswordTextField.focus = true
                onTextChanged: {
                    editEntryDetailsDialog.usernameChanged =
                            (editEntryDetailsDialog.origUsername !== text ? true : false)
                    editEntryDetailsDialog.updateCoverState()
                }
            }

            Item {
                width: parent.width
                height: entryPasswordTextField.height

                TextField {
                    id: entryPasswordTextField
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    echoMode: TextInput.Password
                    label: "Password"
                    text: ""
                    placeholderText: "Set Password"
                    EnterKey.onClicked: entryVerifyPasswordTextField.focus = true
                    onTextChanged: {
                        editEntryDetailsDialog.passwordChanged =
                                (editEntryDetailsDialog.origPassword !== text ? true : false)
                        editEntryDetailsDialog.updateCoverState()
                    }
                }

                IconButton {
                    id: showPasswordButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    icon.source: entryPasswordTextField.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" : "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        entryPasswordTextField.forceActiveFocus()
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

            TextField {
                id: entryVerifyPasswordTextField
                width: parent.width
                echoMode: TextInput.Password
                label: "Verify Password"
                text: ""
                placeholderText: "Verify Password"
                errorHighlight: entryPasswordTextField.text !== text
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: entryCommentTextField.focus = true
            }

            TextArea {
                id: entryCommentTextField
                width: parent.width
                label: "Comment"
                text: ""
                placeholderText: "Set Comment"
                onTextChanged: {
                    editEntryDetailsDialog.commentChanged =
                            (editEntryDetailsDialog.origComment !== text ? true : false)
                    editEntryDetailsDialog.updateCoverState()
                }
            }
        }
    }

    Component.onCompleted: {
        // set reference in kdbListItemInternal object
        kdbListItemInternal.editEntryDetailsDialogRef = editEntryDetailsDialog

        kdbEntry.entryId = editEntryDetailsDialog.entryId
        if (!createNewEntry) {
            kdbEntry.loadEntryData()
        }
        entryTitleTextField.focus = true
    }
    Component.onDestruction: {
        // unset again
        kdbListItemInternal.editEntryDetailsDialogRef = null
    }

    // user wants to save new entry data
    onAccepted: {
        // first save locally Kdb entry details then trigger save to backend
        kdbListItemInternal.setKdbEntryDetails(createNewEntry,
                                    entryId,
                                    parentGroupId,
                                    entryTitleTextField.text,
                                    entryUrlTextField.text,
                                    entryUsernameTextField.text,
                                    entryPasswordTextField.text,
                                    entryCommentTextField.text)
        kdbListItemInternal.saveKdbEntryDetails()
    }
    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // first save locally Kdb entry details then trigger check for unsaved changes
            kdbListItemInternal.setKdbEntryDetails(createNewEntry,
                                        entryId,
                                        parentGroupId,
                                        entryTitleTextField.text,
                                        entryUrlTextField.text,
                                        entryUsernameTextField.text,
                                        entryPasswordTextField.text,
                                        entryCommentTextField.text)
            kdbListItemInternal.checkForUnsavedKdbEntryChanges()
        }
    }
}
