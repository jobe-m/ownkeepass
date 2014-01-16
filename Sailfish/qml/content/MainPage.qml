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
        var inactivityTime = Global.env.keepassSettings.getInactivityTime()
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

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        ApplicationMenu {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

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
                                                    "dbFileLocation": internal.dbFileLocation,
                                                    "dbFilePath": internal.databasePath,
                                                    "useKeyFile": internal.useKeyFile,
                                                    "keyFileLocation": internal.keyFileLocation,
                                                    "keyFilePath": internal.keyFilePath,
                                                    "loadAsDefault": internal.loadAsDefault,
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
                        internal.loadAsDefault = dialog.loadAsDefault
                        internal.masterPassword = dialog.password
                        internal.createNewDatabase = true

                        internal.openKeepassDatabase(dialog.password, true)
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
                                                    "dbFileLocation": internal.dbFileLocation,
                                                    "dbFilePath": internal.databasePath,
                                                    "useKeyFile": internal.useKeyFile,
                                                    "keyFileLocation": internal.keyFileLocation,
                                                    "keyFilePath": internal.keyFilePath,
                                                    "loadAsDefault": internal.loadAsDefault,
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
                        internal.loadAsDefault = dialog.loadAsDefault
                        internal.masterPassword = dialog.password
                        internal.createNewDatabase = false

                        internal.openKeepassDatabase(dialog.password, false)
                    })
                }
            }

            SectionHeader {
                enabled: recentDatabasesRepeater.model !== 0
                visible: recentDatabasesRepeater.model !== 0
                text: "Recent databases"
            }

            Repeater {
                id: recentDatabasesRepeater
                model: 0

                Column {
                    width: parent.width
                    height: children.height
                    ListItem {
                        id: listItem
                        contentHeight: Theme.itemSizeMedium // two line delegate

                        Column {
                            width: parent.width
                            height: children.height
                            spacing: Theme.paddingSmall

                            Label {
                                id: firstLabel
                                x: Theme.paddingLarge
                                width: parent.width - Theme.paddingLarge * 2
                                horizontalAlignment: Text.AlignLeft
                                text: Global.config.recentDbNamesUI[index]
                                font.pixelSize: Theme.fontSizeMedium
                                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            }

                            Label {
                                id: secondLabel
                                x: Theme.paddingLarge
                                width: parent.width - Theme.paddingLarge * 2
                                horizontalAlignment: Text.AlignLeft
                                text: internal.getLocationName(Global.config.recentDbLocations[index]) + ": " +
                                      Global.config.recentDbPathsUI[index]
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                            }
                        }

                        onClicked: {
                            console.log("Clicked on: " + Global.config.recentDbNamesUI[index])
//                            openPasswordPage(false)
//                            saveFilePaths(Global.config.recentDatabaseFilePaths[index],
//                                                   Global.config.recentKeyFilePaths[index])
//                            updateRecentDatabaseList(Global.config.recentDatabaseFilePaths[index],
//                                                              Global.config.recentKeyFilePaths[index])
                        }
                    }
                }
            }
        }
    }

    KdbDatabase {
        id: kdbDatabase
//        onPreCheckDone: internal.preCheckDoneHandler(result)
        onDatabaseOpened: internal.databaseOpenedHandler(result, errorMsg)
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler(result, errorMsg)
        onDatabaseClosed: internal.databaseClosedHandler(result, errorMsg)
    }

    Component.onCompleted: {
        // Init some global variables
        Global.env.setMainPage(mainPage)
        Global.env.setKdbDatabase(kdbDatabase)
        // If ownKeepass was opened the very first time give the user a predefined database file path and name
        if (Global.config.getNumberOfRecents() === 0) {
            internal.databasePath = "ownkeepass/notes.kdb"
        }
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
        property bool createNewDatabase: true
        property string masterPassword: ""
        property bool overWriteDbfileCheck: false
        // Here are default values which will be used on creation and opening of database
        property int dbFileLocation: 0
        property string databasePath: ""
        property bool useKeyFile: false
        property int keyFileLocation: 0
        property string keyFilePath: ""
        property bool loadAsDefault: false

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
                if (!ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // Ok, now check if path to file exists if not create it
                        if (ownKeepassHelper.createFilePathIfNotExist(completeDbFilePath)) {
                            // set default values for encryption and key transformation rounds
                            kdbDatabase.keyTransfRounds = Global.env.keepassSettings.defaultKeyTransfRounds
                            kdbDatabase.cryptAlgorithm = Global.env.keepassSettings.defaultCryptAlgorithm
                            // create new Keepass database
                            kdbDatabase.create(completeDbFilePath, completeKeyFilePath, password, true)

                            // update recent database list
                            Global.config.addNewRecent(dbFileLocation,
                                                       databasePath,
                                                       useKeyFile,
                                                       keyFileLocation,
                                                       keyFilePath)
                            recentDatabasesRepeater.model = Global.config.getNumberOfRecents()
                        } else {
                            // Path to new database file could not be created
                            Global.env.infoPopup.show("Permission Error", "Cannot create path for your \
Keepass database file. You may need to set directory permissions for user \'nemo\'.", 0, false)
                            masterGroupsPage.closeOnError()
                        }
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not \
present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file already exists, ask user if it should be overwritten
// TODO
                    Global.env.infoPopup.show("TODO ;)", "Ask user if he wants to overwrite existing database file. \
Please specify another database file in the mean time.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            } else {
                // Check if database exists and if key file exists in case it should be used
                if (ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // open existing Keepass database
                        kdbDatabase.open(completeDbFilePath, completeKeyFilePath, password, false)

                        // update recent database list
                        Global.config.addNewRecent(dbFileLocation,
                                                   databasePath,
                                                   useKeyFile,
                                                   keyFileLocation,
                                                   keyFilePath)
                        recentDatabasesRepeater.model = Global.config.getNumberOfRecents()
                    } else {
                        // Key file should be used but does not exist
                        Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not \
present. Please check path to key file again.", 0, false)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file does not exist nothing to do
                    Global.env.infoPopup.show("Database File Error", "Database file does not exist. Please check \
path to database file again.", 0, false)
                    masterGroupsPage.closeOnError()
                }
            }
        }

        // Get Name for file location
        function getLocationName(value) {
            switch (value) {
            case 0:
                return "Jolla Documents"
            case 1:
                return "SD Card"
            case 2:
                return "Android Storage"
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
            }
        }

        function init() {
            // load settings into kdbDatabase
            kdbDatabase.showUserNamePasswordsInListView = Global.env.keepassSettings.showUserNamePasswordInListView

            // Go through recent database list and check each database and key file path if they exists
// TODO

//            databasePath = Global.env.keepassSettings.defaultDatabasePath
//            keyFilePath  = Global.env.keepassSettings.defaultKeyFilePath
//            kdbDatabase.preCheck(databasePath, keyFilePath)
        }

//        function preCheckDoneHandler(result) {
//            console.log("onPreCheckDone: " + result)
//            switch (result) {
//            case KdbDatabase.RE_OK: {
////                // files exists so open query password dialog
////                createNewDatabase = false
////                // stop BusyIndicator so that button is shown
////                preCheckBusyIndicator.running = false
//                // If user wants database to be automatically opened on start do it now...
//// TODO check which recent database to open automatically
//                if (Global.env.keepassSettings.loadAsDefault) {
//                    // take over details from recent database list
//// TODO
////                    internal.dbFileLocation = dialog.dbFileLocation
////                    internal.databasePath =  dialog.dbFilePath
////                    internal.useKeyFile = dialog.useKeyFile
////                    internal.keyFileLocation = dialog.keyFileLocation
////                    internal.keyFilePath = dialog.keyFilePath
////                    internal.loadAsDefault = dialog.loadAsDefault

//                    var dialog = pageStack.push("QueryPasswordDialog.qml",
//                                                {
//                                                    "state": "OpenRecentDatabase",
//                                                    "state": "OpenNewDatabase",
//                                                    "dbFileLocation": 0,
//                                                    "dbFilePath": "",
//                                                    "useKeyFile": false,
//                                                    "keyFileLocation": 0,
//                                                    "keyFilePath": "",
//                                                    "loadAsDefault": true
//                                                })
//                    dialog.accepted.connect(function() {
//                        internal.openKeepassDatabase(dialog.password, false)
//                        // delete password once it was used
//                        dialog.password = ""
//                        // Get handler to masterGroups page, it is needed to init the view once the database
//                        // could be opened with given password and/or key file
//                        masterGroupsPage = dialog.acceptDestinationInstance
//                    })
//                }
//                break; }
//            case KdbDatabase.RE_PRECHECK_DB_PATH_ERROR: {
////                // in this case the database file does not exists so let the user create a new keepass database
////                createNewDatabase = true
////                // stop BusyIndicator so that button is shown
////                preCheckBusyIndicator.running = false
//                break; }
//            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_ERROR: {
////                // in this case database file exists but not key file
////                createNewDatabase = true
//                Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not present. Please check ownKeepass Settings for correct path to the key file or leave key file path empty if you don't use a key file with your database.", 0, false)
//                break; }
//            case KdbDatabase.RE_PRECHECK_DB_PATH_CREATION_ERROR: {
////                createNewDatabase = true
//                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your Keepass database file. Please choose another path in ownKeepass Settings.", 0, false)
//                break; }
//            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_CREATION_ERROR: {
////                createNewDatabase = true
//                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your key file. Please choose another path in ownKeepass Settings.", 0, false)
//                break; }
//            default: {
//                Global.env.infoPopup.show("Unknown Error", "Sorry something went wrong. No idea. Maybe reboot your phone and try again.", 0, false)
//                break; }
//            }
//        }

        function databaseOpenedHandler(result, errorMsg) {
            var dialog
            console.log("onDatabaseOpened: " + result)
            switch (result) {
            case KdbDatabase.RE_OK:
                // Yeah, database opened successfully, now init master groups page and cover page
                masterGroupsPage.init()
                break
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Password Error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Keyfile Error", "The following error occured during opening of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_LOAD_ERROR:
                // show error to the user
                Global.env.infoPopup.show("Password Error", errorMsg + " Please try again.", 0, false)
                masterGroupsPage.closeOnError()
                break
            default:
                console.log("ERROR: unknown result on databaseOpened")
                break
            }
        }

        function newDatabaseCreatedHandler(result, errorMsg) {
            var page
            console.log("onNewDatabaseCreated: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // Yeah, database created successfully, now init master groups page and cover page
                masterGroupsPage.init()
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_FILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal File Error", "The following error occured during creation of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Password Error", "The following error occured during creation of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Keyfile Error", "The following error occured during creation of database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_CREATE_BACKUPGROUP_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Creation of backup group failed with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SAVE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Save Database Error", "Could not save database with following error: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            default:
                console.log("ERROR: unknown result on databaseCreated")
                break
            }
        }

        function databaseClosedHandler(result, errorMsg) {
            switch (result) {
            case KdbDatabase.RE_OK:
                console.log("Database closed")
                break
            case KdbDatabase.RE_DB_ALREADY_CLOSED: {
                // show error to the user
                Global.env.infoPopup.show("Database Error", "Database was already closed. Nothing serious, but please submit a bug report.", 0, false)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Database Error", "An error occured on closing your database: " + errorMsg, 0, false)
                masterGroupsPage.closeOnError()
                break }
            default:
                console.log("ERROR: unknown result on databaseClosed")
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
//                    Global.env.keepassSettings.defaultDatabasePath !== defaultDatabaseFilePath ||
//                    Global.env.keepassSettings.defaultKeyFilePath !== defaultKeyFilePath ||
                    Global.env.keepassSettings.defaultCryptAlgorithm !== defaultCryptAlgorithm ||
                    Global.env.keepassSettings.defaultKeyTransfRounds !== defaultKeyTransfRounds ||
                    Global.env.keepassSettings.locktime !== inactivityLockTime ||
                    Global.env.keepassSettings.showUserNamePasswordInListView !== showUserNamePasswordInListView ||
                    Global.env.keepassSettings.showUserNamePasswordOnCover !== showUserNamePasswordOnCover ||
                    Global.env.keepassSettings.lockDatabaseFromCover !== lockDatabaseFromCover ||
                    Global.env.keepassSettings.copyNpasteFromCover !== copyNpasteFromCover) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "type": c_queryForKeepassSettings})
            }
        }

        function saveKeepassSettings() {
//            Global.env.keepassSettings.defaultDatabasePath = defaultDatabaseFilePath
//            Global.env.keepassSettings.defaultKeyFilePath = defaultKeyFilePath
            Global.env.keepassSettings.defaultCryptAlgorithm = defaultCryptAlgorithm
            Global.env.keepassSettings.defaultKeyTransfRounds = defaultKeyTransfRounds
            Global.env.keepassSettings.locktime = inactivityLockTime
            Global.env.keepassSettings.showUserNamePasswordInListView = showUserNamePasswordInListView
            Global.env.keepassSettings.showUserNamePasswordOnCover = showUserNamePasswordOnCover
            Global.env.keepassSettings.lockDatabaseFromCover = lockDatabaseFromCover
            Global.env.keepassSettings.copyNpasteFromCover = copyNpasteFromCover
            Global.env.keepassSettings.saveSettings()
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


