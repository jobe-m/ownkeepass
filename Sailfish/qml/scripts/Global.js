.pragma library

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

// Constants used by infoBanner type
var none = 0
var info = 1
var warning = 2
var error = 3

// The index list below must be the same as the order of language menu items in settings dialog
var system_default = 0
var catalan = 1
var chinese = 2
var czech = 3
var danish = 4
var dutch = 5
var english = 6
var finnish = 7
var french = 8
var german = 9
var italian = 10
var polish = -1 // not yet started
var russian = 11
var spanish = 12
var swedish = 13
var ukrainian = -1 // not yet started


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

    // For clipboard handling
    clipboardUnused: 0,
    clipboardUsernameDropped: 1,
    clipboardPasswordDropped: 2
}

// Environment variables

// Indicator for database locking
// true: Database is opened and can be locked by user or inactivity timer
// false: Database is already locked by user, so that inactivity timer does not lock a second time
var enableDatabaseLock = false


var env = {
    mainPage: undefined,
    kdbDatabase: undefined,
    infoPopup: undefined,
    keepassSettings: undefined,
    coverPage: undefined,

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
    },
    setCoverPage: function(obj) {
        this.coverPage = obj
    }
}

// Get Name for file location
function getLocationName(value) {
    switch (value) {
    case 0:
        //: This is used in the file browser when the user has not yet selected any file.
        return qsTr("Nothing selected yet")
    case 1:
        //: Like the user home folder in linux/unix
        return qsTr("Home:") + (" ")
    case 2:
        return qsTr("SD Card:") + (" ")
    case 3:
        return qsTr("Android Storage:") + (" ")
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
