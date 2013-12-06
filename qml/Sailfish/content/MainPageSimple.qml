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
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "../common"
import "../scripts/Global.js" as Global
import KeepassPlugin 1.0

Page {
    id: mainPage

    // Components accessible through root mainPage object from all subpages
    property Component kdbListItemComponent: kdbListItemComponent
    property Component showEntryDetailsPageComponent: showEntryDetailsPageComponent
    property Component editEntryDetailsDialogComponent: editEntryDetailsDialogComponent
    property Component editGroupDetailsDialogComponent: editGroupDetailsDialogComponent
    property Component editDatabaseSettingsDialogComponent: editDatabaseSettingsDialogComponent
    property Component settingsDialogComponent: settingsDialogComponent
    property Component queryDialogForUnsavedChangesComponent: queryDialogForUnsavedChangesComponent

    function inactivityTimerStart() {
        // first check if the user has set timer to unlimited
        // meaning the app should never lock
        if (!inactivityTimer.unlimited) {
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

        property bool unlimited: false

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
        KpPushUpMenu {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }
        }
    }

    KdbDatabase {
        id: kdbDatabase
        onPreCheckDone: internal.preCheckDoneHandler(result)
        onDatabaseOpened: internal.databaseOpenedHandler(result, errorMsg)
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler(result, errorMsg)
        onDatabaseClosed: internal.databaseClosedHandler(result, errorMsg)
    }

    Component.onCompleted: {
        // init some global variables
        Global.env.setMainPage(mainPage)
        Global.env.setKdbDatabase(kdbDatabase)
        Global.env.setKeepassSettings(keepassSettings)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // If this page gets active the database is definitely closed and needs to be opened again
            // so set cover page state accordingly
            applicationWindow.cover.coverState = Global.constants.databaseClosed
            // now also check default database path if file exists
            internal.init()
        }
    }

    QtObject {
        id: keepassSettings
        property bool simpleMode: true
        property bool loadDefault: true // if (simpleMode === true) this is ignored resp. always true
        // default database and key file paths used in simple mode to create one database easily
        property string defaultDatabasePath: "/home/nemo/Documents/notes.kdb"
        property string defaultKeyFilePath: ""
        property int defaultEncryption: 0  // Default encryption: AES/Rijndael = 0, Twofish = 1
        property int defaultKeyTransfRounds: 50000
        property int locktime: 3  // min = 0, max = 10, default = 3
        property bool showUserNamePasswordInListView: false  // default = false

        Component.onCompleted: {
            initDatabase()
            loadSettings()
        }

        onLocktimeChanged: {
            // convert setting into amount of microseconds and set in inactivityTimer
            var interval
                switch (locktime) {
                case 0:
                    interval = Global.constants._1microsecond
                    break
                case 1:
                    interval = Global.constants._5seconds
                    break
                case 2:
                    interval = Global.constants._10seconds
                    break
                case 3:
                    interval = Global.constants._30seconds
                    break
                case 4:
                    interval = Global.constants._1minute
                    break
                case 5:
                    interval = Global.constants._2minutes
                    break
                case 6:
                    interval = Global.constants._5minutes
                    break
                case 7:
                    interval = Global.constants._10minutes
                    break
                case 8:
                    interval = Global.constants._30minutes
                    break
                case 9:
                    interval = Global.constants._60minutes
                    break
                case 10:
                    inactivityTimer.unlimited = true
                    return
                }
                inactivityTimer.unlimited = false
                inactivityTimer.interval = interval
        }

        // Initialize tables we need if they haven't been created yet
        function initDatabase() {
            var db = getDatabase();
            db.transaction(function(tx) {
                // Create the settings table if it doesn't already exist
                // If the table exists, this is skipped
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
            })
        }

        // for internal use
        function getDatabase() {
             return LocalStorage.openDatabaseSync("ownKeepassSettings", "1.0", "Application settings for ownKeepass", 100000);
        }

        /*
          This function is used to retrieve a setting from database
          The function returns “Unknown” if the setting was not found in the database
          */
        function getSetting(setting) {
            var db = getDatabase()
            var res = "UNKNOWN"
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting])
                if (rs.rows.length > 0) {
                    res = rs.rows.item(0).value
                }
            })
            return res
        }

        /*
          This function is used to write a setting into the database
          setting: string representing the setting name
          value: string representing the value of the setting
          The function returns “OK” if it was successful, or “Error” if it wasn't
          */
        function setSetting(setting, value) {
            var db = getDatabase()
            var res = ""
            db.transaction(function(tx) {
                var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
                if (rs.rowsAffected > 0) {
                    res = "OK"
                } else {
                    console.log("ERROR: Cannot save setting - " + setting)
                    res = "ERROR"
                }
            })
            return res
        }


        function loadSettings() {
            var value = getSetting("simpleMode")
            simpleMode = value !== "UNKNOWN" ? (value === "true" ? true : false) : simpleMode
            value = getSetting("loadDefault")
            loadDefault = value !== "UNKNOWN" ? (value === "true" ? true : false) : loadDefault
            value = getSetting("defaultDatabasePath")
            defaultDatabasePath = value !== "UNKNOWN" ? value : defaultDatabasePath
            value = getSetting("defaultKeyFilePath")
            defaultKeyFilePath = value !== "UNKNOWN" ? value : defaultKeyFilePath
            value = getSetting("defaultEncryption")
            defaultEncryption = value !== "UNKNOWN" ? Number(value) : defaultEncryption
            value = getSetting("defaultKeyTransfRounds")
            defaultKeyTransfRounds = value !== "UNKNOWN" ? Number(value) : defaultKeyTransfRounds
            value = getSetting("locktime")
            locktime = value !== "UNKNOWN" ? Number(value) : locktime
            value = getSetting("showUserNamePasswordInListView")
            showUserNamePasswordInListView = value !== "UNKNOWN" ? (value === "true" ? true : false) : showUserNamePasswordInListView
        }

        function saveSettings() {
            // save settings as strings in SQL database
            setSetting("simpleMode", simpleMode ? "true" : "false")
            setSetting("loadDefault", loadDefault ? "true" : "false")
            setSetting("defaultDatabasePath", defaultDatabasePath)
            setSetting("defaultKeyFilePath", defaultKeyFilePath)
            setSetting("defaultEncryption", String(defaultEncryption))
            setSetting("defaultKeyTransfRounds", String(defaultKeyTransfRounds))
            setSetting("locktime", String(locktime))
            setSetting("showUserNamePasswordInListView", showUserNamePasswordInListView ? "true": "false")
        }
    }

    // internal stuff
    QtObject {
        id: internal
        property bool createNewDatabase: true
        property string databasePath: ""
        property string keyFilePath: ""
        property Page masterGroupsPage

        function openKeepassDatabase(password, createNewDatabase) {
            if (password === "") console.log("ERROR: Password is empty")
            if (createNewDatabase) {
                // set default values for encryption and key transformation rounds
                kdbDatabase.keyTransfRounds = keepassSettings.defaultKeyTransfRounds
                kdbDatabase.cryptAlgorithm = keepassSettings.defaultEncryption
                // create new Keepass database
                kdbDatabase.create(databasePath, keyFilePath, password)
            } else {
                // open existing Keepass database
                kdbDatabase.open(databasePath, keyFilePath, password, false)
            }
        }

        function init() {
            // load settings into kdbDatabase
            kdbDatabase.showUserNamePasswordsInListView = keepassSettings.showUserNamePasswordInListView

            if (keepassSettings.loadDefault) {
                databasePath = keepassSettings.defaultDatabasePath
                keyFilePath  = keepassSettings.defaultKeyFilePath
            } else {
                // check if some other recently opened database is set as default = !simpleMode
// TODO for next release ;)

            }
            kdbDatabase.preCheck(databasePath, keyFilePath)
        }

        function preCheckDoneHandler(result) {
            var dialog
            console.log("onPreCheckDone: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // files exists so open query password dialog
                createNewDatabase = false
                dialog = pageStack.push("QueryPasswordDialog.qml", {"createNewDatabase": createNewDatabase})
                            dialog.accepted.connect(function() {
                                openKeepassDatabase(dialog.password, createNewDatabase)
                                // delete password once it was used
                                dialog.password = ""
                                masterGroupsPage = dialog.acceptDestinationInstance
                            })
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_ERROR: {
                // in this case the database file does not exists so let the user create a new keepass database
                createNewDatabase = true
                dialog = pageStack.push("QueryPasswordDialog.qml", {"createNewDatabase": createNewDatabase})
                            dialog.accepted.connect(function() {
                                openKeepassDatabase(dialog.password, createNewDatabase)
                                // delete password once used
                                dialog.password = ""
                                masterGroupsPage = dialog.acceptDestinationInstance
                            })
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_ERROR: {
                // in this case database file exists but not key file
                createNewDatabase = true
                Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not present. Please check ownKeepass Settings for correct path to the key file or leave key file path empty if you don't use a key file with your database.", 0, false)
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_CREATION_ERROR: {
                console.log("ERROR: Cannot create path directories to database file, check your file permissions")
                createNewDatabase = true
                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your Keepass database file. Please choose another path.", 0, false)
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_CREATION_ERROR: {
                createNewDatabase = true
                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your key file. Please choose another path.", 0, false)
                break; }
            default: {
                console.log("ERROR: unknown result on onPreCheckDone")
                break; }
            }
        }

        function databaseOpenedHandler(result, errorMsg) {
            var dialog
            console.log("onDatabaseOpened: " + result)
            switch (result) {
            case KdbDatabase.RE_OK:
                // Yeah, database could be opened successfully, now init master groups page and cover page
                masterGroupsPage.init()
                Global.env.setDatabaseState(Global.constants.databaseOpened)
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
                // open database groups main page and replace password page in page stack
                page = pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                               { "pageTitle": "Password groups",
                                 "groupId": 0,
                                 "loadMasterGroups": true,
                                 "mainPage": mainPage }, false, true);
                masterGroupsPage = page
                // database is now created
                internal.createNewDatabase = false
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

// TODO merge this internal object with above one
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
          Data used to save keepass default setting values
          */
        property string defaultDatabaseFilePath
        property string defaultKeyFilePath
        property int defaultCryptAlgorithm
        property int defaultKeyTransfRounds
        property int inactivityLockTime
        property bool showUserNamePasswordInListView


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

        function setKeepassSettings(aDefaultDatabaseFilePath, aDefaultKeyFilePath, aDefaultCryptAlgorithm,
                                    aDefaultKeyTransfRounds, aInactivityLockTime, aShowUserNamePasswordInListView) {
            defaultDatabaseFilePath = aDefaultDatabaseFilePath
            defaultKeyFilePath = aDefaultKeyFilePath
            defaultCryptAlgorithm = aDefaultCryptAlgorithm
            defaultKeyTransfRounds = aDefaultKeyTransfRounds
            inactivityLockTime = aInactivityLockTime
            showUserNamePasswordInListView = aShowUserNamePasswordInListView
        }

        function checkForUnsavedKeepassSettingsChanges() {
            if (Global.env.keepassSettings.defaultDatabasePath !== defaultDatabaseFilePath ||
                    Global.env.keepassSettings.defaultKeyFilePath !== defaultKeyFilePath ||
                    Global.env.keepassSettings.defaultEncryption !== defaultCryptAlgorithm ||
                    Global.env.keepassSettings.defaultKeyTransfRounds !== defaultKeyTransfRounds ||
                    Global.env.keepassSettings.locktime !== inactivityLockTime ||
                    Global.env.keepassSettings.showUserNamePasswordInListView !== showUserNamePasswordInListView) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "type": c_queryForKeepassSettings})
            }
        }

        function saveKeepassSettings() {
            Global.env.keepassSettings.defaultDatabasePath = defaultDatabaseFilePath
            Global.env.keepassSettings.defaultKeyFilePath = defaultKeyFilePath
            Global.env.keepassSettings.defaultEncryption = defaultCryptAlgorithm
            Global.env.keepassSettings.defaultKeyTransfRounds = defaultKeyTransfRounds
            Global.env.keepassSettings.locktime = inactivityLockTime
            Global.env.keepassSettings.showUserNamePasswordInListView = showUserNamePasswordInListView
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

            ListView.onAdd: AddAnimation {
                target: kdbListItem
            }
            ListView.onRemove: RemoveAnimation {
                target: kdbListItem
            }

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
                source: "../entryicons/_0.png"
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
                // set reference in kdbListItemInternal object
                kdbListItemInternal.editEntryDetailsDialogRef = editEntryDetailsDialog

                kdbEntry.entryId = editEntryDetailsDialog.entryId
                if (!createNewEntry) {
                    kdbEntry.loadEntryData()
                }
                entryTitleTextField.focus = true
            }
            Component.onDestruction: {
                // unset again
                kdbListItemInternal.editEntryDetailsDialogRef = null
            }

            // user wants to save new entry data
            onAccepted: {
                // first save locally Kdb entry details then trigger save to backend
                kdbListItemInternal.setKdbEntryDetails(createNewEntry,
                                            entryId,
                                            parentGroupId,
                                            entryTitleTextField.text,
                                            entryUrlTextField.text,
                                            entryUsernameTextField.text,
                                            entryPasswordTextField.text,
                                            entryCommentTextField.text)
                kdbListItemInternal.saveKdbEntryDetails()
            }
            // user has rejected editing entry data, check if there are unsaved details
            onRejected: {
                // no need for saving if input fields are invalid
                if (canNavigateForward) {
                    // first save locally Kdb entry details then trigger check for unsaved changes
                    kdbListItemInternal.setKdbEntryDetails(createNewEntry,
                                                entryId,
                                                parentGroupId,
                                                entryTitleTextField.text,
                                                entryUrlTextField.text,
                                                entryUsernameTextField.text,
                                                entryPasswordTextField.text,
                                                entryCommentTextField.text)
                    kdbListItemInternal.checkForUnsavedKdbEntryChanges()
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
                kdbListItemInternal.setDatabaseSettings(databaseMasterPassword.text,
                                             databaseCryptAlgorithm.currentIndex,
                                             Number(databaseKeyTransfRounds.text))
                kdbListItemInternal.saveDatabaseSettings()
            }
            // user has rejected changing database settings, check if there are unsaved details
            onRejected: {
                // no need for saving if input field for master password is invalid
                if (canNavigateForward) {
                    // first save locally database settings then trigger check for unsaved changes
                    kdbListItemInternal.setDatabaseSettings(databaseMasterPassword.text,
                                                 databaseCryptAlgorithm.currentIndex,
                                                 Number(databaseKeyTransfRounds.text))
                    kdbListItemInternal.checkForUnsavedDatabaseSettingsChanges()
                }
            }
        } // Dialog
    }

    Component {
        id: settingsDialogComponent
        Dialog {
            id: settingsDialog

            // forbit page navigation if master password is not confirmed
            canNavigateForward: !defaultDatabaseFilePath.errorHighlight

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

                    SectionHeader {
                        text: "Keepass Settings"
                    }

// TODO We have currently only simple mode
//                            TextSwitch {
//                                id: simpleMode
//                                checked: Global.env.keepassSettings.simpleMode
//                                text: "Use Simple Mode"
//                                description: "In simple mode below default Keepass database is automatically loaded on application start. " +
//                                             " If you switch this off you get a list of recently opened Keepass database files instead."
//                            }

//                            SectionHeader {
//                                text: "Database"
//                            }

                    Column {
                        width: parent.width

                        TextField {
                            id: defaultDatabaseFilePath
                            width: parent.width
                            inputMethodHints: Qt.ImhUrlCharactersOnly
                            label: "Default database file path"
                            placeholderText: label
                            errorHighlight: text === ""
                            text: Global.env.keepassSettings.defaultDatabasePath
                            EnterKey.onClicked: parent.focus = true
                        }

                        SilicaLabel {
                            text: Global.env.keepassSettings.simpleMode ?
                                      "This is the name and path of default Keepass database file" :
                                      "This is the path where new Keepass Password Safe files will be stored"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }
                    }

                    TextSwitch {
                        id: useKeyFile
                        checked: Global.env.keepassSettings.defaultKeyFilePath !== ""
                        text: "Create Key File"
                        description: "Switch this on if you want to create a key file together with a new Keepass Password Safe file"
                    }

                    TextField {
                        id: defaultKeyFilePath
                        enabled: useKeyFile.checked
                        opacity: useKeyFile.checked ? 1.0 : 0.0
                        height: useKeyFile.checked ? implicitHeight : 0
                        width: parent.width
                        inputMethodHints: Qt.ImhUrlCharactersOnly
                        label: "Default key file path"
                        placeholderText: label
                        text: Global.env.keepassSettings.defaultKeyFilePath
                        EnterKey.onClicked: parent.focus = true
                        Behavior on opacity { NumberAnimation { duration: 500 } }
                        Behavior on height { NumberAnimation { duration: 500 } }
                    }

                    Column {
                        width: parent.width

                        ComboBox {
                            id: defaultEncryption
                            width: settingsDialog.width
                            label: "Default Encryption in use:"
                            currentIndex: Global.env.keepassSettings.defaultEncryption
                            menu: ContextMenu {
                                MenuItem { text: "AES/Rijndael" }
                                MenuItem { text: "Twofish" }
                            }
                        }

                        SilicaLabel {
                            text: "Choose encryption which will be used as default for a new Keepass Password Safe file"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }
                    }

                    Column {
                        width: parent.width

                        TextField {
                            id: defaultKeyTransfRounds
                            width: parent.width
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: RegExpValidator { regExp: /^[1-9][0-9]*$/ }
                            label: "Default Key Transformation Rounds"
                            placeholderText: label
                            text: Global.env.keepassSettings.defaultKeyTransfRounds
                            EnterKey.onClicked: parent.focus = true
                        }

                        SilicaLabel {
                            text: "Setting this value higher increases opening time of the Keepass database but makes it more robust against brute force attacks"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }
                    }

                    SectionHeader {
                        text: "UI Settings"
                    }

                    Slider {
                        id: inactivityLockTime
                        value: Global.env.keepassSettings.locktime
                        minimumValue: 0
                        maximumValue: 10
                        stepSize: 1
                        width: parent.width - Theme.paddingLarge * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        valueText: calculateInactivityTime(value)
                        label: "Inactivity Lock Time"
                        /*
                          0 = immediately
                          1 = 5 seconds
                          2 = 10 seconds
                          3 = 30 seconds
                          4 = 1 minute
                          5 = 2 minutes
                          6 = 5 minutes
                          7 = 10 minutes
                          8 = 30 minutes
                          9 = 60 minutes
                          10 = unlimited
                          */
                        function calculateInactivityTime(value) {
                            switch (value) {
                            case 0:
                                return "Immediately"
                            case 1:
                                return "5 Seconds"
                            case 2:
                                return "10 Seconds"
                            case 3:
                                return "30 Seconds"
                            case 4:
                                return "1 Minute"
                            case 5:
                                return "2 Minutes"
                            case 6:
                                return "5 Minutes"
                            case 7:
                                return "10 Minutes"
                            case 8:
                                return "30 Minutes"
                            case 9:
                                return "60 Minutes"
                            case 10:
                                return "Unlimited"
                            }
                        }
                    }

                    TextSwitch {
                        id: extendedListView
                        checked: Global.env.keepassSettings.showUserNamePasswordInListView
                        text: "Extended List View"
                        description: "If you switch this on username and password are shown below entry title in list views"
                    }
                }
            }

            onAccepted: {
                // first save locally database settings then trigger saving
                var defaultKeyFilePathTemp = ""
                if (useKeyFile.checked)
                    defaultKeyFilePathTemp = defaultKeyFilePath.text
                kdbListItemInternal.setKeepassSettings(defaultDatabaseFilePath.text,
                                            defaultKeyFilePathTemp,
                                            defaultEncryption.currentIndex,
                                            Number(defaultKeyTransfRounds.text),
                                            inactivityLockTime.value,
                                            extendedListView.checked)
                kdbListItemInternal.saveKeepassSettings()
            }

            onRejected: {
                // no need for saving if input field for master password is invalid
                if (canNavigateForward) {
                    // first save locally database settings then trigger check for unsaved changes
                    var defaultKeyFilePathTemp = ""
                    if (useKeyFile.checked)
                        defaultKeyFilePathTemp = defaultKeyFilePath.text
                    kdbListItemInternal.setKeepassSettings(defaultDatabaseFilePath.text,
                                                defaultKeyFilePathTemp,
                                                defaultEncryption.currentIndex,
                                                Number(defaultKeyTransfRounds.text),
                                                inactivityLockTime.value,
                                                extendedListView.checked)
                    kdbListItemInternal.checkForUnsavedKeepassSettingsChanges()
                }
            }
        }
    }

    Component {
        id: queryDialogForUnsavedChangesComponent
        QueryDialog {
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
    } // end queryForUnsavedChangesComponent

}


