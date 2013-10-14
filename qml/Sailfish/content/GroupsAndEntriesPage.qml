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
import "../common"
import KeepassPlugin 1.0

Page {
    id: groupsAndEntriesPage

    // ID of the keepass group which should be shown
    property int groupId: 0
    property bool loadMasterGroups: false
    property string pageTitle: qsTr("Groups and entries")

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: kdbListModel

        header: KeepassPageHeader {
            title: pageTitle
            subTitle: "ownKeepass"
        }

        ViewPlaceholder {
            enabled: listView.count === 0
            text: "No content"
            hintText: loadMasterGroups ? "Pull down to add password groups" : "Pull down to add password groups and entries"
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Database Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("DatabaseSettingsPage.qml").toString())
            }

            MenuItem {
                text: "New Password Group"
                onClicked: pageStack.push(Qt.resolvedUrl("EditGroupDetailsDialog.qml").toString(),
                                          { "createNewGroup": true, "parentGroupId": groupId })
            }
            MenuItem {
                enabled: !loadMasterGroups
                visible: !loadMasterGroups
                text: "New Password Entry"
                onClicked: {
                    console.log("Open EditEntryDetailsDialog to create new entry")
                    pageStack.push(editEntryDetailsDialogComponent,
                                   { "createNewEntry": true, "parentGroupId": groupId })
                }
            }
        }

        KpPushUpMenu {}

        VerticalScrollDecorator {}

        delegate: kdbListItemDelegate.kdbListItem

        Item {
            id: kdbListItemDelegate
            property Component kdbListItem: kdbListItemComponent

            QtObject {
                id: internal

                property Dialog editEntryDetailsDialogRef: null

                // Here are all Kdb entry details which are used to create a new entry, save changes to an
                // already existing entry and to check if the user has done changes to an entry in the UI and
                // canceled the edit dialog. In that case a query dialog is shown to let the user save the
                // entry details if he has canceled the edit dialog unintentionally or because he did not
                // understand the whole UI paradigma at all...
                property bool createNewEntry: false
                property int entryId: 0
                property int parentGroupId: 0
                property string originalEntryTitle: ""
                property string originalEntryUrl: ""
                property string originalEntryUsername: ""
                property string originalEntryPassword: ""
                property string originalEntryComment: ""
                property string entryTitle: ""
                property string entryUrl: ""
                property string entryUsername: ""
                property string entryPassword: ""
                property string entryComment: ""

                function saveKdbEntryDetails() {
                    console.log("Save entry (internal): " + entryTitle)
                    // Set entry ID and create or save Kdb Entry
                    kdbEntry.entryId = entryId
                    if (createNewEntry) {
                        // create new group in database, save and update list model data in backend
                        kdbEntry.createNewEntry(entryTitle,
                                                entryUrl,
                                                entryUsername,
                                                entryPassword,
                                                entryComment,
                                                parentGroupId)
                    } else {
                        // save changes of existing group to database and update list model data in backend
                        kdbEntry.saveEntryData(entryTitle,
                                               entryUrl,
                                               entryUsername,
                                               entryPassword,
                                               entryComment)
                    }
                }

                function checkForUnsavedChanges() {
                    console.log("Check for unsaved changes")
                    // check if the user has changed any entry details
                    if (originalEntryTitle !== entryTitle || originalEntryUrl !== entryUrl ||
                            originalEntryUsername !== entryUsername || originalEntryPassword !== entryPassword ||
                            originalEntryComment !== entryComment) {
                        // open query dialog for unsaved changes
                        pageStack.replace(queryDialogForUnsavedChangesComponent)
                    }
                }

                function loadKdbEntryDetails(title, url, username, password, comment) {
//                    console.log("binaryDesc: " + binaryDesc)
//                    console.log("creation: " + creation)
//                    console.log("lastMod: " + lastMod)
//                    console.log("lastAccess: " + lastAccess)
//                    console.log("expire: " + expire)
//                    console.log("binarySize: " + binarySize)
//                    console.log("friendlySize: " + friendlySize)
                    entryTitle    = originalEntryTitle    = title
                    entryUrl      = originalEntryUrl      = url
                    entryUsername = originalEntryUsername = username
                    entryPassword = originalEntryPassword = password
                    entryComment  = originalEntryComment  = comment

                    // populate entry detail text fields in EditEntryDetailsDialog
                    if(editEntryDetailsDialogRef) editEntryDetailsDialogRef.setTextFields(title, url, username, password, comment)
                }

                function setKdbEntryDetails(createNew, eId, parentGId, title, url, username, password, comment) {
                    createNewEntry = createNew
                    entryId        = eId
                    parentGroupId  = parentGId
                    entryTitle     = title
                    entryUrl       = url
                    entryUsername  = username
                    entryPassword  = password
                    entryComment   = comment
                }
            }

            KdbGroup {
                id: kdbGroup
                onGroupDeleted: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            KdbEntry {
                id: kdbEntry
                onEntryDataLoaded: internal.loadKdbEntryDetails(title, url, username, password, comment)
                onEntryDataSaved: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
                onNewEntryCreated: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
                onEntryDeleted: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            Component {
                id: kdbListItemComponent
                ListItem {
                    id: kdbListItem

                    property string text: model.name
                    property string subText: model.subtitle
                    property bool selected: false
                    property bool groupItem: model.itemType === KdbListModel.GROUP

                    menu: contextMenuComponent
                    contentHeight: col.height
                    width: parent ? parent.width : screen.width

                    function __removeGroup() {
                        kdbGroup.groupId = model.id
                        remorseAction("Deleting group", function() { kdbGroup.deleteGroup() })
                    }
                    function __removeEntry() {
                        kdbEntry.entryId = model.id
                        remorseAction("Deleting entry", function() { kdbEntry.deleteEntry() })
                    }

                    ListView.onRemove: animateRemoval()
                    onClicked: {
                        switch (model.itemType) {
                        case KdbListModel.GROUP:
                            pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                                           { "pageTitle": model.name, "groupId": model.id })
                            break
                        case KdbListModel.ENTRY:
                            pageStack.push(Qt.resolvedUrl("EntryDetailsPage.qml").toString(),
                                           { "pageTitle": model.name, "entryId": model.id })
                            break
                        }
                    }

                    Column {
                        id: col
                        width: parent.width
                        height: children.height
                        spacing: Theme.paddingSmall

                        Label {
                            x: Theme.paddingLarge
                            width: parent.width - Theme.paddingLarge * 2
                            text: kdbListItem.text
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: Theme.fontSizeMedium
                            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }

                        Label {
                            x: Theme.paddingLarge
                            width: parent.width - Theme.paddingLarge * 2
                            text: kdbListItem.subText
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        }
                    }

                    Component {
                        id: contextMenuComponent
                        ContextMenu {
                            id: contextMenu
                            property int itemTypeFromModel: 0
                            property int itemIdFromModel: 0
                            MenuItem {
                                text: qsTr("Edit")
                                onClicked: {
                                    switch (model.itemType) {
                                    case KdbListModel.GROUP:
                                        pageStack.push(Qt.resolvedUrl("EditGroupDetailsDialog.qml").toString(),
                                                       { "groupId": model.id })
                                        break
                                    case KdbListModel.ENTRY:
                                        console.log("Open EditEntryDetailsDialog: " + model.id)
                                        pageStack.push(editEntryDetailsDialogComponent,
                                                       { "entryId": model.id })
                                        break
                                    }
                                }
                            }
                            MenuItem {
                                text: qsTr("Delete")
                                onClicked: {
                                    switch (model.itemType) {
                                    case KdbListModel.GROUP:
                                        __removeGroup()
                                        break
                                    case KdbListModel.ENTRY:
                                        __removeEntry()
                                        break
                                    }
                                }
                            }
                        }
                    } // end contextMenuComponent
                } // end kdbListItem
            } // end kdbListItemComponent

            Component {
                id: editEntryDetailsDialogComponent
                Dialog {
                    id: editEntryDetailsDialog

                    property bool createNewEntry: false
                    // ID of the keepass entry to be edited
                    property int entryId: 0
                    // creation of new entry needs parent group ID
                    property int parentGroupId: 0

                    function setTextFields(title, url, username, password, comment) {
                        entryTitleTextField.text = title
                        entryUrlTextField.text = url
                        entryUsernameTextField.text = username
                        entryPasswordTextField.text = entryVerifyPasswordTextField.text = password
                        entryCommentTextField.text = comment
                    }

                    // control page navigation depending if the password is verified
                    canNavigateForward: entryPasswordTextField.text === entryVerifyPasswordTextField.text
                    backNavigation: canNavigateForward

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
                                acceptText: canNavigateForward ? "Save" : "Verify Password!"
                                title: canNavigateForward ? "Save" : "Verify Password!"
                            }

                            SilicaLabel {
                                text: editEntryDetailsDialog.createNewEntry ? "Create new Password Entry:" :
                                                       "Edit Password Entry:"
                            }

                            TextField {
                                id: entryTitleTextField
                                width: parent.width
                                label: "Title"
                                placeholderText: "Set Title"
                                EnterKey.onClicked: entryUrlTextField.focus = true
                            }

                            TextField {
                                id: entryUrlTextField
                                width: parent.width
                                label: "Url"
                                placeholderText: "Set Url"
                                EnterKey.onClicked: entryUsernameTextField.focus = true
                            }

                            TextField {
                                id: entryUsernameTextField
                                width: parent.width
                                label: "Username"
                                placeholderText: "Set Username"
                                EnterKey.onClicked: entryPasswordTextField.focus = true
                            }

                            TextField {
                                id: entryPasswordTextField
                                width: parent.width
                                echoMode: TextInput.Password
                                label: "Password"
                                placeholderText: "Set Password"
                                EnterKey.onClicked: entryVerifyPasswordTextField.focus = true
                            }

                            TextField {
                                id: entryVerifyPasswordTextField
                                width: parent.width
                                echoMode: TextInput.Password
                                label: "Verify Password"
                                placeholderText: "Verify Password"
                                errorHighlight: entryPasswordTextField.text !== text
                                EnterKey.highlighted: !errorHighlight
                                EnterKey.onClicked: entryCommentTextField.focus = true
                            }

                            TextArea {
                                id: entryCommentTextField
                                width: parent.width
                                label: "Comment"
                                placeholderText: "Set Comment"
                            }
                        }
                    }

                    Component.onCompleted: {
                        // set reference in internal object
                        internal.editEntryDetailsDialogRef = editEntryDetailsDialog

                        kdbEntry.entryId = editEntryDetailsDialog.entryId
                        if (!createNewEntry) {
                            kdbEntry.loadEntryData()
                        }
                        entryTitleTextField.focus = true
                    }
                    Component.onDestruction: {
                        // unset again
                        internal.editEntryDetailsDialogRef = null
                    }

                    // user wants to save new entry data
                    onAccepted: {
                        // first save locally Kdb entry details then trigger save to backend
                        internal.setKdbEntryDetails(createNewEntry,
                                                    entryId,
                                                    parentGroupId,
                                                    entryTitleTextField.text,
                                                    entryUrlTextField.text,
                                                    entryUsernameTextField.text,
                                                    entryPasswordTextField.text,
                                                    entryCommentTextField.text)
                        internal.saveKdbEntryDetails()
                    }
                    // user has rejected editing entry data, check if there are unsaved details
                    onRejected: {
                        // first save locally Kdb entry details then trigger check for unsaved changes
                        internal.setKdbEntryDetails(createNewEntry,
                                                    entryId,
                                                    parentGroupId,
                                                    entryTitleTextField.text,
                                                    entryUrlTextField.text,
                                                    entryUsernameTextField.text,
                                                    entryPasswordTextField.text,
                                                    entryCommentTextField.text)
                        internal.checkForUnsavedChanges()
                    }
                }
            } // editEntryDetailsDialog

            Component {
                id: queryDialogForUnsavedChangesComponent
                QueryDialog {
                    headerAcceptText: "Yes"
                    headerTitleText: "Yes"
                    titleText: "Save Changes"
                    message: "Do you want to save your changes in the Password Entry?"
                    onAccepted: internal.saveKdbEntryDetails()
                }
            } // end queryForUnsavedChangesComponent
        } // end kdbLIstItemDelegate
    } // end listView

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
        onMasterGroupsLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage
    }

    Component.onCompleted: {
        if (loadMasterGroups) {
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function __showLoadErrorPage() {
        console.log("ERROR: Could not load")
// TODO both error pages below are not shown because of transition in progress stuff...
        pageStack.replace(Qt.resolvedUrl("../common/QueryDialog.qml").toString(), {
                           "headerAcceptText": "Info",
                           "headerTitleText": "Info",
                           "titleText": "Load Error",
                           "message": "Could not load all items from database. That's strange!"
                       })
    }

    function __showSaveErrorPage() {
        console.log("ERROR: Could not save")
        pageStack.replace(Qt.resolvedUrl("../common/QueryDialog.qml").toString(), {
                           "headerAcceptText": "Info",
                           "headerTitleText": "Info",
                           "titleText": "Save Error",
                           "message": "Could not save your changes to database. Either the location where your Keepass database file is places is write protected or was removed."
                       })
    }
}
