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
