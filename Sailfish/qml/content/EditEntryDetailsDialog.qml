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

    // ID of the keepass entry to be edited
    property string entryId: ""
    property bool createNewEntry: false

    // This function will be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState(changesDone) {
        if (changesDone) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
        } else {
            applicationWindow.cover.state = "ENTRY_VIEW"
        }
    }

    // forbit page navigation if title is not set and password is not verified (if password field shows the password in cleartext)
    canNavigateForward: !entryTitleTextField.errorHighlight && (!entryVerifyPasswordTextField.enabled || !entryVerifyPasswordTextField.errorHighlight)
    allowedOrientations: applicationWindow.orientationSetting

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
                            pageStack.push( editItemIconDialog, { "newIconUuid": kdbEntry.iconUuid })
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
                    kdbEntry.title = text
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1  // prevent the "abc" password mode button to steal focus
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
                    kdbEntry.url = text
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
                    kdbEntry.userName = text
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1
            }

            Column {
                id: passwordColumn
                width: parent.width
                height: entryPasswordTextField.echoMode === TextInput.Password
                        ? entryPasswordTextField.height + entryVerifyPasswordTextField.height + spacing
                        : entryPasswordTextField.height

                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                PasswordField {
                    id: entryPasswordTextField
                    width: parent.width
                    showEchoModeToggle: true
                    horizontalAlignment: TextInput.AlignLeft
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    label: qsTr("Password")
                    placeholderText: qsTr("Set password")
                    font.family: 'monospace'
                    text: kdbEntry.password
                    onTextChanged: {
                        kdbEntry.password = text
                        updateCoverState(kdbEntry.edited)
                    }
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        // Check which field gets focus when pressing EnterKey
                        if (entryVerifyPasswordTextField.enabled) {
                            entryVerifyPasswordTextField.focus = true
                        } else {
                            entryCommentTextField.focus = true
                        }
                    }
                    focusOutBehavior: -1
                }

                PasswordField {
                    id: entryVerifyPasswordTextField
                    width: parent.width
                    horizontalAlignment: TextInput.AlignLeft
                    enabled: entryPasswordTextField.echoMode === TextInput.Password
                    opacity: enabled ? 1.0 : 0.0
                    showEchoModeToggle: false
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    label: qsTr("Password")
                    placeholderText: qsTr("Verify password")
                    font.family: 'monospace'
                    text: kdbEntry.password
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

                    Behavior on opacity { FadeAnimation { duration: 200; easing.type: Easing.OutQuad } }
                }
            }

            Button {
                width: parent.width * 0.65
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Generate password")
                onClicked: {
                    var pwGenDialog = pageStack.push("PasswordGeneratorDialog.qml")
                    pwGenDialog.accepted.connect(function() {
                        entryPasswordTextField.text =
                                entryVerifyPasswordTextField.text = pwGenDialog.generatedPassword
                    })
                }
            }

            TextArea {
                id: entryCommentTextField
                width: parent.width
                label: qsTr("Comment")
                text: kdbEntry.notes
                placeholderText: qsTr("Set comment")
                onTextChanged: {
                    kdbEntry.notes = text
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1
            }

// TODO implement SilicaListView for editing additional attributes
// Implement also backend in kdbEntry to change additional attributes...

            SilicaListView {
                id: additionalAttributesListView
                width: parent.width
                model: kdbEntry

                delegate: Item {
                    id: additionalAttributesDelegate
                    width: parent.width
                    height: additionalAttributesTextArea.height + additionalAttributesButtons.height + Theme.paddingLarge

                    TextArea {
                        id: additionalAttributesTextArea
                        width: parent.width
                        anchors.top: parent.top
                        label: model.key
                        text: model.value
                        placeholderText: qsTr("Set") + " " + model.key
                        onTextChanged: {
                            // Check if editing additional attribute value
                            // Additional attribute key will be saved in button onClicked handler below
                            if (!model.editKeyMode) {
                                model.value = text
                                updateCoverState(kdbEntry.edited)
                            }
                        }
                    }

// TODO Add TextField for editing key

                    Row {
                        id: additionalAttributesButtons
                        anchors.top: additionalAttributesTextArea.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.horizontalPageMargin
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        spacing: (width / 2) * 0.1
                        height: Theme.itemSizeSmall //+ Theme.paddingMedium

                        Button {
                            id: editLabelButton
                            width: (parent.width / 2) * 0.95
                            anchors.bottom: parent.bottom
                            text: qsTr("Edit Label")
                            onClicked: {
                                if (model.editKeyMode) {
                                    model.editKeyMode = false
                                    // change to edit additional attribute value
                                    text = qsTr("Edit Label")
                                    deleteAdditionalAttributeButton.text = qsTr("Delete")
                                    additionalAttributesTextArea.text = model.value
                                    additionalAttributesTextArea.label = model.key
                                    additionalAttributesTextArea.placeholderText = qsTr("Set") + " " + model.key
                                } else {
                                    model.editKeyMode = true
                                    // change to edit additional attribute key (label)
                                    text = qsTr("Cancel")
                                    deleteAdditionalAttributeButton.text = qsTr("Accept")
                                    additionalAttributesDelegate.enabled = true
                                    additionalAttributesTextArea.text = model.key
                                    additionalAttributesTextArea.label = qsTr("Edit Label")
                                    additionalAttributesTextArea.placeholderText = qsTr("Edit Label")
                                }
                            }
                        }

                        Button {
                            id: deleteAdditionalAttributeButton
                            width: (parent.width / 2) * 0.95
                            anchors.bottom: parent.bottom
                            text: qsTr("Delete")
                            onClicked: {
                                if (model.editKeyMode) {
                                    model.editKeyMode = false
                                    // Accept changes of additional attribute Key and save it
                                    model.key = additionalAttributesTextArea.text
                                    updateCoverState(kdbEntry.edited)
                                    text = qsTr("Delete")
                                    editLabelButton.text = qsTr("Edit Label")
                                    additionalAttributesTextArea.text = model.value
                                    additionalAttributesTextArea.label = model.key
                                    additionalAttributesTextArea.placeholderText = qsTr("Set") + " " + model.key
                                } else {
                                    model.editKeyMode = true
                                    // Set marker to delete additional attribute
                                    model.toBeDeleted = true
                                }
                            }
                        }
                    }

                    Item {
                        height: Theme.paddingLarge
                        width: parent.width
                        anchors.top: additionalAttributesButtons.bottom
                    }
                }

                Connections {
                    // for breaking the binding loop on height
                    onContentHeightChanged: additionalAttributesListView.height = additionalAttributesListView.contentHeight
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
            updateCoverState(kdbEntry.edited)
        }
    }

    Component.onCompleted: {
        if (createNewEntry) {
            kdbEntry.clearData()
        }
        entryTitleTextField.focus = true
    }

    // user wants to save new entry data
    onAccepted: {
        // trigger save entry data to backend
        kdbListItemInternal.saveKdbEntryDetails(createNewEntry)
    }

    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // trigger check for unsaved changes
            kdbListItemInternal.checkForUnsavedKdbEntryChanges()
        }
    }
}
