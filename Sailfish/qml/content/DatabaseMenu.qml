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
import "../scripts/Global.js" as Global

PullDownMenu {
    id: databaseMenu

    property alias menuLabelText: databaseMenuLabel.text
    property bool enableDatabaseSettingsMenuItem: false
    property bool enableNewPasswordGroupsMenuItem: false
    property bool enableNewPasswordEntryMenuItem: false
    property bool enableSearchMenuItem: false

    signal newPasswordEntryClicked
    signal newPasswordGroupClicked
    signal searchClicked

    MenuItem {
        enabled: enableDatabaseSettingsMenuItem
        visible: enabled
        text: qsTr("Database Settings")
        onClicked: {
            pageStack.push(Global.env.mainPage.editDatabaseSettingsDialogComponent)
        }
    }

    MenuItem {
        enabled: enableNewPasswordGroupsMenuItem
        visible: enabled
        text: "New Password Group"
        onClicked: {
            newPasswordGroupClicked()
        }
    }

    MenuItem {
        enabled: enableNewPasswordEntryMenuItem
        visible: enabled
        text: "New Password Entry"
        onClicked: {
            newPasswordEntryClicked()
        }
    }
    MenuItem {
        enabled: enableSearchMenuItem
        visible: enabled
        text: "Search"
        onClicked: {
            searchClicked()
        }
    }

    MenuLabel {
        id: databaseMenuLabel
        enabled: text !== ""
    }
}
