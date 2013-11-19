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
import "../common"
import "../scripts/Global.js" as Global
import KeepassPlugin 1.0

Page {
    id: groupsAndEntriesPage

    /*
      Because this page is preloaded when the Query Password Dialog is shown, but without password the
      database cannot be opened and therefore within this page it will give an error if we load groups
      from the KdbListModel on startup. So the init() function is invoked later when the database could
      be opened successfully.
     */
    property bool initOnPageConstruction: true
    // ID of the keepass group which should be shown
    property int groupId: 0
    property bool loadMasterGroups: false
    property string pageTitle: "Password Groups"

    function init() {
        if (loadMasterGroups) {
            groupsAndEntriesPage.state = "LoadMasterGroups"
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            groupsAndEntriesPage.state = "LoadGroupsAndEntries"
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function closeOnError() {
        __closeOnError = true
        if (status === PageStatus.Active) pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
    }

    // private properties and funtions
    property bool __closeOnError: false
    property string __saveState: state
    function __showLoadErrorPage() {
        console.log("ERROR: Could not load")
        Global.env.infoPopup.show("Load Error", "Could not load all items from Keepass database file. That's strange.", 0, false)
    }

    function __showSaveErrorPage() {
        console.log("ERROR: Could not save")
        Global.env.infoPopup.show("Save Error", "Could not save your changes to Keepass database file. Either the location of the file is write protected or it was removed.", 0, false)
    }

    Column {
        id: headerContainer
        width: parent.width
        height: children.height

        PageHeaderExtended {
            id: pageHeader
            subTitle: "ownKeepass"
        }

        SearchField {
            id: searchField
            width: parent.width
            height: 0
            enabled: false
            opacity: 0.0
            placeholderText: "Search"

            onTextChanged: {
                kdbListModel.searchEntriesInKdbDatabase(searchField.text)
            }

            Behavior on height { NumberAnimation {} }
            Behavior on opacity { FadeAnimation {} }
        }
    }

    SilicaListView {
        id: listView
        currentIndex: -1
        onCurrentIndexChanged: {
            console.log("currentIndex changed: " + currentIndex)
        }

        anchors.fill: parent
        model: kdbListModel

        ViewPlaceholder {
            id: viewPlaceholder
            text: "Group is empty"
        }

        header: Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        PullDownMenu {
            MenuItem {
                id: databaseSettingsMenuItem
                text: qsTr("Database Settings")
                onClicked: pageStack.push(Global.env.mainPage.editDatabaseSettingsDialogComponent)
            }

            MenuItem {
                id: newPasswordGroupsMenuItem
                text: "New Password Group"
                onClicked: pageStack.push(Global.env.mainPage.editGroupDetailsDialogComponent,
                                          { "createNewGroup": true, "parentGroupId": groupId })
            }
            MenuItem {
                id: newPasswordEntryMenuItem
                text: "New Password Entry"
                onClicked: {
                    console.log("Open EditEntryDetailsDialog to create new entry")
                    pageStack.push(Global.env.mainPage.editEntryDetailsDialogComponent,
                                   { "createNewEntry": true, "parentGroupId": groupId })
                }
            }
            MenuItem {
                id: searchMenuItem
                text: "Search"
                onClicked: {
                    if (searchField.enabled) {
                        // Disable search functionality
                        groupsAndEntriesPage.state = groupsAndEntriesPage.__saveState
                        // populate listmodel with group
                        init()
                    } else {
                        // Enable search functionality
                        groupsAndEntriesPage.__saveState = groupsAndEntriesPage.state
                        groupsAndEntriesPage.state = "Search"
                        // prevent newly added list delegates from stealing focus
                        listView.currentIndex = -1
                        // initialise listmodel for search
                        kdbListModel.searchRootGroupId = groupsAndEntriesPage.groupId
                        kdbListModel.searchEntriesInKdbDatabase("")
                        searchField.forceActiveFocus()
                    }
                }
            }
        }

        KpPushUpMenu {}

        VerticalScrollDecorator {}

        delegate: Global.env.mainPage.kdbListItemComponent
    }

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
        onMasterGroupsLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage
    }

    state: "Loading"

    states: [
        State {
            name: "Loading"
            PropertyChanges { target: pageHeader; title: groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: databaseSettingsMenuItem; enabled: false; visible: false }
            PropertyChanges { target: newPasswordGroupsMenuItem; enabled: false; visible: false }
            PropertyChanges { target: newPasswordEntryMenuItem; enabled: false; visible: false }
            PropertyChanges { target: searchMenuItem; enabled: false; visible: false }
            PropertyChanges { target: viewPlaceholder; enabled: false }
        },
        State {
            name: "LoadMasterGroups"
            PropertyChanges { target: pageHeader; title: groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: databaseSettingsMenuItem; enabled: true; visible: true }
            PropertyChanges { target: newPasswordGroupsMenuItem; enabled: true; visible: true }
            PropertyChanges { target: newPasswordEntryMenuItem; enabled: false; visible: false }
            PropertyChanges { target: searchMenuItem; enabled: true; visible: true; text: "Search" }
            PropertyChanges { target: searchField; enabled: false; height: 0; opacity: 0.0 }
            PropertyChanges { target: viewPlaceholder; enabled: listView.count === 0;
                hintText: "Pull down to add password groups" }
        },
        State {
            name: "LoadGroupsAndEntries"
            PropertyChanges { target: pageHeader; title: groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: databaseSettingsMenuItem; enabled: true; visible: true }
            PropertyChanges { target: newPasswordGroupsMenuItem; enabled: true; visible: true }
            PropertyChanges { target: newPasswordEntryMenuItem; enabled: true; visible: true }
            PropertyChanges { target: searchMenuItem; enabled: true; visible: true; text: "Search" }
            PropertyChanges { target: searchField; enabled: false; height: 0; opacity: 0.0 }
            PropertyChanges { target: viewPlaceholder;  enabled: listView.count === 0;
                hintText: "Pull down to add password groups and entries" }
        },
        State {
            name: "Search"
            PropertyChanges { target: pageHeader; title: "Search for Entries" }
            PropertyChanges { target: databaseSettingsMenuItem; enabled: true; visible: true }
            PropertyChanges { target: newPasswordGroupsMenuItem; enabled: false; visible: false }
            PropertyChanges { target: newPasswordEntryMenuItem; enabled: false; visible: false }
            PropertyChanges { target: searchMenuItem; enabled: true; visible: true; text: "End Search" }
            PropertyChanges { target: searchField; enabled: true; height: searchField.implicitHeight; opacity: 1.0 }
            PropertyChanges { target: viewPlaceholder; enabled: false }
        }
    ]

    onStatusChanged: {
        if (__closeOnError && status === PageStatus.Active) pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
    }

    Component.onCompleted: {
        if (initOnPageConstruction) init()
    }
}
