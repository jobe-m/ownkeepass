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
import "content"
import "common"
import "scripts/Global.js" as Global

ApplicationWindow
{
    id: applicationWindow

    // For accessing main page to further pass application activity status
    property MainPageSimple mainPageRef: null

    initialPage: initialPage

    // Place info popup outside of page stack so that it is shown over all
    // application UI elements
    InfoPopup {
        id: infoPopup
    }

    Component {
        id: initialPage
        MainPageSimple {
            id: mainPage
            Component.onCompleted: applicationWindow.mainPageRef = mainPage
        }
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    onApplicationActiveChanged: {
        // Application goes into background or returns to active focus again
        if (applicationActive) {
            mainPageRef.inactivityTimerStop()
        } else {
            mainPageRef.inactivityTimerStart()
        }
    }

    Component.onCompleted: {
        Global.env.setInfoPopup(infoPopup)
    }
}


