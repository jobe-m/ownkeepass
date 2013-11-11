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
import "../scripts/Global.js" as Global
import KeepassPlugin 1.0

Page {
    id: groupsAndEntriesPage

    property bool initOnPageConstruction: true
    // ID of the keepass group which should be shown
    property int groupId: 0
    property bool loadMasterGroups: false
    property string pageTitle: qsTr("Groups and entries")

    function init() {
        if (loadMasterGroups) {
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function closeOnError() {
        __closeOnError = true
        if (status === PageStatus.Active) pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
    }

    // private properties and funtions
    property bool __closeOnError: false
    function __showLoadErrorPage() {
        console.log("ERROR: Could not load")
        Global.env.infoPopup.show("Load Error", "Could not load all items from Keepass database file. That's strange.", 10000)
    }

    function __showSaveErrorPage() {
        console.log("ERROR: Could not save")
        Global.env.infoPopup.show("Save Error", "Could not save your changes to Keepass database file. Either the location of the file is write protected or it was removed.", 15000)
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: kdbListModel

        header: PageHeaderExtended {
            title: pageTitle
            subTitle: "ownKeepass"
        }

        ViewPlaceholder {
            enabled: listView.count === 0
            text: "Group is empty"
            hintText: loadMasterGroups ? "Pull down to add password groups" : "Pull down to add password groups and entries"
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Database Settings")
                onClicked: pageStack.push(editDatabaseSettingsDialogComponent)
            }

            MenuItem {
                text: "New Password Group"
                onClicked: pageStack.push(editGroupDetailsDialogComponent,
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
// TODO rename object
//                id: kdbListItemInternal
                id: internal

                /*
                  These are handlers to edit entry and group dialogs and show entry page which needs to
                  get the entry resp. group details passed to in order to shown them
                  */
                property Dialog editEntryDetailsDialogRef: null
                property Dialog editGroupDetailsDialogRef: null
                property Page showEntryDetailsPageRef: null

                /*
                  Here are all Kdb entry details which are used to create a new entry, save changes to an
                  already existing entry and to check if the user has done changes to an entry in the UI
                  after he canceled the edit dialog. In that case a query dialog is shown to let the user
                  save the entry details if he has canceled the edit dialog unintentionally or because he
                  did not understand the whole UI paradigma at all...
                  */
                property string originalEntryTitle: ""
                property string originalEntryUrl: ""
                property string originalEntryUsername: ""
                property string originalEntryPassword: ""
                property string originalEntryComment: ""
// TODO                property int originalEntryImageId: 0
                property string entryTitle: ""
                property string entryUrl: ""
                property string entryUsername: ""
                property string entryPassword: ""
                property string entryComment: ""
// TODO                property int entryImageId: 0

                /*
                  Here are the details for Kdb groups. The same applies like for Kdb entries.
                  */
                property string originalGroupName: ""
// TODO                property int originalGroupImageId: 0
                property string groupName: ""
// TODO                property int groupImageId: 0

                /*
                  Data used to save database settings values in KdbDatabase object.
                  */
                property string databaseMasterPassword: ""
                property int databaseCryptAlgorithm: 0
                property int databaseKeyTransfRounds: 0

                /*
                  Commonly used for manipulation and creation of entries and groups.
                  */
                property bool createNewItem: false
                property int itemId: 0
                property int parentGroupId: 0

                // some constants
                readonly property int c_queryForEntry: 1
                readonly property int c_queryForGroup: 2
                readonly property int c_queryForDatabaseSettings: 3

                function saveKdbGroupDetails() {
                    console.log("Group name: " + groupName)
                    // Set group ID and create or save Kdb Group
                    kdbGroup.groupId = itemId
                    if (createNewItem) {
                        // create new group in database, save and update list model data in backend
                        kdbGroup.createNewGroup(groupName,
                                                parentGroupId)
                    } else {
                        // save changes of existing group to database and update list model data in backend
                        kdbGroup.saveGroupData(groupName)
                    }
                }

                function saveKdbEntryDetails() {
                    // Set entry ID and create or save Kdb Entry
                    kdbEntry.entryId = itemId
                    if (createNewItem) {
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

                function checkForUnsavedKdbEntryChanges() {
                    // check if the user has changed any entry details
                    if (originalEntryTitle !== entryTitle || originalEntryUrl !== entryUrl ||
                            originalEntryUsername !== entryUsername || originalEntryPassword !== entryPassword ||
                            originalEntryComment !== entryComment) {
                        // open query dialog for unsaved changes
                        pageStack.replace(queryDialogForUnsavedChangesComponent,
                                          { "type": c_queryForEntry })
                    }
                }

                function checkForUnsavedKdbGroupChanges() {
                    if (originalGroupName !== groupName) {
                        pageStack.replace(queryDialogForUnsavedChangesComponent,
                                          { "type": c_queryForGroup })
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

                    // Populate entry detail text fields in editEntryDetailsDialog or showEntryDetailsPage
                    // depending on which is currently active
                    if(editEntryDetailsDialogRef)
                        editEntryDetailsDialogRef.setTextFields(title, url, username, password, comment)
                    if(showEntryDetailsPageRef)
                        showEntryDetailsPageRef.setTextFields(title, url, username, password, comment)
                }

                function loadKdbGroupDetails(name) {
                    groupName = originalGroupName = name
                    // Populate group detail text fields in editGroupDetailsDialog
                    if(editGroupDetailsDialogRef)
                        editGroupDetailsDialogRef.setTextFields(name)
                }

                function setKdbEntryDetails(createNewEntry, entryId, parentGrId, title, url, username, password, comment) {
                    createNewItem = createNewEntry
                    itemId        = entryId
                    parentGroupId = parentGrId
                    entryTitle    = title
                    entryUrl      = url
                    entryUsername = username
                    entryPassword = password
                    entryComment  = comment
                }

                function setKdbGroupDetails(createNewGroup, groupId, parentGrId, name) {
                    createNewItem = createNewGroup
                    itemId        = groupId
                    parentGroupId = parentGrId
                    groupName     = name
                }

                function setDatabaseSettings(masterPassword, cryptAlgorithm, keyTransfRounds) {
                    databaseMasterPassword  = masterPassword
                    databaseCryptAlgorithm  = cryptAlgorithm
                    databaseKeyTransfRounds = keyTransfRounds
                }

                function checkForUnsavedDatabaseSettingsChanges() {
                    // check if user gave a new master password or if encryption type or key transformation rounds have changed
                    if (databaseMasterPassword !== "" ||
                            databaseCryptAlgorithm !== Global.env.kdbDatabase.cryptAlgorithm ||
                            databaseKeyTransfRounds !== Global.env.kdbDatabase.keyTransfRounds) {
                        pageStack.replace(queryDialogForUnsavedChangesComponent,
                                          { "type": c_queryForDatabaseSettings })
                    }
                }

                function saveDatabaseSettings() {
                    if (databaseMasterPassword !== "")
                        Global.env.kdbDatabase.changePassword(databaseMasterPassword)
                    databaseMasterPassword = ""
                    if (databaseCryptAlgorithm !== Global.env.kdbDatabase.cryptAlgorithm)
                        Global.env.kdbDatabase.cryptAlgorithm = databaseCryptAlgorithm
                    if (databaseKeyTransfRounds !== Global.env.kdbDatabase.keyTransfRounds)
                        Global.env.kdbDatabase.keyTransfRounds = databaseKeyTransfRounds
                }
            }

            KdbGroup {
                id: kdbGroup
                onGroupDataLoaded: internal.loadKdbGroupDetails(title)
                onGroupDataSaved: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
                onNewGroupCreated: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            KdbEntry {
                id: kdbEntry
                onEntryDataLoaded: internal.loadKdbEntryDetails(title, url, username, password, comment)
                onEntryDataSaved: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
                onNewEntryCreated: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            /*
              We need separate objects for deletion because of the 5 seconds guard period where
              the user can undo the delete operation, i.e. the deletion is delayed and the user
              might open another item which would then be deleted if we don't use separate
              objects here
              */
            KdbGroup {
                id: kdbGroupForDeletion
                onGroupDeleted: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
            }

            KdbEntry {
                id: kdbEntryForDeletion
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
                    contentHeight: Theme.itemSizeMedium
                    width: parent ? parent.width : screen.width

                    function listItemRemoveGroup() {
                        kdbGroupForDeletion.groupId = model.id
                        remorseAction("Deleting group", function() { kdbGroupForDeletion.deleteGroup() })
                    }
                    function listItemRemoveEntry() {
                        kdbEntryForDeletion.entryId = model.id
                        remorseAction("Deleting entry", function() { kdbEntryForDeletion.deleteEntry() })
                    }

                    ListView.onRemove: animateRemoval()
                    onClicked: {
                        switch (model.itemType) {
                        case KdbListModel.GROUP:
                            pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                                           { "pageTitle": model.name, "groupId": model.id })
                            break
                        case KdbListModel.ENTRY:
                            pageStack.push(showEntryDetailsPageComponent,
                                           { "pageTitle": model.name, "entryId": model.id })
                            break
                        }
                    }

                    Image {
                        x: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        width: 81 //Theme.iconSizeMedium
                        height: 81 //Theme.iconSizeMedium
                        source: "../icons/_0.png"
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Rectangle {
                        id: itemIcon
                        x: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        width: 81
                        height: 81
                        radius: 20
                        color: "white"
                        opacity: 0.1
                    }

                    Item {
                        anchors.left: itemIcon.right
                        anchors.leftMargin: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.paddingLarge * 2 - Theme.paddingSmall - itemIcon.width
                        height: model.itemType === KdbListModel.ENTRY && !Global.env.keepassSettings.showUserNamePasswordInListView ?
                                    itemTitle.height :
                                    itemTitle.height + (Theme.paddingSmall / 2) + itemDescription.height

                        Label {
                            id: itemTitle
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: parent.width
                            text: kdbListItem.text
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: Theme.fontSizeMedium
                            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            truncationMode: TruncationMode.Fade
                        }

                        Label {
                            id: itemDescription
                            enabled: model.itemType === KdbListModel.GROUP || Global.env.keepassSettings.showUserNamePasswordInListView
                            visible: enabled
                            anchors.left: parent.left
                            anchors.top: itemTitle.bottom
                            anchors.topMargin: Theme.paddingSmall / 2
                            width: parent.width
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
                                        pageStack.push(editGroupDetailsDialogComponent,
                                                       { "groupId": model.id })
                                        break
                                    case KdbListModel.ENTRY:
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
                                        listItemRemoveGroup()
                                        break
                                    case KdbListModel.ENTRY:
                                        listItemRemoveEntry()
                                        break
                                    }
                                }
                            }
                        }
                    } // end contextMenuComponent
                } // end kdbListItem
            } // end kdbListItemComponent

            Component {
                id: showEntryDetailsPageComponent
                ShowEntryDetailsPage {
                    id: showEntryDetailsPage
                }
            }

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
                                placeholderText: "Set Title (mandatory)"
                                errorHighlight: text === ""
                                EnterKey.highlighted: !errorHighlight
                                EnterKey.onClicked: entryUrlTextField.focus = true
                            }

                            TextField {
                                id: entryUrlTextField
                                width: parent.width
                                inputMethodHints: Qt.ImhUrlCharactersOnly
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

                            Item {
                                width: parent.width
                                height: entryPasswordTextField.height

                                TextField {
                                    id: entryPasswordTextField
                                    anchors.left: parent.left
                                    anchors.right: showPasswordButton.left
                                    echoMode: TextInput.Password
                                    label: "Password"
                                    placeholderText: "Set Password"
                                    EnterKey.onClicked: entryVerifyPasswordTextField.focus = true
                                }

                                IconButton {
                                    id: showPasswordButton
                                    width: icon.width
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.paddingLarge
                                    icon.source: "image://theme/icon-m-ambience"
                                    highlighted: entryPasswordTextField.echoMode === TextInput.Normal
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
                        // no need for saving if input fields are invalid
                        if (canNavigateForward) {
                            // first save locally Kdb entry details then trigger check for unsaved changes
                            internal.setKdbEntryDetails(createNewEntry,
                                                        entryId,
                                                        parentGroupId,
                                                        entryTitleTextField.text,
                                                        entryUrlTextField.text,
                                                        entryUsernameTextField.text,
                                                        entryPasswordTextField.text,
                                                        entryCommentTextField.text)
                            internal.checkForUnsavedKdbEntryChanges()
                        }
                    }
                }
            } // editEntryDetailsDialog

            Component {
                id: editGroupDetailsDialogComponent
                Dialog {
                    id: editGroupDetailsDialog

                    property bool createNewGroup: false
                    // ID of the keepass entry which should be edited
                    property int groupId: 0
                    // creation of new group needs parent group ID
                    property int parentGroupId: 0

                    function setTextFields(name) {
                        groupTitleTextField.text = name
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
                                placeholderText: "Set name of group"
                                errorHighlight: text === ""
                                EnterKey.highlighted: !errorHighlight
                                EnterKey.onClicked: parent.focus = true
                            }
                        }
                    }

                    Component.onCompleted: {
                        // set reference in internal object
                        internal.editGroupDetailsDialogRef = editGroupDetailsDialog

                        kdbGroup.groupId = editGroupDetailsDialog.groupId
                        if (!createNewGroup) {
                            kdbGroup.loadGroupData()
                        }
                        groupTitleTextField.focus = true
                    }
                    Component.onDestruction: {
                        // unset again
                        internal.editGroupDetailsDialogRef = null
                    }
                    // user wants to save new entry data
                    onAccepted: {
                        // first save locally Kdb entry details then trigger save to backend
                        internal.setKdbGroupDetails(createNewGroup,
                                                    groupId,
                                                    parentGroupId,
                                                    groupTitleTextField.text)
                        internal.saveKdbGroupDetails()
                    }
                    // user has rejected editing entry data, check if there are unsaved details
                    onRejected: {
                        // no need for saving if input fields are invalid
                        if (canNavigateForward) {
                            // first save locally Kdb entry details then trigger check for unsaved changes
                            internal.setKdbGroupDetails(createNewGroup,
                                                        groupId,
                                                        parentGroupId,
                                                        groupTitleTextField.text)
                            internal.checkForUnsavedKdbGroupChanges()
                        }
                    }
                }
            } // end editGroupDetailsDialogComponent

            Component {
                id: editDatabaseSettingsDialogComponent
                Dialog {
                    id: editDatabaseSettingsDialog

                    // forbit page navigation if master password is not confirmed
                    canNavigateForward: !confirmDatabaseMasterPassword.errorHighlight

                    SilicaFlickable {
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: col.height

                        VerticalScrollDecorator {}

                        Column {
                            id: col
                            width: parent.width
                            spacing: Theme.paddingLarge

                            DialogHeader {
                                acceptText: "Save"
                                title: "Save"
                            }

                            SectionHeader {
                                text: "Database Settings"
                            }

                            TextField {
                                id: databaseMasterPassword
                                width: parent.width
                                inputMethodHints: Qt.ImhNoPredictiveText
                                echoMode: TextInput.Password
                                label: "Master Password"
                                placeholderText: "Change Master Password"
                                EnterKey.enabled: text !== ""
                                EnterKey.highlighted: text !== ""
                                EnterKey.onClicked: {
                                    confirmDatabaseMasterPassword.focus = true
                                }
                            }

                            TextField {
                                id: confirmDatabaseMasterPassword
                                enabled: databaseMasterPassword.text !== ""
                                opacity: databaseMasterPassword.text !== "" ? 1.0 : 0.0
                                height: databaseMasterPassword.text !== "" ? implicitHeight : 0
                                width: parent.width
                                inputMethodHints: Qt.ImhNoPredictiveText
                                echoMode: TextInput.Password
                                errorHighlight: databaseMasterPassword.text !== text
                                label: !errorHighlight ? "Master Password confirmed" : "Confirm Master Password"
                                placeholderText: "Confirm Master Password"
                                EnterKey.enabled: databaseMasterPassword.text !== "" && !errorHighlight
                                EnterKey.highlighted: databaseMasterPassword.text !== "" && !errorHighlight
                                EnterKey.onClicked: {
                                    parent.focus = true
                                }
                                Behavior on opacity { NumberAnimation { duration: 500 } }
                                Behavior on height { NumberAnimation { duration: 500 } }
                            }

                            ComboBox {
                                id: databaseCryptAlgorithm
                                width: parent.width
                                label: "Encryption in use:"
                                currentIndex: 0
                                menu: ContextMenu {
                                    MenuItem { text: "AES/Rijndael" }
                                    MenuItem { text: "Twofish" }
                                }
                            }

                            TextField {
                                id: databaseKeyTransfRounds
                                width: parent.width
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                validator: RegExpValidator { regExp: /^[1-9][0-9]*$/ }
                                label: "Key Transformation Rounds"
                                placeholderText: label
                                text: Global.env.kdbDatabase.keyTransfRounds
                                EnterKey.onClicked: parent.focus = true
                            }
                        }
                    } // SilicaFlickable

                    // user wants to save new Settings
                    onAccepted: {
                        // first save locally database settings then trigger saving
                        internal.setDatabaseSettings(databaseMasterPassword.text,
                                                     databaseCryptAlgorithm.currentIndex,
                                                     Number(databaseKeyTransfRounds.text))
                        internal.saveDatabaseSettings()
                    }
                    // user has rejected changing database settings, check if there are unsaved details
                    onRejected: {
                        // no need for saving if input field for master password is invalid
                        if (canNavigateForward) {
                            // first save locally database settings then trigger check for unsaved changes
                            internal.setDatabaseSettings(databaseMasterPassword.text,
                                                         databaseCryptAlgorithm.currentIndex,
                                                         Number(databaseKeyTransfRounds.text))
                            internal.checkForUnsavedDatabaseSettingsChanges()
                        }
                    }
                } // Dialog
            }

            Component {
                id: queryDialogForUnsavedChangesComponent
                QueryDialog {
                    property int type: 0
                    headerAcceptText: "Yes"
                    headerTitleText: "Yes"
                    titleText: "Unsaved Changes"
                    message: type === internal.c_queryForEntry ?
                                 "Do you want to save changes to the Password Entry?" :
                                 type == internal.c_queryForGroup ?
                                     "Do you want to save changes to the Password Group?" :
                                     type === internal.c_queryForDatabaseSettings ?
                                         "Do you want to save changes to Database Settings?" : ""

                    onAccepted:  type === internal.c_queryForEntry ?
                                     internal.saveKdbEntryDetails() :
                                     type == internal.c_queryForGroup ?
                                          internal.saveKdbGroupDetails() :
                                         type === internal.c_queryForDatabaseSettings ?
                                             internal.saveDatabaseSettings() : console.log("ERROR in query for unsaved changes")
                }
            } // end queryForUnsavedChangesComponent
        } // end kdbLIstItemDelegate
    } // end listView

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
        onMasterGroupsLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage
    }

    onStatusChanged: {
        if (__closeOnError && status === PageStatus.Active) pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
    }

    Component.onCompleted: if (initOnPageConstruction) init()
}
