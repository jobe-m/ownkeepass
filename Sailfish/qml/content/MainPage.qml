/***************************************************************************
**
** Copyright (C) 2013 - 2015 Marko Koschak (marko.koschak@tisno.de)
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
import "../components"
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

    // internal
    property string __unlockCharA: ""
    property string __unlockCharB: ""
    property string __unlockCharC: ""

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
        if (ownKeepassSettings.fastUnlock) {
            if (Global.enableDatabaseLock === true) {
                pageStack.push(Qt.resolvedUrl("LockPage.qml").toString(),
                               { "firstChar": __unlockCharA,
                                   "secondChar": __unlockCharB,
                                   "thirdChar": __unlockCharC,
                                   "mainPage": mainPage,
                                   "recoverCoverState": applicationWindow.cover.state })
                // Update cover page state
                applicationWindow.cover.title = ""
                applicationWindow.cover.state = "DATABASE_LOCKED"
                // Disable fast unlock because database is now locked already
                Global.enableDatabaseLock = false
            }
        } else {
            // No fast unlock: By going back to main page database will be closed
            pageStack.pop(mainPage)
        }
    }


    function clipboardTimerStart() {
        var timeToClearClipboard = Global.getClearClipboardTime(ownKeepassSettings.clearClipboard)
        if (timeToClearClipboard !== -1) {
            clipboardTimer.interval = timeToClearClipboard
            clipboardTimer.restart()
        }
    }

    allowedOrientations: applicationWindow.orientationSetting

    onOrientationChanged: {
        // Don't animate move of the view content if only orientation changes
        viewAnimation.enabled = false
    }

    Connections {
        target: ownKeepassHelper
        onShowErrorBanner: {
            var title = qsTr("Problem with SD card")
            var message = qsTr("SD cards with multiple partitions are not supported.")
            applicationWindow.infoPopup.show(Global.error, title, message)
        }
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

    Timer {
        id: clipboardTimer
        running: false
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            // delete clipboard content
            Clipboard.text = ""
        }
    }

    SilicaFlickable {
        id: mainPageFlickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator { }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable
        PullDownMenu {
            MenuItem {
                text: qsTr("Create new database")
                onClicked: {
                    pageStack.push(queryPasswordDialogComponent,
                                   {
                                       "state": "CreateNewDatabase",
                                       "dbFileLocation": 0,
                                       "dbFilePath": "",
                                       "useKeyFile": false,
                                       "keyFileLocation": 0,
                                       "keyFilePath": "",
                                       "password": ""
                                   })
                }
            }

            MenuItem {
                text: qsTr("Open database")
                onClicked: {
                    pageStack.push(queryPasswordDialogComponent,
                                   {
                                       "state": "OpenNewDatabase",
                                       "dbFileLocation": 0,
                                       "dbFilePath": "",
                                       "useKeyFile": false,
                                       "keyFileLocation": 0,
                                       "keyFilePath": "",
                                       "password": ""
                                   })
                }
            }
        }

        ApplicationMenu {
            helpContent: "MainPage"
        }

        Column {
            id: col
            width: parent.width
            spacing: 0

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: qsTr("Password Safe")
                subTitleOpacity: 0.5
                subTitleBottomMargin: mainPage.orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
            }

            Item {
                width: 1
                height: moreDetails.expanded ?
                            0 : (Screen.sizeCategory >= Screen.Large ?
                                     (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.195) : (Screen.height * 0.122)) :
                                     (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.081) : (Screen.height * 0.063))
                                 )

                Behavior on height {
                    id: viewAnimation
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                }
            }

            Image {
                enabled: mainPage.orientation & Orientation.PortraitMask
                visible: enabled
                // Make image size is dependent on screen size
                width: Screen.sizeCategory >= Screen.Large ? (Screen.width * 0.5) : (Screen.width * 0.91)
                height: width
                source: "../../wallicons/wall-ownKeys_" + (Screen.width > 540 ? "780x780" : "492x492") + ".png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: parent.width
                height: mainPage.orientation & Orientation.PortraitMask ?
                            passwordFieldCombo.height :
                            (passwordFieldCombo.height + (
                                 Screen.sizeCategory >= Screen.Large ? 3 * Theme.paddingLarge : Theme.paddingLarge
                                 ))

                Image {
                    id: smallImage
                    enabled: mainPage.orientation & Orientation.LandscapeMask
                    visible: enabled
                    width: mainPage.orientation & Orientation.PortraitMask ? 0 : height
                    height: Screen.sizeCategory >= Screen.Large ? (Screen.height * 0.24) : (Screen.height * 0.26)
                    source: "../../wallicons/wall-ownKeys_492x492.png"
                    anchors.left: parent.left
                    anchors.leftMargin: mainPage.orientation & Orientation.PortraitMask ? 0: Theme.horizontalPageMargin
                    anchors.bottom: parent.bottom
                }

                PasswordFieldCombo {
                    id: passwordFieldCombo
                    anchors.right: parent.right
                    anchors.left: smallImage.right
                    anchors.bottom: parent.bottom

                    onPasswordClicked: { // returns password
                        // open master groups page and load database in background
                        var masterGroupsPage = pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                                                              { "initOnPageConstruction": false, "groupId": "0" })
                        var createNewDatabase =  false
                        internal.openKeepassDatabase(password, createNewDatabase, masterGroupsPage)
                    }

                    onPasswordConfirmClicked: { // returns password
                        // open master groups page and load database in background
                        var masterGroupsPage = pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                                                              { "initOnPageConstruction": false, "groupId": "0" })
                        var createNewDatabase = true
                        internal.openKeepassDatabase(password, createNewDatabase, masterGroupsPage)
                    }
                }
            }

            MainPageMoreDetails {
                id: moreDetails
                onExpandedChanged: {
                    // Animate move of the view content if more details view expands
                    viewAnimation.enabled = true
                }
            }
        }

        state: "CREATE_NEW_DATABASE"
        states: [
            State {
                name: "CREATE_NEW_DATABASE"
                PropertyChanges {
                    target: passwordFieldCombo;
                    passwordDescriptionText: qsTr("Type in a master password for locking your new Keepass Password Safe:")
                    passwordErrorHighlightEnabled: true
                    passwordConfirmEnabled: true
                }
                PropertyChanges {
                    target: moreDetails
                    //: This is on the first page. The user has not yet created any Keepass databases. It gives the info where the new default database will be created.
                    databasePathAndNameText: qsTr("Path and name for new database") }
            },
            State {
                name: "OPEN_DATABASE"
                PropertyChanges {
                    target: passwordFieldCombo;
                    passwordDescriptionText: ""
                    passwordErrorHighlightEnabled: false
                    passwordConfirmEnabled: false
                }
                PropertyChanges {
                    target: moreDetails
                    //: This is on the first page where the user inputs the master password of his Keepass database.
                    databasePathAndNameText: qsTr("Path and name of database") }
            }
        ]
    }

    Connections {
        target: ownKeepassDatabase
        onDatabaseOpened: internal.databaseOpenedHandler(result, errorMsg)
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler()
        onDatabaseClosed: internal.databaseClosedHandler()
        onDatabasePasswordChanged: internal.databasePasswordChangedHandler()
        onErrorOccured: internal.errorHandler(result, errorMsg)
    }


    Connections {
        target: ownKeepassSettings
        onDatabaseDetailsLoaded: { // returns: databaseExists, ...
            if (databaseExists) {
                // Set database name in global object for pulley menu on query password page
                Global.activeDatabase = Global.getLocationName(dbLocation) + " " + dbFilePath
                mainPageFlickable.state = "OPEN_DATABASE"
                // set db location, path and keyfile stuff
                internal.setDatabaseInfo(dbLocation,
                                         dbFilePath,
                                         useKeyFile,
                                         keyFileLocation,
                                         keyFilePath,
                                         databaseType)
            } else {
                Global.activeDatabase = Global.getLocationName(1) + " Documents/ownkeepass/notes.kdb"
                mainPageFlickable.state = "CREATE_NEW_DATABASE"
                // set default db location, path, no keyfile and Keepass 1 as database type
                internal.setDatabaseInfo(1,
                                         "Documents/ownkeepass/notes.kdb",
                                         false,
                                         "",
                                         "",
                                         DatabaseType.DB_TYPE_KEEPASS_1)
            }
        }

        onRecentDatabaseRemoved: { // returns: result, uiName
            console.log("show Info Popup")
            if (result === DatabaseAccessResult.RE_OK) {
                // all fine
            } else {
                applicationWindow.infoPopup.show(Global.error, "Internal Error", "Something went wrong with dropping the database from the recent database list. That shouldn't happen. Please let me (the developer) know about that via email or at github. Thanks!")
            }
        }
    }

    Component.onCompleted: {
        // Init some global variables
        Global.env.setMainPage(mainPage)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // If this page gets active the database is definitely closed and needs to be opened again
            // so set cover page state accordingly
            applicationWindow.cover.title = ""
            applicationWindow.cover.state = "NO_DATABASE_OPENED"
            // disable fast unlock feature becase database is now closed anyway
            Global.enableDatabaseLock = false
            // Delete fast unlock code
            __unlockCharA = ""
            __unlockCharB = ""
            __unlockCharC = ""
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
        property int databaseType: ownKeepassDatabase.DB_TYPE_UNKNOWN
        property Page masterGroupsPage

        function init() {
            // make sure database is closed
            ownKeepassDatabase.close()
            // load settings into ownKeepassDatabase
            ownKeepassDatabase.showUserNamePasswordsInListView = ownKeepassSettings.showUserNamePasswordInListView
            ownKeepassDatabase.sortAlphabeticallyInListView = ownKeepassSettings.sortAlphabeticallyInListView
            // load details about most recently used database
            ownKeepassSettings.loadDatabaseDetails()
        }

        function setDatabaseInfo(dbFileLocation,
                                 dbFilePath,
                                 useKeyFile,
                                 keyFileLocation,
                                 keyFilePath,
                                 databaseType) {
            internal.dbFileLocation = dbFileLocation
            internal.databasePath =  dbFilePath
            internal.useKeyFile = useKeyFile
            internal.keyFileLocation = keyFileLocation
            internal.keyFilePath = keyFilePath
            internal.databaseType = databaseType
        }

        function openKeepassDatabase(password,
                                     createNewDatabase,
                                     acceptDestinationInstance) {
            // Save handler to masterGroups page, it is needed to init the view once the database
            // could be opened with given password and/or key file
            internal.masterGroupsPage = acceptDestinationInstance
            if (password === "") console.log("ERROR: Password is empty")

            if (ownKeepassSettings.fastUnlock) {
                if (password.length < 3) {
                    console.log("ERROR: Passwort too short for fast unlock!")
                } else {
                    // Extract fast unlock code from master password
                    __unlockCharA = password.charAt(0)
                    __unlockCharB = password.charAt(1)
                    __unlockCharC = password.charAt(2)
                }
            }

            // prepare database and key file
            var completeDbFilePath = ownKeepassHelper.getLocationRootPath(internal.dbFileLocation) + "/" + internal.databasePath
            var completeKeyFilePath
            if (internal.useKeyFile) {
                completeKeyFilePath = ownKeepassHelper.getLocationRootPath(internal.keyFileLocation) + "/" + internal.keyFilePath
            } else {
                completeKeyFilePath = ""
            }

            if (createNewDatabase) {
                // Check if database file already exists and if key file is present if it should be used
                if (!ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // Ok, now check if path to file exists if not create it
                        if (ownKeepassHelper.createFilePathIfNotExist(completeDbFilePath)) {
                            // set default values for encryption and key transformation rounds
                            ownKeepassDatabase.keyTransfRounds = ownKeepassSettings.defaultKeyTransfRounds
                            ownKeepassDatabase.cryptAlgorithm = ownKeepassSettings.defaultCryptAlgorithm
                            // create new Keepass database
                            ownKeepassDatabase.create(internal.databaseType, completeDbFilePath, completeKeyFilePath, password, true)
                            kdbListItemInternal.databaseKeyFile = completeKeyFilePath
                        } else {
                            // Path to new database file could not be created
                            applicationWindow.infoPopup.show(Global.error, qsTr("Permission error"), qsTr("Cannot create path for your Keepass database file. You may need to set directory permissions for user \'nemo\'."))
                            masterGroupsPage.closeOnError()
                        }
                    } else {
                        // Key file should be used but does not exist
                        applicationWindow.infoPopup.show(Global.warning, qsTr("Key file error"), qsTr("Database path is ok, but your key file is not present. Please check path to key file:") + " " + completeKeyFilePath)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file already exists
                    applicationWindow.infoPopup.show(Global.info, qsTr("Database file already exists"), qsTr("Please specify another path and name for your Keepass database or delete the old database within a file browser."))
                    masterGroupsPage.closeOnError()
                }
            } else {
                // Check if database exists and if key file exists in case it should be used
                if (ownKeepassHelper.fileExists(completeDbFilePath)) {
                    if (!useKeyFile || ownKeepassHelper.fileExists(completeKeyFilePath)) {
                        // open existing Keepass database
                        ownKeepassDatabase.open(internal.databaseType, completeDbFilePath, completeKeyFilePath, password, false)
                        kdbListItemInternal.databaseKeyFile = completeKeyFilePath
                    } else {
                        // Key file should be used but does not exist
                        applicationWindow.infoPopup.show(Global.warning, qsTr("Key file error"), qsTr("Database path is ok, but your key file is not present. Please check path to key file:") + " " + completeKeyFilePath)
                        masterGroupsPage.closeOnError()
                    }
                } else {
                    // Database file does not exist
                    applicationWindow.infoPopup.show(Global.warning, qsTr("Database file error"), qsTr("Database file does not exist. Please check path to database file:") + " " + completeDbFilePath)
                    masterGroupsPage.closeOnError()
                }
            }
        }

        function updateRecentDatabaseListModel() {
            // update recent database list
            var uiName = internal.databasePath.substring(internal.databasePath.lastIndexOf("/") + 1, internal.databasePath.length)
            var uiPath = internal.databasePath.substring(0, internal.databasePath.lastIndexOf("/") + 1)
            ownKeepassSettings.addRecentDatabase(uiName,
                                                 uiPath,
                                                 internal.dbFileLocation,
                                                 internal.databasePath,
                                                 internal.useKeyFile,
                                                 internal.keyFileLocation,
                                                 internal.keyFilePath,
                                                 internal.databaseType)
            // Set database name in global object for pulley menu on groups and entries pages
            Global.activeDatabase = Global.getLocationName(dbFileLocation) + " " + databasePath
            // Get database name and set on cover page for create new and open database states
            applicationWindow.cover.title = databasePath.substring(
                        databasePath.lastIndexOf("/") + 1, databasePath.length)
        }

        function databaseOpenedHandler(result, errorMsg) {
            // display popup if some error occured
            switch (result) {
            case DatabaseAccessResult.RE_DB_READ_ONLY:
                // Database opened successfully in read only mode, now init master groups page and cover page
                Global.enableDatabaseLock = true
                masterGroupsPage.init()
                updateRecentDatabaseListModel()
                break
            case DatabaseAccessResult.RE_OK:
                // Yeah, database opened successfully, now init master groups page and cover page
                Global.enableDatabaseLock = true
                masterGroupsPage.init()
                updateRecentDatabaseListModel()
                break
            case DatabaseAccessResult.RE_NOT_A_KEEPASS_DB:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Database file"),
                                          qsTr("The specified file is not a Keepass database."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_NOT_SUPPORTED_DB_VERSION:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Database version"),
                                          qsTr("The specified file has an unsupported Keepass database version."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_MISSING_DB_HEADERS:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Internal database error"),
                                          qsTr("Database headers are missing."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_WRONG_PASSWORD_OR_DB_IS_CORRUPT:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Wrong password"),
                                          qsTr("Either your master password is wrong or the database file is corrupt. Please try again."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_WRONG_PASSWORD_OR_KEYFILE_OR_DB_IS_CORRUPT:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Wrong password"),
                                          qsTr("Either your master password is wrong or your key file is wrong. Please try again. If the error persists then either key file or database file is corrupt."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_HEAD_HASH_MISMATCH:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("Internal database error"),
                                          qsTr("Database head doesn't match corresponding hash value."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DBFILE_OPEN_ERROR:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("File I/O error"),
                                          qsTr("Cannot open database file. Error details:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_KEYFILE_OPEN_ERROR:
                applicationWindow.infoPopup.show(Global.error,
                                          qsTr("File I/O error"),
                                          qsTr("Cannot open key file. Error details:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            default:
                applicationWindow.infoPopup.show(Global.error,
                                          "Unknown error code",
                                          "Error code " + result + " appeared after database was opened.")
                masterGroupsPage.closeOnError()
                break
            }
        }

        function newDatabaseCreatedHandler() {
            // Yeah, database created successfully, now init master groups page and cover page
            Global.enableDatabaseLock = true
            masterGroupsPage.init()
            updateRecentDatabaseListModel()
        }

        function databaseClosedHandler() {
            // disable fast unlock feature becase database is now closed anyway
            Global.enableDatabaseLock = false
            // Delete fast unlock code
            __unlockCharA = ""
            __unlockCharB = ""
            __unlockCharC = ""
        }

        function databasePasswordChangedHandler() {
            applicationWindow.infoPopup.show(Global.info, qsTr("Password changed"), qsTr("The master password of your database was changed successfully."), 3)
        }

        function errorHandler(result, errorMsg) {
            // show error to the user
            switch (result) {
            case DatabaseAccessResult.RE_DB_CLOSE_FAILED:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal database error"), qsTr("Could not close the previous opened database. Please try again. Error message:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_SETKEY_ERROR:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal key error"), qsTr("The following error occured during opening of database:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_SETKEYFILE_ERROR:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal key file error"), qsTr("The following error occured during opening of database:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_LOAD_ERROR:
                applicationWindow.infoPopup.show(Global.warning, qsTr("Error loading database"), errorMsg + " " + qsTr("Please try again."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_FILE_ERROR:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal file error"), qsTr("The following error occured during creation of database:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_CREATE_BACKUPGROUP_ERROR:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal database error"), qsTr("Creation of backup group failed with following error:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_SAVE_ERROR:
                applicationWindow.infoPopup.show(Global.error, qsTr("Save database error"), qsTr("Could not save database with following error:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_DB_ALREADY_CLOSED:
                console.log("Database was already closed. Nothing serious.")
                break
            case DatabaseAccessResult.RE_DB_CLOSE_FAILED:
                applicationWindow.infoPopup.show(Global.error, qsTr("Database error"), qsTr("An error occured on closing your database:") + " " + errorMsg)
                masterGroupsPage.closeOnError()
                break
            // here start new and reviewed error codes
            case DatabaseAccessResult.RE_CRYPTO_INIT_ERROR:
                // cryptographic algorithms could not be initialized successfully, abort opening of any Keepass database for safety (Keepass 2 only)
                applicationWindow.infoPopup.show(Global.error, qsTr("Crypto init error"),
                                          qsTr("Cryptographic algorithms could not be initialized successfully. The database is closed again to prevent any attack. Please try to reopen the app. If the error persists please contact the developer."))
                masterGroupsPage.closeOnError()
                break
            case DatabaseAccessResult.RE_ERR_QSTRING_TO_INT:
                applicationWindow.infoPopup.show(Global.error, qsTr("Internal database error"),
                                          qsTr("Conversion of QString \"%1\" to Int failed").arg(errorMsg))
                break
            default:
                console.log("ERROR: unknown result on database error occured: " + result)
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
          did not understand the whole UI paradigma at all... well recently the UX evolved quite nicely;)
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
        property int    originalGroupIconId: -1
        property string originalGroupCustomIconUuid: ""
        property string groupName: ""
        property int    groupIconId: -1
        property string groupCustomIconUuid: ""

        /*
          Data used to save database setting values in ownKeepassDatabase object
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
        property bool sortAlphabeticallyInListView
        property bool showUserNamePasswordInListView
        property bool focusSearchBarOnStartup
        property bool showUserNamePasswordOnCover
        property bool lockDatabaseFromCover
        property bool copyNpasteFromCover
        property int clearClipboard
        property int language
        property bool fastUnlock
        property int fastUnlockRetryCount
        property int uiOrientation

        /*
          Commonly used for manipulation and creation of entries and groups
          */
        property bool createNewItem: false
        property string itemId: ""
        property string parentGroupId: ""

        function saveKdbGroupDetails() {
            // Set group ID and create or save Kdb Group
            kdbGroup.groupId = itemId
            if (createNewItem) {
                // create new group in database, save and update list model data in backend
                kdbGroup.createNewGroup(groupName,
                                        parentGroupId,
                                        groupIconId,
                                        groupCustomIconUuid)
            } else {
                // save changes of existing group to database and update list model data in backend
                kdbGroup.saveGroupData(groupName,
                                       groupIconId,
                                       groupCustomIconUuid)
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
            if (originalGroupName !== groupName ||
                    originalGroupIconId !== groupIconId ||
                    originalGroupCustomIconUuid !== groupCustomIconUuid) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "state": "QUERY_FOR_GROUP" })
            }
        }

        function loadKdbEntryDetails(keys, values) {
            entryTitle    = originalEntryTitle    = values[0]
            entryUrl      = originalEntryUrl      = values[1]
            entryUsername = originalEntryUsername = values[2]
            entryPassword = originalEntryPassword = values[3]
            entryComment  = originalEntryComment  = values[4]

            // Populate entry detail text fields in editEntryDetailsDialog or showEntryDetailsPage
            // depending on which is currently active
            if(editEntryDetailsDialogRef)
                editEntryDetailsDialogRef.setTextFields(keys, values)
            if(showEntryDetailsPageRef)
                showEntryDetailsPageRef.setTextFields(keys, values)
        }

        function loadKdbGroupDetails(name, iconId, customIconUuid) {
            groupName = originalGroupName = name
            // Populate group detail text fields in editGroupDetailsDialog
            if(editGroupDetailsDialogRef)
                editGroupDetailsDialogRef.setTextFields(name, iconId, customIconUuid)
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

        function setKdbGroupDetails(createNewGroup, groupId, parentGrId, name, iconId, customIconUuid) {
            createNewItem       = createNewGroup
            itemId              = groupId
            parentGroupId       = parentGrId
            groupName           = name
            groupIconId         = iconId
            groupCustomIconUuid = customIconUuid
        }

        function setDatabaseSettings(masterPassword, cryptAlgorithm, keyTransfRounds) {
            databaseMasterPassword  = masterPassword
            databaseCryptAlgorithm  = cryptAlgorithm
            databaseKeyTransfRounds = keyTransfRounds
        }

        function checkForUnsavedDatabaseSettingsChanges() {
            // check if user gave a new master password or if encryption type or key transformation rounds have changed
            if (databaseMasterPassword !== "" ||
                    databaseCryptAlgorithm !== ownKeepassDatabase.cryptAlgorithm ||
                    databaseKeyTransfRounds !== ownKeepassDatabase.keyTransfRounds) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "state": "QUERY_FOR_DATABASE_SETTINGS" })
            }
        }

        function saveDatabaseSettings() {
            if (databaseMasterPassword !== "") {
                ownKeepassDatabase.changePassword(databaseMasterPassword, databaseKeyFile)
                if (databaseMasterPassword.length < 3) {
                    console.log("ERROR: Passwort too short for fast unlock!")
                } else {
                    // Extract fast unlock code from master password
                    __unlockCharA = databaseMasterPassword.charAt(0)
                    __unlockCharB = databaseMasterPassword.charAt(1)
                    __unlockCharC = databaseMasterPassword.charAt(2)
                }
                databaseMasterPassword = ""
            }
            if (databaseCryptAlgorithm !== ownKeepassDatabase.cryptAlgorithm) {
                ownKeepassDatabase.cryptAlgorithm = databaseCryptAlgorithm
            }
            if (databaseKeyTransfRounds !== ownKeepassDatabase.keyTransfRounds) {
                ownKeepassDatabase.keyTransfRounds = databaseKeyTransfRounds
            }
        }

        function setKeepassSettings(aDefaultCryptAlgorithm, aDefaultKeyTransfRounds, aInactivityLockTime,
                                    aSortAlphabeticallyInListView,
                                    aShowUserNamePasswordInListView, aFocusSearchBarOnStartup, aShowUserNamePasswordOnCover,
                                    aLockDatabaseFromCover, aCopyNpasteFromCover, aClearClipboard, aLanguage,
                                    aFastUnlock, aFastUnlockRetryCount, aOrientation) {
            defaultCryptAlgorithm = aDefaultCryptAlgorithm
            defaultKeyTransfRounds = aDefaultKeyTransfRounds
            inactivityLockTime = aInactivityLockTime
            sortAlphabeticallyInListView = aSortAlphabeticallyInListView
            showUserNamePasswordInListView = aShowUserNamePasswordInListView
            focusSearchBarOnStartup = aFocusSearchBarOnStartup
            showUserNamePasswordOnCover = aShowUserNamePasswordOnCover
            lockDatabaseFromCover = aLockDatabaseFromCover
            copyNpasteFromCover = aCopyNpasteFromCover
            clearClipboard = aClearClipboard
            language = aLanguage
            fastUnlock = aFastUnlock
            fastUnlockRetryCount = aFastUnlockRetryCount
            uiOrientation = aOrientation
        }

        function checkForUnsavedKeepassSettingsChanges() {
            if (
                    ownKeepassSettings.defaultCryptAlgorithm !== defaultCryptAlgorithm ||
                    ownKeepassSettings.defaultKeyTransfRounds !== defaultKeyTransfRounds ||
                    ownKeepassSettings.locktime !== inactivityLockTime ||
                    ownKeepassSettings.sortAlphabeticallyInListView !== sortAlphabeticallyInListView ||
                    ownKeepassSettings.showUserNamePasswordInListView !== showUserNamePasswordInListView ||
                    ownKeepassSettings.focusSearchBarOnStartup !== focusSearchBarOnStartup ||
                    ownKeepassSettings.showUserNamePasswordOnCover !== showUserNamePasswordOnCover ||
                    ownKeepassSettings.lockDatabaseFromCover !== lockDatabaseFromCover ||
                    ownKeepassSettings.copyNpasteFromCover !== copyNpasteFromCover ||
                    ownKeepassSettings.clearClipboard !== clearClipboard ||
                    ownKeepassSettings.language !== language ||
                    ownKeepassSettings.fastUnlock !== fastUnlock ||
                    ownKeepassSettings.fastUnlockRetryCount !== fastUnlockRetryCount ||
                    ownKeepassSettings.uiOrientation !== uiOrientation) {
                pageStack.replace(queryDialogForUnsavedChangesComponent,
                                  { "state": "QUERY_FOR_APP_SETTINGS"})
            }
        }

        function saveKeepassSettings() {
            ownKeepassSettings.defaultCryptAlgorithm = defaultCryptAlgorithm
            ownKeepassSettings.defaultKeyTransfRounds = defaultKeyTransfRounds
            ownKeepassSettings.locktime = inactivityLockTime
            ownKeepassSettings.sortAlphabeticallyInListView = sortAlphabeticallyInListView
            ownKeepassSettings.showUserNamePasswordInListView = showUserNamePasswordInListView
            ownKeepassSettings.focusSearchBarOnStartup = focusSearchBarOnStartup
            ownKeepassSettings.showUserNamePasswordOnCover = showUserNamePasswordOnCover
            ownKeepassSettings.lockDatabaseFromCover = lockDatabaseFromCover
            ownKeepassSettings.copyNpasteFromCover = copyNpasteFromCover
            ownKeepassSettings.clearClipboard = clearClipboard
            ownKeepassSettings.language = language
            ownKeepassSettings.fastUnlock = fastUnlock
            ownKeepassSettings.fastUnlockRetryCount = fastUnlockRetryCount
            ownKeepassSettings.uiOrientation = uiOrientation
        }
    }

    KdbGroup {
        id: kdbGroup
        onGroupDataLoaded: kdbListItemInternal.loadKdbGroupDetails(title, iconId, customIconUuid)
        onGroupDataSaved: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
        onNewGroupCreated: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntry
        onEntryDataLoaded: kdbListItemInternal.loadKdbEntryDetails(keys, values)
        onEntryDataSaved: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
        onNewEntryCreated: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
    }


    // We need separate objects for deletion because of the 5 seconds guard period where
    // the user can undo the delete operation, i.e. the deletion is delayed and the user
    // might open another item which would then be deleted if we don't use separate
    // objects here
    KdbGroup {
        id: kdbGroupForDeletion
        onGroupDeleted: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntryForDeletion
        onEntryDeleted: if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntryToMove
        onEntryMoved: {
            if (result === DatabaseAccessResult.RE_DB_SAVE_ERROR) __showSaveErrorPage()
        }
    }

    Component {
        id: queryPasswordDialogComponent
        QueryPasswordDialog {
            onAccepted: {
                internal.setDatabaseInfo(dbFileLocation,
                                         dbFilePath,
                                         useKeyFile,
                                         keyFileLocation,
                                         keyFilePath,
                                         databaseType)
                internal.openKeepassDatabase(password,
                                             state === "CreateNewDatabase",
                                             acceptDestinationInstance)
            }
        }
    }

    Component {
        id: recentDatabaseListItemComponent
        ListItem {
            id: recentDatabaseListItem

            contentHeight: Theme.itemSizeMedium // two line delegate
            menu: contextMenuComponent
            width: Screen.width

            function dropFromList() {
                remorseAction("Drop Database from List",
                              function() {
                                  ownKeepassSettings.removeRecentDatabase(model.uiName, model.databaseLocation, model.databaseFilePath)
                              })
            }
            function deleteDatabase() {
                remorseAction("Delete Database",
                              function() {
                                  // save that we delete also database from filesystem
// TODO
//                                  ownKeepassSettings.removeRecentDatabase(model.uiName, model.databaseLocation, model.databaseFilePath)
                              })
            }

            ListView.onAdd: AddAnimation {
                target: recentDatabaseListItem
            }
            ListView.onRemove: RemoveAnimation {
                target: recentDatabaseListItem
            }

            Column {
                width: parent.width
                height: children.height
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingSmall

                Label {
                    id: firstLabel
                    x: Theme.horizontalPageMargin
                    width: parent.width - Theme.horizontalPageMargin * 2
                    horizontalAlignment: Text.AlignLeft
                    text: model.uiName
                    font.pixelSize: Theme.fontSizeMedium
                    color: recentDatabaseListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    id: secondLabel
                    x: Theme.horizontalPageMargin
                    width: parent.width - Theme.horizontalPageMargin * 2
                    horizontalAlignment: Text.AlignLeft
                    text: Global.getLocationName(model.databaseLocation) + " " + model.uiPath
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: recentDatabaseListItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                }
            }

            onClicked: {
                // Set database name in global object for pulley menu on query password page
                Global.activeDatabase = Global.getLocationName(model.databaseLocation) + " " + model.databaseFilePath
                pageStack.push(queryPasswordDialogComponent,
                               { "state": "OpenRecentDatabase",
                                 "dbFileLocation": model.databaseLocation,
                                 "dbFilePath": model.databaseFilePath,
                                 "useKeyFile": model.useKeyFile,
                                 "keyFileLocation": model.keyFileLocation,
                                 "keyFilePath": model.keyFilePath,
                                 "databaseType": model.databaseType,
                                 "password": "" })
            }

            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: contextMenu

                    MenuItem {
                        text: qsTr("Drop from List")
                        onClicked: {
                            recentDatabaseListItem.dropFromList()
                        }
                    }

// TODO
//                    MenuItem {
//                        text: qsTr("Delete Database")
//                        onClicked: {
//                            recentDatabaseListItem.deleteDatabase()
//                        }
//                    }
                }
            } // end contextMenuComponent
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
            headerAcceptText: qsTr("Yes")
            headerCancelText: qsTr("No")
            headerTitleText: qsTr("Unsaved changes")
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
                    console.log("ERROR: unknown query for unsaved changes")
                    break
                }
            }

            state: "QUERY_FOR_ENTRY"
            states: [
                State {
                    name: "QUERY_FOR_ENTRY"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: qsTr("Do you want to save changes to the password entry?") }
                },
                State {
                    name: "QUERY_FOR_GROUP"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: qsTr("Do you want to save changes to the password group?") }
                },
                State {
                    name: "QUERY_FOR_DATABASE_SETTINGS"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: qsTr("Do you want to save changes to database settings?") }
                },
                State {
                    name: "QUERY_FOR_APP_SETTINGS"
                    PropertyChanges { target: queryDialogForUnsavedChanges
                        message: qsTr("Do you want to save changed settings values?") }
                }
            ]
        }
    }

}
