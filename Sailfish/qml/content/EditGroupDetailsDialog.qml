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
    id: editGroupDetailsDialog

    property bool createNewGroup: false
    // ID of the keepass entry which should be edited
    property int groupId: 0
    // creation of new group needs parent group ID
    property int parentGroupId: 0

    // The following properties are used to check if text of any entry detail was changed. If so,
    // set cover page accordingly to signal the user unsaved changes
    property string origGroupTitle: ""

    function setTextFields(name) {
        groupTitleTextField.text = origGroupTitle = name
    }

    // forbit page navigation if name of group is empty
    canNavigateForward: groupTitleTextField.text !== ""

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
                text: editGroupDetailsDialog.createNewGroup ? qsTr("Type in a name for the new group:") :
                                                              qsTr("Change name of group:")
            }

            TextField {
                id: groupTitleTextField
                width: parent.width
                label: "Name of group"
                text: ""
                placeholderText: "Set name of group"
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
                    applicationWindow.cover.coverTitle = text
                    // update cover state
                    if (editGroupDetailsDialog.origGroupTitle !== text) {
                        applicationWindow.cover.state = "UNSAVED_CHANGES"
                    } else {
                        applicationWindow.cover.state = "GROUPS_VIEW"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // set reference in kdbListItemInternal object
        kdbListItemInternal.editGroupDetailsDialogRef = editGroupDetailsDialog

        kdbGroup.groupId = editGroupDetailsDialog.groupId
        if (!createNewGroup) {
            kdbGroup.loadGroupData()
        }
        groupTitleTextField.focus = true
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
                                    groupTitleTextField.text)
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
                                        groupTitleTextField.text)
            kdbListItemInternal.checkForUnsavedKdbGroupChanges()
        }
    }
}
