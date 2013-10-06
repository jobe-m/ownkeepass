/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of KeepassMe.
**
** KeepassMe is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** KeepassMe is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with KeepassMe.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

.pragma library

.import QtQuick 2.0 as QQ

var TextFieldAlignment = QQ.Text.AlignRight
var lastOpenedKdbFileName = "myNotes"

var Config = {
    jsondb: undefined,
    kdbDatabase: undefined,

    setJsonDb: function(obj) {
        this.jsondb = obj
    },

    setKdbDatabase: function(obj) {
        this.kdbDatabase = obj
    },

    reset: function() {
        this.jsondb = undefined
        this.kdbDatabase = undefined
    }
}

var config = {
    // user preferences
    showEmptyEntries: false,
    maxNumberOfRecents: 2,


    // Array objects holding recent opened keepass databases.
    // The full path to the database and keyfile must be set.
    // Every database entry has a keyfile entry. If no keyfile exists for a database
    // the keyfile entry must be an empty string "".
    recentDatabaseNames: undefined,
    recentDatabasePaths: undefined,
    recentDatabaseFilePaths: undefined,
    recentKeyFilePaths: undefined,

    // initialize arrays
    initArrays:
    function() {
        this.recentDatabaseNames = []
        this.recentDatabasePaths = []
        this.recentDatabaseFilePaths = []
        this.recentKeyFilePaths = []
    },

    // return amount of recently opened database
    getNumberOfRecents:
    function() {
        // check if all lengths are equal otherwise clean everything up
        var length = this.recentDatabaseNames.length
        if ((this.recentDatabasePaths.length === length) &&
                (this.recentDatabaseFilePaths.length === length) &&
                (this.recentKeyFilePaths.length === length)) {
            return length
        } else {
            this.initArrays()
            return 0
        }
    },

    //
    addNewRecent:
    function(database, keyFile) {
        // check if input is valid
        if (database === undefined) {
            console.log("Database undefined in addNewRecent()")
            return false
        }
        if (keyFile === undefined) {
            keyFile = "/"
        }
        // check if new database is already in the recent list and remove it before adding
        var index = this.recentDatabaseFilePaths.indexOf(database)
        if (index !== -1) {
            this.recentDatabaseNames.splice(index, 1)
            this.recentDatabasePaths.splice(index, 1)
            this.recentDatabaseFilePaths.splice(index, 1)
            this.recentKeyFilePaths.splice(index, 1)
        }
        // check if more than max recent entries are already in the list and remove the oldest
        while (this.getNumberOfRecents() >= this.maxNumberOfRecents) {
            this.recentDatabaseNames.pop()
            this.recentDatabasePaths.pop()
            this.recentDatabaseFilePaths.pop()
            this.recentKeyFilePaths.pop()
        }
        // cut name and path from database file path and save separately
        this.recentDatabaseNames.unshift(database.substring(database.lastIndexOf("/") + 1, database.length))
        this.recentDatabasePaths.unshift(database.substring(0, database.lastIndexOf("/") + 1))
        // add new keepass database/keyfile entry
        this.recentDatabaseFilePaths.unshift(database)
        this.recentKeyFilePaths.unshift(keyFile)
        return true
    }
}
