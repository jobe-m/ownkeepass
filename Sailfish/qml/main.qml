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
    property MainPageSimple mainPageRef: null

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
        MainPageSimple {
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
        // here are default values set if the settings were not yet saved in the SQLite database
        property bool simpleMode: true
        // If (simpleMode === true) this just opens the query password dialog
        // Later (in non simple mode) this will open the database out of recently opened databases where the user has ckecked "Open per default"
        property bool loadDefault: false
        // default database and key file paths used in simple mode to create one database easily
        property string defaultDatabasePath: jollaPhoneDocumentsPath + "/ownkeepass/notes.kdb"
        property string defaultKeyFilePath: ""
        property int defaultCryptAlgorithm: 0  // Default encryption: AES/Rijndael = 0, Twofish = 1
        property int defaultKeyTransfRounds: 50000
        property int locktime: 3  // min = 0, max = 10, default = 3
        property bool showUserNamePasswordInListView: false  // default = false
        property bool showUserNamePasswordOnCover: true
        property bool lockDatabaseFromCover: true
        property bool copyNpasteFromCover: true

        Component.onCompleted: {
            console.log("Predefined locations: " + jollaPhoneDocumentsPath + " " + sdCardPath + " " + androidStoragePath)
            Global.env.setKeepassSettings(keepassSettings)
            initDatabase()
            loadSettings()
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
          This function is used to write a setting into the database.
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
            // when during loading of settings the values are "unknown" then that means
            // that the setting is not yet saved so save just default value
            var value = getSetting("simpleMode")
            simpleMode = value !== "UNKNOWN" ? (value === "true" ? true : false) : simpleMode
            value = getSetting("loadDefault")
            loadDefault = value !== "UNKNOWN" ? (value === "true" ? true : false) : loadDefault
            value = getSetting("defaultDatabasePath")
            defaultDatabasePath = value !== "UNKNOWN" ? value : defaultDatabasePath
            value = getSetting("defaultKeyFilePath")
            defaultKeyFilePath = value !== "UNKNOWN" ? value : defaultKeyFilePath
            value = getSetting("defaultCryptAlgorithm")
            defaultCryptAlgorithm = value !== "UNKNOWN" ? Number(value) : defaultCryptAlgorithm
            value = getSetting("defaultKeyTransfRounds")
            defaultKeyTransfRounds = value !== "UNKNOWN" ? Number(value) : defaultKeyTransfRounds
            value = getSetting("locktime")
            locktime = value !== "UNKNOWN" ? Number(value) : locktime
            value = getSetting("showUserNamePasswordInListView")
            showUserNamePasswordInListView = value !== "UNKNOWN" ? (value === "true" ? true : false) : showUserNamePasswordInListView
            value = getSetting("showUserNamePasswordOnCover")
            showUserNamePasswordOnCover = value !== "UNKNOWN" ? (value === "true" ? true : false) : showUserNamePasswordOnCover
            value = getSetting("lockDatabaseFromCover")
            lockDatabaseFromCover = value !== "UNKNOWN" ? (value === "true" ? true : false) : lockDatabaseFromCover
            value = getSetting("copyNpasteFromCover")
            copyNpasteFromCover = value !== "UNKNOWN" ? (value === "true" ? true : false) : copyNpasteFromCover
        }

        function saveSettings() {
            // save settings as strings in SQL database
            setSetting("simpleMode", simpleMode ? "true" : "false")
            setSetting("loadDefault", loadDefault ? "true" : "false")
            setSetting("defaultDatabasePath", defaultDatabasePath)
            setSetting("defaultKeyFilePath", defaultKeyFilePath)
            setSetting("defaultCryptAlgorithm", String(defaultCryptAlgorithm))
            setSetting("defaultKeyTransfRounds", String(defaultKeyTransfRounds))
            setSetting("locktime", String(locktime))
            setSetting("showUserNamePasswordInListView", showUserNamePasswordInListView ? "true": "false")
            setSetting("showUserNamePasswordOnCover", showUserNamePasswordOnCover ? "true": "false")
            setSetting("lockDatabaseFromCover", lockDatabaseFromCover ? "true": "false")
            setSetting("copyNpasteFromCover", copyNpasteFromCover ? "true": "false")
        }
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


