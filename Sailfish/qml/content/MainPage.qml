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
import harbour.ownkeepass.KeepassX1 1.0

Page {
    id: mainPage

    // Components accessible through root mainPage object from all subpages
    property Component kdbListItemComponent: kdbListItemComponent
    property Component showEntryDetailsPageComponent: showEntryDetailsPageComponent
    property Component editEntryDetailsDialogComponent: editEntryDetailsDialogComponent
    property Component editGroupDetailsDialogComponent: editGroupDetailsDialogComponent
    property Component editDatabaseSettingsDialogComponent: editDatabaseSettingsDialogComponent
    property Component editSettingsDialogComponent: editSettingsDialogComponent
    property Component queryDialogForUnsavedChangesComponent: queryDialogForUnsavedChangesComponent

    function inactivityTimerStart() {
        var inactivityTime = Global.getInactivityTime(ownKeepassSettings.locktime)
        // Check if the user has not set timer to unlimited
        // meaning the app should never lock
        if (inactivityTime <= Global.constants._60minutes) {
            inactivityTimer.interval = inactivityTime
            inactivityTimer.restart()
        }
    }

    function inactivityTimerStop() {
        inactivityTimer.stop()
    }

    function lockDatabase() {
        // By going back to main page database will be locked
        pageStack.pop(mainPage)
    }

    Timer {
        id: inactivityTimer
        running: false
        repeat: false
        interval: Global.constants._30seconds // default value
        triggeredOnStart: false
        onTriggered: {
            // Inactivity timer hit
            lockDatabase()
        }
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: recentDatabaseModel

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        ApplicationMenu {
            helpContent: "MainPage"
        }

        header: Column {
            width: parent.width
            spacing: 0 // Theme.paddingLarge

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

            Image {
                width: 492
                height: 492
                source: "../../wallicons/wall-ownKeys.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Create new database"
                onClicked: {
                    pageStack.push(queryPasswordDialogComponent,
                                   {
                                       "state": "CreateNewDatabase",
                                       "dbFileLocation": 0,
                                       // If ownKeepass was opened the very first time give the user a predefined database file path and name
                                       "dbFilePath": recentDatabaseModel.isEmpty ? "ownkeepass/notes.kdb" : "",
                                       "useKeyFile": false,
                                       "keyFileLocation": 0,
                                       "keyFilePath": "",
                                       "loadLastDb": ownKeepassSettings.loadLastDb,
                                       "password": ""
                                   })
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Open database"
                onClicked: {
                    pageStack.push(queryPasswordDialogComponent,
                                   {
                                       "state": "OpenNewDatabase",
                                       "dbFileLocation": 0,
                                       "dbFilePath": "",
                                       "useKeyFile": false,
                                       "keyFileLocation": 0,
                                       "keyFilePath": "",
                                       "loadLastDb": ownKeepassSettings.loadLastDb,
                                       "password": ""
                                   })
                }
            }

            SectionHeader {
                enabled: !recentDatabaseModel.isEmpty
                visible: enabled
                text: "Recent databases"
            }
        }

        delegate: recentDatabaseListItemComponent
    }

    KdbDatabase {
        id: kdbDatabase
        onDatabaseOpened: internal.databaseOpenedHandler()
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler()
        onDatabaseClosed: internal.databaseClosedHandler()
        onDatabasePasswordChanged: internal.databasePasswordChangedHandler()
        onErrorOccured: internal.errorHandler(result, errorMsg)
    }

    Connections {
        target: ownKeepassSettings
        onLoadLastDatabase: { // returns: dbLocation, dbFilePath, ...
            // Set database name in global object for pulley menu on query password page
            applicationWindow.databaseUiName = Global.getLocationName(dbLocation) + " " + dbFilePath
            pageStack.push(queryPasswordDialogComponent,
                           { "state": "OpenRecentDatabase",
                             "dbFileLocation": dbLocation,
                             "dbFilePath": dbFilePath,
                             "useKeyFile": useKeyFile,
                             "keyFileLocation": keyFileLocation,
                             "keyFilePath": keyFilePath,
                             "loadLastDb": ownKeepassSettings.loadLastDb,
                             "password": "" })
        }
    }

    Component.onCompleted: {
        // Init some global variables
        Global.env.setMainPage(mainPage)
        Global.env.setKdbDatabase(kdbDatabase)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // If this page gets active the database is definitely closed and needs to be opened again
            // so set cover page state accordingly
            applicationWindow.cover.title = ""
            applicationWindow.cover.state = "NO_DATABASE_OPENED"
            // now also check database and key file paths if they exists
            internal.init()
        }
    }

    // Internal data which is used during open or create of Keepass database
    QtObject {
        id: internal
        property bool overWriteDbfileCheck: false
        // These values will be used on creation and opening of database
        // If creation of database and opening succeeds these values will be stored in settings.ini
        property int dbFileLocation: 0
        property string databasePath: ""
        property bool useKeyFile: false
        property int keyFileLocation: 0
        property string keyFilePath: ""
        property bool loadLastDb: false
        property Page masterGroupsPage

        function openKeepassDatabase(password,
                                     createNewDatabase,
                                     acceptDestinationInstance,
                                     dbFileLocation,
                                     dbFilePath,
                                     useKeyFile,
                                     keyFileLocation,
                                     keyFilePath) {
            // Save handler to masterGroups page, it is needed to init the view once the database
            // could be opened with given password and/or key file
            internal.masterGroupsPage = acceptDestinationInstance
            internal.dbFileLocation = dbFileLocation
            internal.databasePath =  dbFilePath
            internal.useKeyFile = useKeyFile
            internal.keyFileLocation = keyFileLocation
            internal.keyFilePath = keyFilePath

            if (password === "") console.log("ERROR: Password is empty")
            // prepate database and key file
            var completeDbFilePath = getRootPath(dbFileLocation) + "/" + databasePath
            var completeKeyFilePath
            if (useKeyFile) completeKeyFilePath = getRootPath(keyFileLocation) + "/" + keyFilePath
            else completeKeyFilePath = ""

            if (createNewDatabase) {
                // Check if database file already exists and if key file is present if it should be used
                if (!ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // Ok, now check if path to file exists if not create it
                        if (ownKeepassHelper.createFilePathIfNotExist(completeDbFilePath)) {
                            // set default values for encryption and key transformation rounds
                            kdbDatabase.keyTransfRounds = ownKeepassSettings.defaultKeyTransfRounds
                            kdbDatabase.cryptAlgorithm = ownKeepassSettings.defaultCryptAlgorithm
                            // create new Keepass database
                            kdbDatabase.create(completeDbFilePath, completeKeyFilePath, password, true)
                            kdbListItemInternal.databaseKeyFile = completeKeyFilePath
                        } else {
                            // Path to new database file could not be created
                            Global.env.infoPopup.show("Permission error", "Cannot create path for your Keepass database file. You may need to set directory permissions for user \'nemo\'.", 0, false)
                            masterGroupsPage.closeOnError()
                        }
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key file error", "Database path is ok, but your key file is not present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file already exists
                    Global.env.infoPopup.show("Database file already exists", "Please specify another path and name for your Keepass database or delete the old database within a Filebrowser.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            } else {
                // Check if database exists and if key file exists in case it should be used
                if (ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // open existing Keepass database
                        kdbDatabase.open(completeDbFilePath, completeKeyFilePath, password, false)
                        kdbListItemInternal.databaseKeyFile = completeKeyFilePath
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key file error", "Database path is ok, but your key file is not present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file does not exist
                    Global.env.infoPopup.show("Database file error", "Database file does not exist. Please check path to database file again.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            }
        }

        // Get phisical path for file location
        function getRootPath(value) {
            switch (value) {
            case 0:
                return ownKeepassHelper.getJollaPhoneDocumentsPath()
            case 1:
                return ownKeepassHelper.getSdCardPath()
            case 2:
                return ownKeepassHelper.getAndroidStoragePath()
            case 3:
                return ownKeepassHelper.getSailboxLocalStoragePath()
            }
        }

        function init() {
            // load settings into kdbDatabase
            kdbDatabase.showUserNamePasswordsInListView = ownKeepassSettings.showUserNamePasswordInListView
            // initialize check if the last used database should be opened again
            ownKeepassSettings.checkLoadLastDatabase()
        }

        function updateRecentDatabaseListModel() {
            // update recent database list
            var uiName = internal.databasePath.substring(internal.databasePath.lastIndexOf("/") + 1, internal.databasePath.length)
            var uiPath = Global.getLocationName(internal.dbFileLocation) + internal.databasePath.substring(0, internal.databasePath.lastIndexOf("/") + 1)
            ownKeepassSettings.addRecentDatabase(uiName,
                                                 uiPath,
                                                 internal.dbFileLocation,
                                                 internal.databasePath,
                                                 internal.useKeyFile,
                                                 internal.keyFileLocation,
                                                 internal.keyFilePath)
            ownKeepassSettings.loadLastDb = internal.loadLastDb
            // Set database name in global object for pulley menu on groups and entries pages
            applicationWindow.databaseUiName = Global.getLocationName(dbFileLocation) + " " + databasePath
            // Get database name and set on cover page for create new and open database states
            applicationWindow.cover.title = databasePath.substring(
                        databasePath.lastIndexOf("/") + 1, databasePath.length)
        }

        function databaseOpenedHandler() {
            // Yeah, database opened successfully, now init master groups page and cover page
            masterGroupsPage.init()
            updateRecentDatabaseListModel()
        }

        function newDatabaseCreatedHandler() {
            // Yeah, database created successfully, now init master groups page and cover page
            masterGroupsPage.init()
            updateRecentDatabaseListModel()
        }

        function databaseClosedHandler() {
            console.log("Database closed")
        }

        function databasePasswordChangedHandler() {
            console.log("Database password changed successfully")
            Global.env.infoPopup.show("Password changed", "The master password of your database was changed successfully.", 3, false)

        }

        function errorHandler(result, errorMsg) {
            console.log("Database Error occured: " + result)
            // show error to the user
            switch (result) {
            case KdbDatabase.RE_DB_CLOSE_FAILED:
                Global.env.infoPopup.show("Internal database error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SETKEY_ERROR:
                Global.env.infoPopup.show("Internal key error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR:
                Global.env.infoPopup.show("Internal key file error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_LOAD_ERROR:
                Global.env.infoPopup.show("Error loading database", errorMsg + " Please try again.", 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_FILE_ERROR:
                Global.env.infoPopup.show("Internal file error", "The following error occured during creation of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_CREATE_BACKUPGROUP_ERROR:
                Global.env.infoPopup.show("Internal database error", "Creation of backup group failed with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SAVE_ERROR:
                Global.env.infoPopup.show("Save database error", "Could not save database with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_ALREADY_CLOSED:
                Global.env.infoPopup.show("Database error", "Database was already closed. Nothing serious, but please submit a bug report.", 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_CLOSE_FAILED:
                Global.env.infoPopup.show("Database error", "An error occured on closing your database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            default:
                console.log("ERROR: unknown result on database error occured")
                break
            }
        }
    }

    // This object is used in the scope of list view on GroupsAndEntriesPage
    // So that those various pages can pass data between each other
    QtObject {
        id: kdbListItemInternal

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
          Here are the details for Kdb groups. The same applies like for Kdb entries
          */
        property string originalGroupName: ""
// TODO                property int originalGroupImageId: 0
        property string groupName: ""
// TODO                property int groupImageId: 0

        /*
          Data used to save database setting values in KdbDatabase object
          */
        property string databaseKeyFile: ""
        property string databaseMasterPassword: ""
        property int databaseCryptAlgorithm: 0
        property int databaseKeyTransfRounds: 0

        /*
          Data used to save ownKeepass default setting values
          */
        property int defaultCryptAlgorithm
        property int defaultKeyTransfRounds
        property int inactivityLockTime
        property bool showUserNamePasswordInListView
        property bool focusSearchBarOnStartup
        property bool showUserNamePasswordOnCover
        property bool lockDatabaseFromCover
        property bool copyNpasteFromCover

        /*
          Commonly used for manipulation and creation of entries and groups
          */
        property bool createNewItem: false
        property int itemId: 0
        property int parentGroupId: 0

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
                                  { "state": "QUERY_FOR_ENTRY" })
            }
        }

        function checkForUnsavedKdbGroupChanges() {
            if (originalGroupName !== groupName) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "state": "QUERY_FOR_GROUP" })
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
                                  { "state": "QUERY_FOR_DATABASE_SETTINGS" })
            }
        }

        function saveDatabaseSettings() {
            if (databaseMasterPassword !== "")
                Global.env.kdbDatabase.changePassword(databaseMasterPassword, databaseKeyFile)
            databaseMasterPassword = ""
            if (databaseCryptAlgorithm !== Global.env.kdbDatabase.cryptAlgorithm)
                Global.env.kdbDatabase.cryptAlgorithm = databaseCryptAlgorithm
            if (databaseKeyTransfRounds !== Global.env.kdbDatabase.keyTransfRounds)
                Global.env.kdbDatabase.keyTransfRounds = databaseKeyTransfRounds
        }

        function setKeepassSettings(aDefaultCryptAlgorithm, aDefaultKeyTransfRounds, aInactivityLockTime,
                                    aShowUserNamePasswordInListView, aFocusSearchBarOnStartup, aShowUserNamePasswordOnCover,
                                    aLockDatabaseFromCover, aCopyNpasteFromCover) {
            defaultCryptAlgorithm = aDefaultCryptAlgorithm
            defaultKeyTransfRounds = aDefaultKeyTransfRounds
            inactivityLockTime = aInactivityLockTime
            showUserNamePasswordInListView = aShowUserNamePasswordInListView
            focusSearchBarOnStartup = aFocusSearchBarOnStartup
            showUserNamePasswordOnCover = aShowUserNamePasswordOnCover
            lockDatabaseFromCover = aLockDatabaseFromCover
            copyNpasteFromCover = aCopyNpasteFromCover
        }

        function checkForUnsavedKeepassSettingsChanges() {
            if (
                    ownKeepassSettings.defaultCryptAlgorithm !== defaultCryptAlgorithm ||
                    ownKeepassSettings.defaultKeyTransfRounds !== defaultKeyTransfRounds ||
                    ownKeepassSettings.locktime !== inactivityLockTime ||
                    ownKeepassSettings.showUserNamePasswordInListView !== showUserNamePasswordInListView ||
                    ownKeepassSettings.focusSearchBarOnStartup !== focusSearchBarOnStartup ||
                    ownKeepassSettings.showUserNamePasswordOnCover !== showUserNamePasswordOnCover ||
                    ownKeepassSettings.lockDatabaseFromCover !== lockDatabaseFromCover ||
                    ownKeepassSettings.copyNpasteFromCover !== copyNpasteFromCover) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "state": "QUERY_FOR_APP_SETTINGS"})
            }
        }

        function saveKeepassSettings() {
            ownKeepassSettings.defaultCryptAlgorithm = defaultCryptAlgorithm
            ownKeepassSettings.defaultKeyTransfRounds = defaultKeyTransfRounds
            ownKeepassSettings.locktime = inactivityLockTime
            ownKeepassSettings.showUserNamePasswordInListView = showUserNamePasswordInListView
            ownKeepassSettings.focusSearchBarOnStartup = focusSearchBarOnStartup
            ownKeepassSettings.showUserNamePasswordOnCover = showUserNamePasswordOnCover
            ownKeepassSettings.lockDatabaseFromCover = lockDatabaseFromCover
            ownKeepassSettings.copyNpasteFromCover = copyNpasteFromCover
        }
    }

    KdbGroup {
        id: kdbGroup
        onGroupDataLoaded: kdbListItemInternal.loadKdbGroupDetails(title)
        onGroupDataSaved: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
        onNewGroupCreated: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntry
        onEntryDataLoaded: kdbListItemInternal.loadKdbEntryDetails(title, url, username, password, comment)
        onEntryDataSaved: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
        onNewEntryCreated: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
    }


    // We need separate objects for deletion because of the 5 seconds guard period where
    // the user can undo the delete operation, i.e. the deletion is delayed and the user
    // might open another item which would then be deleted if we don't use separate
    // objects here
    KdbGroup {
        id: kdbGroupForDeletion
        onGroupDeleted: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntryForDeletion
        onEntryDeleted: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
    }

    Component {
        id: queryPasswordDialogComponent
        QueryPasswordDialog {
            onAccepted: {
                internal.openKeepassDatabase(password,
                                             state === "CreateNewDatabase",
                                             acceptDestinationInstance,
                                             dbFileLocation,
                                             dbFilePath,
                                             useKeyFile,
                                             keyFileLocation,
                                             keyFilePath)
                internal.loadLastDb = loadLastDb
            }
            onRejected: {
                // Reset "Open Automatically" so that the dialog does not open again
                ownKeepassSettings.loadLastDb = false
            }
        }
    }

    Component {
        id: recentDatabaseListItemComponent
        ListItem {
            id: listItem
            contentHeight: Theme.itemSizeMedium // two line delegate

            Column {
                width: parent.width
                height: children.height
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingSmall

                Label {
                    id: firstLabel
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    horizontalAlignment: Text.AlignLeft
                    text: model.uiName
                    font.pixelSize: Theme.fontSizeMedium
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    id: secondLabel
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    horizontalAlignment: Text.AlignLeft
                    text: model.uiPath
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                }
            }

            onClicked: {
                // Set database name in global object for pulley menu on query password page
                applicationWindow.databaseUiName = Global.getLocationName(model.databaseLocation) + " " + model.databaseFilePath
                pageStack.push(queryPasswordDialogComponent,
                               { "state": "OpenRecentDatabase",
                                 "dbFileLocation": model.databaseLocation,
                                 "dbFilePath": model.databaseFilePath,
                                 "useKeyFile": model.useKeyFile,
                                 "keyFileLocation": model.keyFileLocation,
                                 "keyFilePath": model.keyFilePath,
                                 "loadLastDb": ownKeepassSettings.loadLastDb,
                                 "password": "" })
            }
        }
    }

    Component {
        id: kdbListItemComponent
        KdbListItem {
            id: kdbListItem
        }
    }

    Component {
        id: showEntryDetailsPageComponent
        ShowEntryDetailsPage {
            id: showEntryDetailsPage
        }
    }

    Component {
        id: editEntryDetailsDialogComponent
        EditEntryDetailsDialog {
            id: editEntryDetailsDialog
        }
    }

    Component {
        id: editGroupDetailsDialogComponent
        EditGroupDetailsDialog {
            id: editGroupDetailsDialog
        }
    }

    Component {
        id: editDatabaseSettingsDialogComponent
        EditDatabaseSettingsDialog {
            id: editDatabaseSettingsDialog
        }
    }

    Component {
        id: editSettingsDialogComponent
        EditSettingsDialog {
            id: editSettingsDialog
        }
    }

    Component {
        id: queryDialogForUnsavedChangesComponent
        QueryDialog {
            id: queryDialogForUnsavedChanges
            headerAcceptText: "Yes"
            headerTitleText: "Yes"
            titleText: "Unsaved changes"
            message: ""

            onAccepted: {
                switch (state) {
                case "QUERY_FOR_ENTRY":
                    kdbListItemInternal.saveKdbEntryDetails()
                    break
                case "QUERY_FOR_GROUP":
                    kdbListItemInternal.saveKdbGroupDetails()
                    break
                case "QUERY_FOR_DATABASE_SETTINGS":
                    kdbListItemInternal.saveDatabaseSettings()
                    break
                case "QUERY_FOR_APP_SETTINGS":
                    kdbListItemInternal.saveKeepassSettings()
                    break
                default:
                    console.log("ERROR in query for unsaved changes")
                    break
                }
            }

            state: "QUERY_FOR_ENTRY"
            states: [
                State {
                    name: "QUERY_FOR_ENTRY"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: "Do you want to save changes to the password entry?" }
                },
                State {
                    name: "QUERY_FOR_GROUP"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: "Do you want to save changes to the password group?" }
                },
                State {
                    name: "QUERY_FOR_DATABASE_SETTINGS"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: "Do you want to save changes to database settings?" }
                },
                State {
                    name: "QUERY_FOR_APP_SETTINGS"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: "Do you want to save changed settings values?" }
                }
            ]
        }
    }

}
