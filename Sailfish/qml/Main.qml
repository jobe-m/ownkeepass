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
import "cover"
import "common"
import "scripts/Global.js" as Global

ApplicationWindow
{
    id: applicationWindow

    // For accessing main page to pass further application activity status
    property MainPage mainPageRef: null
    property InfoPopup infoPopup: infoPopupObj

    property int orientationSetting: (Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted)

    initialPage: mainPageContainer
    cover: coverPage

    // Place info popup outside of page content so that it is shown over all application UI elements
    InfoPopup {
        id: infoPopupObj
        // pass orientation changes of application window to info popup component so that it can animate itself
        orientation: applicationWindow.orientation
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
        onLockDatabase: mainPageRef.lockDatabase()
        onTriggerClearClipboard: mainPageRef.clipboardTimerStart()
        Component.onCompleted: Global.env.setCoverPage(coverPage)
    }

    Connections {
        target: ownKeepassSettings
        onShowChangeLogBanner: {
            pageStack.push(Qt.resolvedUrl("content/ChangeLogPage.qml"),
                           { "newVersionAvailable": true })
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

    Component.onCompleted: {
        // This binds the setting for allowed orientations to the property which is used on all sub-pages
        orientationSetting = Qt.binding(function() {
            switch (ownKeepassSettings.uiOrientation) {
            case 1:
                return Orientation.Portrait
            case 2:
                return Orientation.Landscape
            default:
                if (Screen.sizeCategory >= Screen.Large) {
                    // Tablet size display
                    return (Orientation.Portrait | Orientation.PortraitInverted | Orientation.Landscape | Orientation.LandscapeInverted)
                } else {
                    // Phone size display
                    return (Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted)
                }
            }
        })
    }
}


