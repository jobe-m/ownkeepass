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

CoverBackground {
    CoverPlaceholder {
        text: "Database locked"
// TODO only for testing in emulator
//        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
        icon.source: "/opt/sdk/ownKeepass/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

//    Label {
//        id: label
//        anchors.centerIn: parent
//        text: "ownKeepass"
//    }
    
//    CoverActionList {
//        id: coverAction
        
//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }
        
//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
//    }
}


