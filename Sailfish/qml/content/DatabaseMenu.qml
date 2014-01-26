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
    property MenuItem databaseSettingsMenuItem: databaseSettingsMenuItem
    property MenuItem newPasswordGroupsMenuItem: newPasswordGroupsMenuItem
    property MenuItem newPasswordEntryMenuItem: newPasswordEntryMenuItem
    property MenuItem searchMenuItem: searchMenuItem

    MenuItem {
        id: databaseSettingsMenuItem
        visible: enabled
        text: qsTr("Database Settings")
        onClicked: pageStack.push(Global.env.mainPage.editDatabaseSettingsDialogComponent)
    }

    MenuItem {
        id: newPasswordGroupsMenuItem
        visible: enabled
        text: "New Password Group"
        onClicked: pageStack.push(Global.env.mainPage.editGroupDetailsDialogComponent,
                                  { "createNewGroup": true, "parentGroupId": groupId })
    }
    MenuItem {
        id: newPasswordEntryMenuItem
        visible: enabled
        text: "New Password Entry"
        onClicked: {
            console.log("Open EditEntryDetailsDialog to create new entry")
            pageStack.push(Global.env.mainPage.editEntryDetailsDialogComponent,
                           { "createNewEntry": true, "parentGroupId": groupId })
        }
    }
    MenuItem {
        id: searchMenuItem
        visible: enabled
        text: "Search"
        onClicked: {
            if (searchField.enabled) {
                // Disable search functionality
                groupsAndEntriesPage.state = groupsAndEntriesPage.__saveState
                // populate listmodel with group data
                init()
            } else {
                // Enable search functionality
                groupsAndEntriesPage.__saveState = groupsAndEntriesPage.state
                groupsAndEntriesPage.state = "Search"
                // initialise listmodel for search
                kdbListModel.searchRootGroupId = groupsAndEntriesPage.groupId
                kdbListModel.clearListModel()
                searchField.forceActiveFocus()
            }
        }
    }

    MenuLabel {
        id: databaseMenuLabel
        enabled: text !== ""
    }
}
