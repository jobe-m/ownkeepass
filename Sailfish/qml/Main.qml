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
import QtQuick.LocalStorage 2.0
import "content"
import "cover"
import "common"
import "scripts/Global.js" as Global

ApplicationWindow
{
    id: applicationWindow

    // For accessing main page to pass further application activity status
    property MainPage mainPageRef: null

    initialPage: mainPageContainer
    cover: coverPage

    // Place info popup outside of page stack so that it is shown over all
    // application UI elements
    InfoPopup {
        id: infoPopup
        Component.onCompleted: {
            Global.env.setInfoPopup(infoPopup)
        }
    }

    Component {
        id: mainPageContainer
        MainPage {
            id: mainPage
            Component.onCompleted: mainPageRef = mainPage
        }
    }

    CoverPage {
        id: coverPage
        keepassSettings: keepassSettings
        onLockDatabase: mainPageRef.lockDatabase()
    }

    QtObject {
        id: keepassSettings
        // here are default values set if the settings were not yet saved in Local Storage SQLite database

        // Settings version
        // This is used to check if settings from some older ownKeepass version are available
        // If yes they might need to be merged into new version
        property string previousVersion: ""
        property string version: "0.9.5"
        // Default encryption: AES/Rijndael = 0, Twofish = 1
        property int defaultCryptAlgorithm: 0
        property int defaultKeyTransfRounds: 50000
        property int locktime: 3  // min = 0, max = 10, default = 3
        property bool showUserNamePasswordInListView: false
        property bool showUserNamePasswordOnCover: true
        property bool lockDatabaseFromCover: true
        property bool copyNpasteFromCover: true

        // Load as default
        // false: do not auto load last opened database
        // true: load last database on startup automatically
        property bool loadLastDb: false

// TODO this is not needed as the array from Global.config will be directly saved to settings.ini file
        // recent list of opened databases
//        property string dbFileLocation: "0"
//        property string dbFilePath: ""
//        property string usekeyFile: "false"
//        property string keyFileLocation: "0"
//        property string keyFilePath: ""


        Component.onCompleted: {
            Global.env.setKeepassSettings(keepassSettings)
//            initDatabase()
            loadSettings()
            loadRecentDatabases()
        }

        // convert locktime setting into amount of microseconds and return it
        function getInactivityTime()
        {
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
                // set unlimited value just more than 60 minutes
                interval = Global.constants._60minutes + 100
            }
            return interval
        }


//        // Initialize tables we need if they haven't been created yet
//        function initDatabase() {
//            var db = getDatabase();
//            db.transaction(function(tx) {
//                // Create the settings table if it doesn't already exist
//                // If the table exists, this is skipped
//                tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
//            })
//        }

//        // for internal use
//        function getDatabase() {
//             return LocalStorage.openDatabaseSync("ownKeepassSettings", "1.0", "Application settings for ownKeepass", 100000);
//        }

        /*
          This function is used to retrieve a setting from settings.ini file
          The function returns default value if the setting was not found
          */
        function getSetting(setting, defaultValue) {
            return settings.getValue("main/" + setting, defaultValue);
        }

        /*
          This function is used to write a setting into settings.ini file
          setting: string representing the setting name
          value: string representing the value of the setting
          */
        function setSetting(setting, value) {
            settings.setValue("main/" + setting, value);
        }

        function loadRecentDatabases() {
            loadLastDb = getSetting("loadLastDb", loadLastDb)
// TODO save arrays from Global.config

//            dbFileLocation = getSetting("dbFileLocation", dbFileLocation)
//            dbFilePath = getSetting("dbFilePath", dbFilePath)
//            usekeyFile = getSetting("usekeyFile", usekeyFile)
//            keyFileLocation = getSetting("keyFileLocation", keyFileLocation)
//            keyFilePath = getSetting("keyFilePath", keyFilePath)
        }

        function saveRecentDatabases() {
            setSetting("loadLastDb", loadLastDb ? "true": "false")
// TODO load arrays into Global.config

//            setSetting("dbFileLocation", dbFileLocation)
//            setSetting("dbFilePath", dbFilePath)
//            setSetting("usekeyFile", usekeyFile)
//            setSetting("keyFileLocation", keyFileLocation)
//            setSetting("keyFilePath", keyFilePath)
        }

        function loadSettings() {
            // when during loading of settings the values are "unknown" then that means
            // that the setting is not yet saved so save just default value
            var value
            version =  getSetting("version", version)
            defaultCryptAlgorithm = getSetting("defaultCryptAlgorithm", defaultCryptAlgorithm)
            defaultKeyTransfRounds = getSetting("defaultKeyTransfRounds", defaultKeyTransfRounds)
            locktime = getSetting("locktime", locktime)
            showUserNamePasswordInListView = getSetting("showUserNamePasswordInListView", showUserNamePasswordInListView)
            showUserNamePasswordOnCover = getSetting("showUserNamePasswordOnCover", showUserNamePasswordOnCover)
            lockDatabaseFromCover = getSetting("lockDatabaseFromCover", lockDatabaseFromCover)
            copyNpasteFromCover = getSetting("copyNpasteFromCover", copyNpasteFromCover)
        }

        function saveSettings() {
            // save settings as strings in SQL database
            setSetting("version", version)
            setSetting("defaultCryptAlgorithm", String(defaultCryptAlgorithm))
            setSetting("defaultKeyTransfRounds", String(defaultKeyTransfRounds))
            setSetting("locktime", String(locktime))
            setSetting("showUserNamePasswordInListView", showUserNamePasswordInListView ? "true": "false")
            setSetting("showUserNamePasswordOnCover", showUserNamePasswordOnCover ? "true": "false")
            setSetting("lockDatabaseFromCover", lockDatabaseFromCover ? "true": "false")
            setSetting("copyNpasteFromCover", copyNpasteFromCover ? "true": "false")
        }
    }

    Component.onCompleted: {
        // Init recent database file list
        Global.config.initArrays()
    }

    onApplicationActiveChanged: {
        // Application goes into background or returns to active focus again
        if (applicationActive) {
            mainPageRef.inactivityTimerStop()
        } else {
            mainPageRef.inactivityTimerStart()
        }
    }
}


