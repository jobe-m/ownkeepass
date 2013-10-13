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

// TESTING
//    function editCanceledWithoutSaving() {
//            remorse.execute("", function() { listModel.clear() } )
//        }
//
//    RemorsePopup {
//        id: remorse
//    }
// end

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
                onClicked: pageStack.push(Qt.resolvedUrl("EditEntryDetailsDialog.qml").toString(),
                                          { "createNewEntry": true, "parentGroupId": groupId })
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

//                property alias entryTitle: entryTitle.text
                property string originalEntryTitle: ""
                property string originalEntryUrl: ""
                property string originalEntryUsername: ""
                property string originalEntryPassword: ""
                property string originalEntryComment: ""

                function saveKdbEntryDetails(createNewEntry, entryId, parentGroupId) {
                    console.log("Save entry (internal): " + entryTitle.text)
                    kdbEntry.entryId = entryId
                    if (createNewEntry) {
                        // create new group in database, save and update list model data
                        kdbEntry.createNewEntry(entryTitle.text,
                                                entryUrl.text,
                                                entryUsername.text,
                                                entryPassword.text,
                                                entryComment.text,
                                                parentGroupId)
                    } else {
                        // save changes of existing group to database and update list model data
                        kdbEntry.saveEntryData(entryTitle.text,
                                               entryUrl.text,
                                               entryUsername.text,
                                               entryPassword.text,
                                               entryComment.text)
                    }
                }

                function openQueryDialogForUnsavedChangesComponent() {
                    pageStack.replace(queryDialogForUnsavedChangesComponent)
                }
            }


            KdbGroup {
                id: kdbGroup
                onGroupDeleted: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            KdbEntry {
                id: kdbEntry
                onEntryDataLoaded: {
//                    console.log("title: " + title)
//                    console.log("url: " + url)
//                    console.log("username: " + username)
//                    console.log("password: " + password)
//                    console.log("comment: " + comment)
//                    console.log("binaryDesc: " + binaryDesc)
//                    console.log("creation: " + creation)
//                    console.log("lastMod: " + lastMod)
//                    console.log("lastAccess: " + lastAccess)
//                    console.log("expire: " + expire)
//                    console.log("binarySize: " + binarySize)
//                    console.log("friendlySize: " + friendlySize)
                    entryTitle.text = title
                    internal.originalEntryTitle = title
                    entryUrl.text = url
                    internal.originalEntryUrl = url
                    entryUsername.text = username
                    internal.originalEntryUsername = username
                    entryPassword.text = password
                    internal.originalEntryPassword = password
                    entryVerifyPassword.text = password
                    entryComment.text = comment
                    internal.originalEntryComment = comment
                }
                onEntryDataSaved: { // returns result
// TODO check save result
                }
                onNewEntryCreated: { // returns result, newEntryId
// TODO check save result
                }
                onEntryDeleted: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            Component {
                id: kdbListItemComponent
                ListItem {
                    id: kdbListItem

                    property string text: model.name // ""
                    property string subText: model.subtitle // ""
                    property bool selected: false
                    property bool groupItem: model.itemType === KdbListModel.GROUP // false

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
                                        //                                pageStack.push(Qt.resolvedUrl("EditEntryDetailsDialog.qml").toString(),
                                        //                                               { "entryId": model.id })
                                        console.log("Open EditEntryDetailsDialog: " + model.id)
                                        pageStack.push(editEntryDetailsDialogComponent,
                                                       { "entryId": model.id })
                                        break
                                    }
                                }


                                //                        KdbEntry {
                                //                            id: kdbEntry
                                //                        }

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
//                    property bool parentNeedUpdate: false

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
                                title: createNewEntry ? "Create Password Entry" : "Edit Password Entry"
                            }

                            SilicaLabel {
                                text: createNewEntry ? "Create new Password Entry:" :
                                                       "Edit Password Entry:"
                            }

                            TextField {
                                id: entryTitle
                                width: parent.width
                                label: "Title"
                                placeholderText: "Set Title"
                                EnterKey.onClicked: parent.focus = true
                            }

                            TextField {
                                id: entryUrl
                                width: parent.width
                                label: "Url"
                                placeholderText: "Set Url"
                                EnterKey.onClicked: parent.focus = true
                            }

                            TextField {
                                id: entryUsername
                                width: parent.width
                                label: "Username"
                                placeholderText: "Set Username"
                                EnterKey.onClicked: parent.focus = true
                            }

                            TextField {
                                id: entryPassword
                                width: parent.width
                                label: "Password"
                                placeholderText: "Set Password"
                                EnterKey.onClicked: parent.focus = true
                            }

                            TextField {
                                id: entryVerifyPassword
                                width: parent.width
                                label: "Verify Password"
                                placeholderText: "Verify Password"
                                errorHighlight: entryPassword.text !== text
                                EnterKey.highlighted: !errorHighlight
                                EnterKey.onClicked: parent.focus = true
                            }

                            TextField {
                                id: entryComment
                                width: parent.width
                                label: "Comment"
                                placeholderText: "Set Comment"
                                EnterKey.onClicked: parent.focus = true
                            }
                        }
                    }

                    Component.onCompleted: {
                        kdbEntry.entryId = editEntryDetailsDialog.entryId
                        if (!createNewEntry) {
                            kdbEntry.loadEntryData()
                        }
                        entryTitle.focus = true
                    }

                    onAccepted: internal.saveKdbEntryDetails(editEntryDetailsDialog.createNewEntry,
                                                               editEntryDetailsDialog.entryId,
                                                               editEntryDetailsDialog.parentGroupId)
                    onRejected: internal.openQueryDialogForUnsavedChangesComponent()
                }

            } // editEntryDetailsDialog

            Component {
                id: queryDialogForUnsavedChangesComponent
                QueryDialog {
//                    property alias entryId: kdbEntryForSaving.entryId
//                    property bool createNewEntry: false
//                    property int parentGroupId: 0
//                    property string entryTitle: ""
//                    property string entryUrl: ""
//                    property string entryUsername: ""
//                    property string entryPassword: ""
//                    property string entryComment: ""

                    canAccept: true
                    headerAcceptText: "Yes"
                    headerTitleText: "Yes"
                    titleText: "Save Changes"
                    message: "Do you want to save your changes in the Password Entry?"
                    onAccepted: console.log("query dialog accepted :-)")
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
//    onPageContainerChanged: {
        if (loadMasterGroups) {
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function __showLoadErrorPage() {
        pageStack.push(infoDialog, {
                           "headerText": "Info",
                           "titleText": "Load Error",
                           "message": "Could not load all items from database. That's strange!"
                       })
    }

    function __showSaveErrorPage() {
        pageStack.push(infoDialog, {
                           "headerText": "Info",
                           "titleText": "Save Error",
                           "message": "Could not save your changes to database. That's strange!"
                       })
    }
}
