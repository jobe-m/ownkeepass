.pragma library

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

// enable (1) / disable (0) development mode
// This sets some paths for SDK usage (/opt/sdk/...) and a default database password for testing
var developmentMode = 0

var constants = {
    _1microsecond: 1,
    _5seconds: 5 * 1000,
    _10seconds: 10 * 1000,
    _30seconds: 30 * 1000,
    _1minute: 60 * 1000,
    _2minutes: 2 * 60 * 1000,
    _5minutes: 5 * 60 * 1000,
    _10minutes: 10 * 60 * 1000,
    _30minutes: 30 * 60 * 1000,
    _60minutes: 60 * 60 * 1000,

    // For cover page handling
    databaseClosed: 0,
    databaseOpened: 1,
    databaseEntryOpened: 2,
    databaseUnsavedChanges: 3,

    // For clipboard handling
    clipboardUnused: 0,
    clipboardUsernameDropped: 1,
    clipboardPasswordDropped: 2
}

var env = {
    mainPage: undefined,
    kdbDatabase: undefined,
    infoPopup: undefined,
    keepassSettings: undefined,

    setMainPage: function(obj) {
        this.mainPage = obj
    },

    setKdbDatabase: function(obj) {
        this.kdbDatabase = obj
    },

    setInfoPopup: function(obj) {
        this.infoPopup = obj
    },

    setKeepassSettings: function(obj) {
        this.keepassSettings = obj
    }
}

// convert locktime setting into amount of microseconds and return it
function getInactivityTime(value)
{
    var interval
    switch (value) {
    case 0:
        interval = constants._1microsecond
        break
    case 1:
        interval = constants._5seconds
        break
    case 2:
        interval = constants._10seconds
        break
    case 3:
        interval = constants._30seconds
        break
    case 4:
        interval = constants._1minute
        break
    case 5:
        interval = constants._2minutes
        break
    case 6:
        interval = constants._5minutes
        break
    case 7:
        interval = constants._10minutes
        break
    case 8:
        interval = constants._30minutes
        break
    case 9:
        interval = constants._60minutes
        break
    case 10:
        // set unlimited value just more than 60 minutes
        interval = constants._60minutes + 100
    }
    return interval
}

var config = {
    // user preferences
    maxNumberOfRecents: 5,

    // Array objects holding recent opened keepass databases.
    // The full path to the database and keyfile must be set.
    // Every database entry has a keyfile entry. If no keyfile exists for a database
    // the keyfile entry must be an empty string "".
    recentDbNamesUI: undefined,
    recentDbPathsUI: undefined,
    recentDbLocations: undefined,
    recentDbFilePaths: undefined,
    recentUseKeyFiles: undefined,
    recentKeyFileLocations: undefined,
    recentKeyFilePaths: undefined,

    // initialize arrays
    initArrays: function() {
        this.recentDbNamesUI = []
        this.recentDbPathsUI = []
        this.recentDbLocations = []
        this.recentDbFilePaths = []
        this.recentUseKeyFiles = []
        this.recentKeyFileLocations = []
        this.recentKeyFilePaths = []
    },

    // return amount of recently opened database
    getNumberOfRecents: function() {
        if (this.recentDbNamesUI === undefined) {
            this.initArrays()
        }
        // check if all lengths are equal otherwise clean everything up
        var length = this.recentDbNamesUI.length
        if (
                (this.recentDbPathsUI.length === length) &&
                (this.recentDbLocations.length === length ) &&
                (this.recentDbFilePaths.length === length) &&
                (this.recentUseKeyFiles.length === length) &&
                (this.recentKeyFileLocations.length === length ) &&
                (this.recentKeyFilePaths.length === length))
        {
            return length
        } else {
            this.initArrays()
            return 0
        }
    },

    deleteDbFromRecentList: function(index) {
        if (index >= this.getNumberOfRecents()) {
            this.recentDbNamesUI.splice(index, 1)
            this.recentDbPathsUI.splice(index, 1)
            this.recentDbLocations.splice(index, 1)
            this.recentDbFilePaths.splice(index, 1)
            this.recentUseKeyFiles.splice(index, 1)
            this.recentKeyFileLocations.splice(index, 1)
            this.recentKeyFilePaths.splice(index, 1)
        }
    },

    //
    addNewRecent: function(databaseLocation, database, useKeyFile, keyFileLocation, keyFile) {
        // check if input is valid
        if (database === undefined) {
            console.log("Database undefined in addNewRecent()")
            return false
        }
        if (keyFile === undefined) {
            keyFile = "/"
        }
        // check if new database is already in the recent list and remove it before adding
        var index = this.recentDbFilePaths.indexOf(database)
        if (index !== -1) {
            this.recentDbNamesUI.splice(index, 1)
            this.recentDbPathsUI.splice(index, 1)
            this.recentDbLocations.splice(index, 1)
            this.recentDbFilePaths.splice(index, 1)
            this.recentUseKeyFiles.splice(index, 1)
            this.recentKeyFileLocations.splice(index, 1)
            this.recentKeyFilePaths.splice(index, 1)
        }
        // check if more than max recent entries are already in the list and remove the oldest
        while (this.getNumberOfRecents() >= this.maxNumberOfRecents) {
            this.recentDbNamesUI.pop()
            this.recentDbPathsUI.pop()
            this.recentDbLocations.pop()
            this.recentDbFilePaths.pop()
            this.recentUseKeyFiles.pop()
            this.recentKeyFileLocations.pop()
            this.recentKeyFilePaths.pop()
        }
        // cut name and path from database file path and save separately
        this.recentDbNamesUI.unshift(database.substring(database.lastIndexOf("/") + 1, database.length))
        this.recentDbPathsUI.unshift(database.substring(0, database.lastIndexOf("/") + 1))
        // add new keepass database/keyfile entry
        this.recentDbLocations.unshift(databaseLocation)
        this.recentDbFilePaths.unshift(database)
        this.recentUseKeyFiles.unshift(useKeyFile)
        this.recentKeyFileLocations.unshift(keyFileLocation)
        this.recentKeyFilePaths.unshift(keyFile)
        return true
    }

}

