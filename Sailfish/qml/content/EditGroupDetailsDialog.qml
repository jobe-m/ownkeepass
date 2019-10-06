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
    id: editGroupDetailsDialog

    property bool createNewGroup: false
    // ID of the keepass entry which should be edited
    property string groupId: ""
    // creation of new group needs parent group ID
    property string parentGroupId: ""
    // icon for group (either a default icon or a custom database icon)
    property string iconUuid: ""

    // internal
    // The following properties are used to check if text of any entry detail was changed. If so,
    // set cover page accordingly to signal the user unsaved changes
    property string origName: ""
    property string origNotes: ""
    property string origIconUuid: ""
    property bool nameChanged: false
    property bool notesChanged: false
    property bool iconUuidChanged: false

    // This function should be called when any text is changed to check if the
    // cover page state needs to be updated
    function updateCoverState() {
        if (nameChanged || notesChanged || iconUuidChanged) {
            applicationWindow.cover.state = "UNSAVED_CHANGES"
        } else {
            applicationWindow.cover.state = "ENTRY_VIEW"
        }
    }

    function setTextFields(name, notes, aIconUuid) {
        groupNameTextField.text = origName = name
        groupNotesTextField.text = origNotes = notes
        iconUuid = origIconUuid = aIconUuid
        groupNameTextField.focus = true
    }

    // set group icon for image element
    onIconUuidChanged: {
        iconUuidChanged = origIconUuid !== iconUuid ? true : false
        groupIcon.source = "image://KeepassIcon/" + iconUuid
    }

    // forbit page navigation if name of group is empty and icon not set
    canNavigateForward: groupNameTextField.text !== "" && iconUuid.length !== -1
    allowedOrientations: applicationWindow.orientationSetting

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
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
            }

            SectionHeader {
                text: qsTr("Change icon")
            }

            Item {
                width: parent.width
                height: groupIconBackground.height

                Image {
                    id: groupIconBackground
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.itemSizeMedium
                    height: Theme.itemSizeMedium
                    source: "image://IconBackground"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    MouseArea {
                        id: groupIconMouseArea
                        anchors.fill: parent
                        onClicked: {
                            // open new dialog with grid of all icons
                            pageStack.push( editItemIconDialog,
                                           { "newIconUuid": iconUuid })
                        }
                    }
                }

                Image {
                    id: groupIcon
                    anchors.centerIn: parent
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    opacity: groupIconMouseArea.pressed ? 0.5 : 1.0
                }

                Rectangle {
                    anchors.fill: groupIconBackground
                    color: groupIconMouseArea.pressed ?
                               Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                             : "transparent"
                }
            }

            SectionHeader {
                text: qsTr("Change group details")
            }

            TextField {
                id: groupNameTextField
                width: parent.width
                label: qsTr("Name of group")
                text: ""
                placeholderText: qsTr("Set name of group")
                errorHighlight: text === ""
                EnterKey.enabled: !errorHighlight
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    accept()
                    close()
                }
                onTextChanged: {
                    // set new title name in cover
                    applicationWindow.cover.title = text
                    nameChanged = origName !== text ? true : false
                    updateCoverState()
                }
                focusOutBehavior: -1
            }

            TextArea {
                id: groupNotesTextField
                width: parent.width
                label: qsTr("Notes for the group")
                text: ""
                placeholderText: qsTr("Set notes for the group")
                onTextChanged: {
                    notesChanged = origNotes !== text ? true : false
                    updateCoverState()
                }
                focusOutBehavior: -1
            }
        }
    }

    EditItemIconDialog {
        id: editItemIconDialog
        itemType: DatabaseItemType.GROUP

        onAccepted: {
            editGroupDetailsDialog.iconUuid = newIconUuid
        }
    }

    Component.onCompleted: {
        // set reference in kdbListItemInternal object
        kdbListItemInternal.editGroupDetailsDialogRef = editGroupDetailsDialog

        kdbGroup.groupId = editGroupDetailsDialog.groupId
        if (!createNewGroup) {
            kdbGroup.loadGroupData()
        }
        groupNameTextField.focus = true
    }
    Component.onDestruction: {
        // unset again
        kdbListItemInternal.editGroupDetailsDialogRef = null
    }
    // user wants to save new entry data
    onAccepted: {
        // first save locally Kdb entry details then trigger save to backend
        kdbListItemInternal.setKdbGroupDetails(createNewGroup,
                                               groupId,
                                               parentGroupId,
                                               groupNameTextField.text,
                                               groupNotesTextField.text,
                                               iconUuid)
        kdbListItemInternal.saveKdbGroupDetails()
    }
    // user has rejected editing entry data, check if there are unsaved details
    onRejected: {
        // no need for saving if input fields are invalid
        if (canNavigateForward) {
            // first save locally Kdb entry details then trigger check for unsaved changes
            kdbListItemInternal.setKdbGroupDetails(createNewGroup,
                                                   groupId,
                                                   parentGroupId,
                                                   groupNameTextField.text,
                                                   groupNotesTextField.text,
                                                   iconUuid)
            kdbListItemInternal.checkForUnsavedKdbGroupChanges()
        }
    }
}
