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

    // This function will be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState(changesDone) {
        if (changesDone) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
        } else {
            applicationWindow.cover.state = "ENTRY_VIEW"
            applicationWindow.cover.username = kdbEntry.userName
            applicationWindow.cover.password = kdbEntry.password
        }
    }

    // forbit page navigation if title is not set and password is not verified (if password field shows the password in cleartext)
    canNavigateForward: !entryTitleTextFieldRef.errorHighlight &&
                        (!entryVerifyPasswordTextFieldRef.enabled || !entryVerifyPasswordTextFieldRef.errorHighlight) &&
                        !kdbEntry.invalidKey
    allowedOrientations: applicationWindow.orientationSetting

    // References for accessing properties inside the Component below
    property Image entryIconRef: null
    property DialogHeader headerRef: null
    property TextField entryTitleTextFieldRef: null
    property PasswordField entryVerifyPasswordTextFieldRef: null

    Component {
        id: headerComp

        Column {
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                id: header
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
                spacing: 0
                Component.onCompleted: headerRef = header
            }

            SectionHeader {
                text: qsTr("Change icon")
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
                    Component.onCompleted: entryIconRef = entryIcon
                }

                Rectangle {
                    anchors.fill: entryIconBackground
                    color: entryIconMouseArea.pressed ?
                               Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                             : "transparent"
                }
            }

            SectionHeader {
                text: qsTr("Change password entry details")
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
                Component.onCompleted: entryTitleTextFieldRef = entryTitleTextField
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

            Column {
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
                        if (echoMode !== TextInput.Password) {
                            entryVerifyPasswordTextField.text = text
                        }
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

                    Component.onCompleted: entryVerifyPasswordTextFieldRef = entryVerifyPasswordTextField
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

            SectionHeader {
                id: additionalAttributesSection
                enabled: ownKeepassDatabase.type === DatabaseType.DB_TYPE_KEEPASS_2
                visible: enabled
                text: qsTr("Change additional attributes")
            }

            // dummy for last padding space
            Item {
                height: 1
                width: parent.width
            }
        }
    }

    SilicaListView {
        id: listView
        model: kdbEntry
        anchors.fill: parent
        clip: true
        spacing: Theme.paddingMedium

        PullDownMenu {
            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
            }
        }

        ApplicationMenu {
            disableNewEntryAttribute: false
            disableSettingsItem: true
            onAddAdditionalAttribute: {
                kdbEntry.addAdditionalAttribute()
            }
        }

        header: headerComp

        footer: Item { // give the last item in the list some space to the bottom
            height: listView.spacing // Theme.paddingMedium
            width: parent.width
        }

        delegate: Item {
            id: additionalAttributesDelegate
            enabled: !model.toBeDeleted
            visible: enabled
            width: parent.width

            height: enabled ? (additionalAttributesButtons.height + additionalAttributesEditText.height +
                               additionalAttributesEditLabel.height + additionalAttributesBottomPadding.height)
                            : 0

            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

            function listItemRemove() {
                Remorse.itemAction(additionalAttributesDelegate,
                                   "Deleting",
                                   function() {
                                       // Set marker to delete additional attribute
                                       model.toBeDeleted = true
                                       additionalAttributesDelegate.enabled = false
                                   })
            }

            function saveLabel() {
                // Save label into additional attribute Key
                model.editKeyMode = false
                additionalAttributesEditText.enabled = true
                additionalAttributesEditText.focus = true
                model.key = additionalAttributesEditLabel.text
                additionalAttributesEditText.label = model.key
                additionalAttributesEditText.placeholderText = qsTr("Set") + " " + model.key
                updateCoverState(kdbEntry.edited)
                additionalAttributeRightButton.text = qsTr("Delete")
                additionalAttributeLeftButton.text = qsTr("Edit Label")
            }

            ListView.onAdd: AddAnimation {
                target: additionalAttributesDelegate
            }
            ListView.onRemove: RemoveAnimation {
                target: additionalAttributesDelegate
            }

            // This is the additional attribute edit button row
            Row {
                id: additionalAttributesButtons
                enabled: height !== 0
                opacity: enabled ? 1.0 : 0.0
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: additionalAttributesEditText.focus || additionalAttributesEditLabel.focus
                        ? additionalAttributeLeftButton.height + Theme.paddingMedium : 0

                Behavior on opacity { FadeAnimation { duration: 200; easing.type: Easing.OutQuad } }

                Button {
                    id: additionalAttributeLeftButton
                    enabled: additionalAttributesEditText.label.length !== 0  // Disable cancel button when label is initally empty on creation
                    width: (parent.width / 2) * 0.95
                    text: model.editKeyMode ? qsTr("Cancel") : qsTr("Edit Label")
                    onClicked: {
                        if (model.editKeyMode) {
                            // change to edit additional attribute text
                            model.editKeyMode = false
                            // Reset key and label to original value
                            model.key = additionalAttributesEditText.label
                            additionalAttributesEditLabel.text = additionalAttributesEditText.label
                            // Switch edit fields
                            additionalAttributesEditText.enabled = true
                            additionalAttributesEditText.focus = true
                            // Switch button texts
                            text = qsTr("Edit Label")
                            additionalAttributeRightButton.text = qsTr("Delete")
                        } else {
                            // change to edit label
                            model.editKeyMode = true
                            additionalAttributesEditText.enabled = false
                            additionalAttributesEditLabel.focus = true
                            text = qsTr("Cancel")
                            additionalAttributeRightButton.text = qsTr("Accept")
                        }
                    }
                }

                Button {
                    id: additionalAttributeRightButton
                    enabled: !additionalAttributesEditLabel.errorHighlight
                    width: (parent.width / 2) * 0.95
                    text: model.editKeyMode ? qsTr("Accept") : qsTr("Delete")
                    onClicked: {
                        if (model.editKeyMode) {
                            // Save label
                            additionalAttributesDelegate.saveLabel()
                        } else {
                            // Start remorse timer to delete the additional attribute
                            additionalAttributesDelegate.listItemRemove()
                        }
                    }
                }
            }

            // The following two Text edit fields are for attitional attributes
            TextArea {
                id: additionalAttributesEditText
                enabled: !model.editKeyMode
                width: parent.width
                height: enabled ? implicitHeight : 0
                anchors.bottom: additionalAttributesBottomPadding.top
                opacity: enabled ? 1.0 : 0.0
                label: model.key
                text: model.value
                placeholderText: model.key.length === 0
                                 ? "ERROR"
                                 : qsTr("Set") + " " + model.key
                onTextChanged: {
                    // Save additional attribute value
                    model.value = text
                    updateCoverState(kdbEntry.edited)
                }
                focusOutBehavior: -1

                Behavior on opacity { FadeAnimation { duration: 200; easing.type: Easing.OutQuad } }
            }

            TextField {
                id: additionalAttributesEditLabel
                width: parent.width
                height: enabled ? implicitHeight : 0
                anchors.bottom: additionalAttributesBottomPadding.top
                enabled: !additionalAttributesEditText.enabled
                opacity: enabled ? 1.0 : 0.0
                label: qsTr("Edit Label")
                text: model.key
                placeholderText: qsTr("Edit Label")
                errorHighlight: model.errorHighlight
                onTextChanged: {
                    model.key = text
                    errorHighlight = model.errorHighlight
                    updateCoverState(kdbEntry.edited)
                }
                EnterKey.enabled: !errorHighlight
                EnterKey.onClicked: {
                    additionalAttributesDelegate.saveLabel()
                }
                focusOutBehavior: -1

                Behavior on opacity { FadeAnimation { duration: 200; easing.type: Easing.OutQuad } }
            }

            // This is a spacer to keep some distance from the next list item
            Item {
                id: additionalAttributesBottomPadding
                height: Theme.paddingMedium
                width: parent.width
                anchors.bottom: additionalAttributesDelegate.bottom
            }
        }

        VerticalScrollDecorator {}
    }

    EditItemIconDialog {
        id: editItemIconDialog
        itemType: DatabaseItemType.ENTRY

        onAccepted: {
            entryIconRef.source = "image://KeepassIcon/" + newIconUuid
            kdbEntry.iconUuid = newIconUuid
            updateCoverState(kdbEntry.edited)
        }
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
