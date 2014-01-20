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
import harbour.ownkeepass 1.0

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
        var inactivityTime = Global.getInactivityTime(OwnKeepassSettings.locktime)
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
        currentIndex: -1
        anchors.fill: parent
        model: recentDatabaseListModel

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        ApplicationMenu {}

//        DatabaseMenu {
//            id: databaseMenu
//        }

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
                    var dialog = pageStack.push("QueryPasswordDialog.qml",
                                                {
                                                    "state": "CreateNewDatabase",
                                                    "dbFileLocation": 0,
                                                    // If ownKeepass was opened the very first time give the user a predefined database file path and name
                                                    "dbFilePath": recentDatabaseListModel.isEmpty ? "ownkeepass/notes.kdb" : "",
                                                    "useKeyFile": false,
                                                    "keyFileLocation": 0,
                                                    "keyFilePath": "",
                                                    "loadAsDefault": false,
                                                    // Development mode here for faster testing with predefined database file
                                                    "password": Global.developmentMode === 1 ? "qwertz" : ""
                                                })
                    dialog.accepted.connect(function() {
                        // Get handler to masterGroups page, it is needed to init the view once the database
                        // could be opened with given password and/or key file
                        internal.masterGroupsPage = dialog.acceptDestinationInstance
                        // take over details from QueryPasswordDialog
                        internal.dbFileLocation = dialog.dbFileLocation
                        internal.databasePath =  dialog.dbFilePath
                        internal.useKeyFile = dialog.useKeyFile
                        internal.keyFileLocation = dialog.keyFileLocation
                        internal.keyFilePath = dialog.keyFilePath
                        OwnKeepassSettings.loadLastDb = dialog.loadAsDefault
                        internal.masterPassword = dialog.password

                        var createNewDatabase = true
                        internal.openKeepassDatabase(dialog.password, createNewDatabase)
                    })
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Open Database"
                onClicked: {
                    var dialog = pageStack.push("QueryPasswordDialog.qml",
                                                {
                                                    "state": "OpenNewDatabase",
                                                    "dbFileLocation": 0,
                                                    "dbFilePath": "",
                                                    "useKeyFile": false,
                                                    "keyFileLocation": 0,
                                                    "keyFilePath": "",
                                                    "loadAsDefault": false,
                                                    // Development mode here for faster testing with predefined database file
                                                    "password": Global.developmentMode === 1 ? "qwertz" : ""
                                                })
                    dialog.accepted.connect(function() {
                        // Get handler to masterGroups page, it is needed to init the view once the database
                        // could be opened with given password and/or key file
                        internal.masterGroupsPage = dialog.acceptDestinationInstance
                        // take over details from QueryPasswordDialog
                        internal.dbFileLocation = dialog.dbFileLocation
                        internal.databasePath =  dialog.dbFilePath
                        internal.useKeyFile = dialog.useKeyFile
                        internal.keyFileLocation = dialog.keyFileLocation
                        internal.keyFilePath = dialog.keyFilePath
                        OwnKeepassSettings.loadLastDb = dialog.loadAsDefault
                        internal.masterPassword = dialog.password

                        var createNewDatabase = false
                        internal.openKeepassDatabase(dialog.password, createNewDatabase)
                    })
                }
            }

            SectionHeader {
                enabled: !recentDatabaseListModel.isEmpty
                visible: enabled
                text: "Recent databases"
            }
        }

        delegate: ListItem {
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
//                        Tracer {}

            onClicked: {
                console.log("Clicked on recent DB no: " + index)
                internal.recentlyOpenedDatabaseNo = index
                var dialog = pageStack.push("QueryPasswordDialog.qml",
                                            {
                                                "state": "OpenRecentDatabase",
                                                "dbFileLocation": model.databaseLocation,
                                                "dbFilePath": model.databaseFilePath,
                                                "useKeyFile": model.useKeyFile,
                                                "keyFileLocation": model.keyFileLocation,
                                                "keyFilePath": model.keyFilePath,
                                                "loadAsDefault": OwnKeepassSettings.loadLastDb,
                                                // Development mode here for faster testing with predefined database file
                                                "password": Global.developmentMode === 1 ? "qwertz" : ""
                                            })
                dialog.rejected.connect(function() {
                    console.log("cancel open of recent database")
                    internal.recentlyOpenedDatabaseNo = -1
                })
                dialog.accepted.connect(function() {
                    // Get handler to masterGroups page, it is needed to init the view once the database
                    // could be opened with given password and/or key file
                    internal.masterGroupsPage = dialog.acceptDestinationInstance
                    // take over details from QueryPasswordDialog
                    internal.dbFileLocation = dialog.dbFileLocation
                    internal.databasePath =  dialog.dbFilePath
                    internal.useKeyFile = dialog.useKeyFile
                    internal.keyFileLocation = dialog.keyFileLocation
                    internal.keyFilePath = dialog.keyFilePath
                    OwnKeepassSettings.loadLastDb = dialog.loadAsDefault
                    internal.masterPassword = dialog.password

                    var createNewDatabase = false
                    internal.openKeepassDatabase(dialog.password, createNewDatabase)
                })
            }
        }
    }

    KdbDatabase {
        id: kdbDatabase
        onDatabaseOpened: internal.databaseOpenedHandler()
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler()
        onDatabaseClosed: internal.databaseClosedHandler()
        onDatabasePasswordChanged: internal.databasePasswordChangedHandler()
        onErrorOccured: internal.errorHandler(result, errorMsg)
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
            applicationWindow.cover.coverState = Global.constants.databaseClosed
            // now also check database and key file paths if they exists
            internal.init()
        }
    }

    // Internal data which is used during open or create of Keepass database
    QtObject {
        id: internal
        property string masterPassword: ""
        property bool overWriteDbfileCheck: false
        // These values will be used on creation and opening of database
        // If creation of database and opening succeeds these values will be stored in settings.ini
        property int dbFileLocation: 0
        property string databasePath: ""
        property bool useKeyFile: false
        property int keyFileLocation: 0
        property string keyFilePath: ""
        // This is used to check if a file on the recent database list exists if tried to openKeepassDatabase
        // If not set it to 0-5 so that we need after the checking which position to delete in the recent database list array
        property int recentlyOpenedDatabaseNo: -1

        property Page masterGroupsPage

        function openKeepassDatabase(password, createNewDatabase) {
            if (password === "") console.log("ERROR: Password is empty")
            // prepate database and key file
            var completeDbFilePath = getRootPath(dbFileLocation) + "/" + databasePath
            var completeKeyFilePath
            if (useKeyFile) completeKeyFilePath = getRootPath(keyFileLocation) + "/" + keyFilePath
            else completeKeyFilePath = ""

            if (createNewDatabase) {
                // Check if database file already exists and if key file is present if it should be used
                if (!OwnKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || OwnKeepassHelper.fileExists(completeKeyFilePath)) {
                        // Ok, now check if path to file exists if not create it
                        if (OwnKeepassHelper.createFilePathIfNotExist(completeDbFilePath)) {
                            // set default values for encryption and key transformation rounds
                            kdbDatabase.keyTransfRounds = OwnKeepassSettings.defaultKeyTransfRounds
                            kdbDatabase.cryptAlgorithm = OwnKeepassSettings.defaultCryptAlgorithm
                            // create new Keepass database
                            kdbDatabase.create(completeDbFilePath, completeKeyFilePath, password, true)
                        } else {
                            // Path to new database file could not be created
                            Global.env.infoPopup.show("Permission Error", "Cannot create path for your Keepass database file. You may need to set directory permissions for user \'nemo\'.", 0, false)
                            masterGroupsPage.closeOnError()
                        }
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file already exists
                    Global.env.infoPopup.show("Database File already exists", "Please specify another path or name for your Keepass database.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            } else {
                // Check if database exists and if key file exists in case it should be used
                if (OwnKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || OwnKeepassHelper.fileExists(completeKeyFilePath)) {
                        // open existing Keepass database
                        kdbDatabase.open(completeDbFilePath, completeKeyFilePath, password, false)
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file does not exist
                    Global.env.infoPopup.show("Database File Error", "Database file does not exist. Please check path to database file again.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            }
        }

        // Get Name for file location
        function getLocationName(value) {
            switch (value) {
            case 0:
                return "Documents: "
            case 1:
                return "SD Card: "
            case 2:
                return "Android Storage: "
            case 3:
                return "Sailbox: "
            }
        }

        // Get phisical path for file location
        function getRootPath(value) {
            switch (value) {
            case 0:
                return jollaPhoneDocumentsPath
            case 1:
                return sdCardPath
            case 2:
                return androidStoragePath
//            case 3:
//                return sailboxPath
            }
        }

        function init() {
            // load settings into kdbDatabase
            kdbDatabase.showUserNamePasswordsInListView = OwnKeepassSettings.showUserNamePasswordInListView
        }

        function updateRecentDatabaseListModel() {
            // update recent database list
            var uiName = internal.databasePath.substring(internal.databasePath.lastIndexOf("/") + 1, internal.databasePath.length)
            var uiPath = getLocationName(internal.dbFileLocation) + internal.databasePath.substring(0, internal.databasePath.lastIndexOf("/") + 1)
            recentDatabaseListModel.addRecent(uiName,
                                              uiPath,
                                              internal.dbFileLocation,
                                              internal.databasePath,
                                              internal.useKeyFile,
                                              internal.keyFileLocation,
                                              internal.keyFilePath)
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
        }

        function errorHandler(result, errorMsg) {
            console.log("Database Error occured: " + result)
            // show error to the user
            switch (result) {
            case KdbDatabase.RE_DB_CLOSE_FAILED:
                Global.env.infoPopup.show("Internal Database Error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SETKEY_ERROR:
                Global.env.infoPopup.show("Internal Key Error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR:
                Global.env.infoPopup.show("Internal Keyfile Error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_LOAD_ERROR:
                Global.env.infoPopup.show("Error loading Database", errorMsg + " Please try again.", 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_FILE_ERROR:
                Global.env.infoPopup.show("Internal File Error", "The following error occured during creation of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_CREATE_BACKUPGROUP_ERROR:
                Global.env.infoPopup.show("Internal Database Error", "Creation of backup group failed with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_SAVE_ERROR:
                Global.env.infoPopup.show("Save Database Error", "Could not save database with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_ALREADY_CLOSED:
                Global.env.infoPopup.show("Database Error", "Database was already closed. Nothing serious, but please submit a bug report.", 0, false)
                masterGroupsPage.closeOnError()
                break
            case KdbDatabase.RE_DB_CLOSE_FAILED:
                Global.env.infoPopup.show("Database Error", "An error occured on closing your database: " + errorMsg, 0, false)
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
        property string databaseMasterPassword: ""
        property int databaseCryptAlgorithm: 0
        property int databaseKeyTransfRounds: 0

        /*
          Data used to save ownKeepass default setting values
          */
//        property string defaultDatabaseFilePath
//        property string defaultKeyFilePath
        property int defaultCryptAlgorithm
        property int defaultKeyTransfRounds
        property int inactivityLockTime
        property bool showUserNamePasswordInListView
        property bool showUserNamePasswordOnCover
        property bool lockDatabaseFromCover
        property bool copyNpasteFromCover

        /*
          Commonly used for manipulation and creation of entries and groups
          */
        property bool createNewItem: false
        property int itemId: 0
        property int parentGroupId: 0

        // some constants
        readonly property int c_queryForEntry: 1
        readonly property int c_queryForGroup: 2
        readonly property int c_queryForDatabaseSettings: 3
        readonly property int c_queryForKeepassSettings: 4

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

        function setKeepassSettings(
//            aDefaultDatabaseFilePath, aDefaultKeyFilePath,
            aDefaultCryptAlgorithm,
                                    aDefaultKeyTransfRounds, aInactivityLockTime, aShowUserNamePasswordInListView,
                                    aShowUserNamePasswordOnCover, aLockDatabaseFromCover, aCopyNpasteFromCover) {
//            defaultDatabaseFilePath = aDefaultDatabaseFilePath
//            defaultKeyFilePath = aDefaultKeyFilePath
            defaultCryptAlgorithm = aDefaultCryptAlgorithm
            defaultKeyTransfRounds = aDefaultKeyTransfRounds
            inactivityLockTime = aInactivityLockTime
            showUserNamePasswordInListView = aShowUserNamePasswordInListView
            showUserNamePasswordOnCover = aShowUserNamePasswordOnCover
            lockDatabaseFromCover = aLockDatabaseFromCover
            copyNpasteFromCover = aCopyNpasteFromCover
        }

        function checkForUnsavedKeepassSettingsChanges() {
            if (
                    OwnKeepassSettings.defaultCryptAlgorithm !== defaultCryptAlgorithm ||
                    OwnKeepassSettings.defaultKeyTransfRounds !== defaultKeyTransfRounds ||
                    OwnKeepassSettings.locktime !== inactivityLockTime ||
                    OwnKeepassSettings.showUserNamePasswordInListView !== showUserNamePasswordInListView ||
                    OwnKeepassSettings.showUserNamePasswordOnCover !== showUserNamePasswordOnCover ||
                    OwnKeepassSettings.lockDatabaseFromCover !== lockDatabaseFromCover ||
                    OwnKeepassSettings.copyNpasteFromCover !== copyNpasteFromCover) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "type": c_queryForKeepassSettings})
            }
        }

        function saveKeepassSettings() {
            OwnKeepassSettings.defaultCryptAlgorithm = defaultCryptAlgorithm
            OwnKeepassSettings.defaultKeyTransfRounds = defaultKeyTransfRounds
            OwnKeepassSettings.locktime = inactivityLockTime
            OwnKeepassSettings.showUserNamePasswordInListView = showUserNamePasswordInListView
            OwnKeepassSettings.showUserNamePasswordOnCover = showUserNamePasswordOnCover
            OwnKeepassSettings.lockDatabaseFromCover = lockDatabaseFromCover
            OwnKeepassSettings.copyNpasteFromCover = copyNpasteFromCover
            OwnKeepassSettings.saveSettings()
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
            state: ""
            property int type: 0
            headerAcceptText: "Yes"
            headerTitleText: "Yes"
            titleText: "Unsaved Changes"
            message: type === kdbListItemInternal.c_queryForEntry ?
                         "Do you want to save changes to the Password Entry?" :
                         type === kdbListItemInternal.c_queryForGroup ?
                             "Do you want to save changes to the Password Group?" :
                             type === kdbListItemInternal.c_queryForDatabaseSettings ?
                                 "Do you want to save changes to Database Settings?" :
                                 type === kdbListItemInternal.c_queryForKeepassSettings ?
                                     "Do you want to save changed settings values?" : ""

            onAccepted:  type === kdbListItemInternal.c_queryForEntry ?
                             kdbListItemInternal.saveKdbEntryDetails() :
                             type === kdbListItemInternal.c_queryForGroup ?
                                 kdbListItemInternal.saveKdbGroupDetails() :
                                 type === kdbListItemInternal.c_queryForDatabaseSettings ?
                                     kdbListItemInternal.saveDatabaseSettings() :
                                     type === kdbListItemInternal.c_queryForKeepassSettings ?
                                         kdbListItemInternal.saveKeepassSettings() : console.log("ERROR in query for unsaved changes")
        }
    }

}


