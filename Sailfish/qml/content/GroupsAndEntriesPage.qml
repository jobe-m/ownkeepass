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
import harbour.ownkeepass 1.0

Page {
    id: groupsAndEntriesPage

    /*
      This page is preloaded when the Query Password Dialog is shown. But without password the
      database cannot be opened and therefore within this page it will give an error if we load groups
      from the KdbListModel on startup. So the init() function is invoked later when the database could
      be opened successfully with the master password.
     */
    property bool initOnPageConstruction: true
    // ID of the keepass group which should be shown
    property int groupId: 0
    property bool loadMasterGroups: false
    property string pageTitle: "Password Groups"

    function init() {
        // "Loading" state is initially active when database is currently opening from QueryPasswordDialog.
        // Depending how long it takes to calculate the master key by doing keyTransfomationRounds the init
        // function is called with a significant delay. During that time the busy indicator is shown.
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

    SilicaListView {
        id: listView
        currentIndex: -1
        anchors.fill: parent
        model: kdbListModel

        header: PageHeaderExtended {
            title: groupsAndEntriesPage.pageTitle
            subTitle: "ownKeepass"
        }

        Item {
            anchors.fill: parent

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: Theme.paddingLarge

                SilicaLabel {
                    horizontalAlignment: Text.AlignHCenter
                    enabled: busyIndicator.running
                    visible: busyIndicator.running
                    text: "Decrypting Keepass Database"
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraLarge
                    Behavior on opacity { FadeAnimation {} }
                }

                BusyIndicator {
                    id: busyIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: running
                    visible: running
                    running: false
                    size: BusyIndicatorSize.Large
                    Behavior on opacity { FadeAnimation {} }
                }
            }
        }

        SilicaViewPlaceholder {
            id: viewPlaceholder
            image.source: "../../wallicons/wall-group.png"
            text: "Group is empty"
        }

        DatabaseMenu {
            id: databaseMenu
            menuLabelText: Global.databaseUiName

            onSearchClicked: {
                // open search page
                pageStack.push(Qt.resolvedUrl("SearchPage.qml").toString(), {
                                   "searchGroupId": groupsAndEntriesPage.groupId,
                                   "pageTitle": groupsAndEntriesPage.groupId === 0 ? "Search in all Groups" :
                                                                                     "Search in " + groupsAndEntriesPage.pageTitle
                               })
            }
        }

        ApplicationMenu {}

        VerticalScrollDecorator {}

        delegate: Global.env.mainPage.kdbListItemComponent
    }

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
        onMasterGroupsLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
    }

    state: "Loading"

    states: [
        State {
            name: "Loading"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: false }
            PropertyChanges { target: databaseMenu; enableNewPasswordGroupsMenuItem: false }
            PropertyChanges { target: databaseMenu; enableNewPasswordEntryMenuItem: false }
            PropertyChanges { target: databaseMenu; enableSearchMenuItem: false }
            PropertyChanges { target: viewPlaceholder; enabled: false }
            PropertyChanges { target: busyIndicator; running: true }
        },
        State {
            name: "LoadMasterGroups"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: true }
            PropertyChanges { target: databaseMenu; enableNewPasswordGroupsMenuItem: true }
            PropertyChanges { target: databaseMenu; enableNewPasswordEntryMenuItem: false }
            PropertyChanges { target: databaseMenu; enableSearchMenuItem: !kdbListModel.isEmpty }
            PropertyChanges { target: viewPlaceholder; enabled: listView.count === 0;
                hintText: "Pull down to add password groups" }
            PropertyChanges { target: busyIndicator; running: false }
        },
        State {
            name: "LoadGroupsAndEntries"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: true }
            PropertyChanges { target: databaseMenu; enableNewPasswordGroupsMenuItem: true }
            PropertyChanges { target: databaseMenu; enableNewPasswordEntryMenuItem: true }
            PropertyChanges { target: databaseMenu; enableSearchMenuItem: !kdbListModel.isEmpty }
            PropertyChanges { target: viewPlaceholder;  enabled: listView.count === 0;
                hintText: "Pull down to add password groups or entries" }
            PropertyChanges { target: busyIndicator; running: false }
        }
    ]

    onStatusChanged: {
        if (__closeOnError && status === PageStatus.Active) {
            pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
        } else if (status === PageStatus.Active) {
            applicationWindow.cover.coverState = Global.constants.databaseOpened
        }
    }

    Component.onCompleted: {
        if (initOnPageConstruction) init()
    }
}
