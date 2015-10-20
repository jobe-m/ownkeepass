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
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
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

    // This page is preloaded when the Query Password Dialog is shown. But without password the
    // database cannot be opened and therefore within this page it will give an error if we load groups
    // from the KdbListModel on startup. So the init() function is invoked later when the database could
    // be opened successfully with the master password.
    property bool initOnPageConstruction: true
    // ID of the keepass group which should be shown ("0" for master groups)
    property string groupId: "0"
    property string pageTitle: qsTr("Password groups")

    // private properties and funtions
    property bool __closeOnError: false
    property string __saveState: state

    function init() {
        if (ownKeepassSettings.showSearchBar) {
            groupsAndEntriesPage.state = "SEARCH_BAR_SHOWN"
        } else {
            groupsAndEntriesPage.state = "SEARCH_BAR_HIDDEN"
        }

        loadGroups()
    }

    function loadGroups() {
        // "Loading" state is initially active when database is currently opening from QueryPasswordDialog.
        // Depending how long it takes to calculate the master key by doing keyTransfomationRounds the init
        // function is called with a significant delay. During that time the busy indicator is shown.
        if (groupId === "0") {
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function closeOnError() {
        __closeOnError = true
        if (status === PageStatus.Active) pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
    }

    function __showLoadErrorPage() {
        applicationWindow.infoPopup.show(Global.error, qsTr("Load Error"), qsTr("Could not load all items from Keepass database file. That's strange."))
    }

    function __showSaveErrorPage() {
        applicationWindow.infoPopup.show(Global.error, qsTr("Save Error"), qsTr("Could not save your changes to Keepass database file. Either the location of the file is write protected or it was removed."))
    }

    allowedOrientations: applicationWindow.orientationSetting

    onOrientationChanged: {
        // Update header box height when page orientation changes, ie. page header hight also changes
        if (orientation & Orientation.PortraitMask) {
            // Orientation Portrait = -110
            headerBox.listViewStart = -110
        } else {
            // Orientation Landscape = -80
            headerBox.listViewStart = -80
        }
    }

    Item {
        id: headerBox
        // (deault) Orientation Portrait = -110
        property int listViewStart: -110
        // y position of header box is depending of search field hight and list view content start position
        // it also changes when pulley menu is opened (done with listView.contentY)
        y: 0 - listView.contentY + listViewStart - searchField.height
        z: 1
        width: parent.width
        height: pageHeader.height + searchField.height

        PageHeaderExtended {
            id: pageHeader
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            subTitle: "ownKeepass"
            subTitleOpacity: 0.5
            subTitleBottomMargin: groupsAndEntriesPage.orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
        }

        SearchField {
            id: searchField
            property int enabledHeight: 100
            anchors.top: pageHeader.bottom
            anchors.left: parent.left
            width: parent.width
            opacity: enabled ? 1.0 : 0.0
            height: enabled ? enabledHeight : 0
            placeholderText: qsTr("Search")
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: listView.focus = true

            onTextChanged: {
                if (text.length > 0) {
                    // set group Id from which the search should be performed
                    kdbListModel.searchRootGroupId = groupId
                    kdbListModel.searchEntriesInKdbDatabase(searchField.text)
                } else {
                    kdbListModel.clearListModel()
                    // reload original group content when searchfield is empty
                    loadGroups()
                }
            }

            onFocusChanged: {
                if (focus) {
//                    console.log("Search bar has focus")
                    groupsAndEntriesPage.state = "SEARCHING"
                } else {
//                    console.log("Search bar lost focus")
                    if (text.length === 0 && groupsAndEntriesPage.state === "SEARCHING") {
                        groupsAndEntriesPage.state = "SEARCH_BAR_SHOWN"
                    }
                }
            }

            Behavior on height { NumberAnimation {} }
            Behavior on opacity { FadeAnimation {} }
        }
    }

    SilicaListView {
        id: listView
        currentIndex: -1
        anchors.fill: parent
        model: kdbListModel

        header: Item {
            // This is just a placeholder for the header box. To avoid the
            // list view resetting the input box everytime the model resets,
            // the search entry is defined outside the list view.
            height: headerBox.height
        }

        ViewSearchPlaceholder {
            id: searchNoEntriesFoundPlaceholder
            // we need to bind the y position of the placeholder to the list view content so that it moves when pulley menu is opened
            y: 0 - listView.contentY
            height: parent.height - headerBox.height
            width: parent.width
            text: qsTr("No entries found")

            onClicked: {
                searchField.forceActiveFocus()
            }
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
                    text: qsTr("Decrypting Keepass database")
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

        ViewPlaceholder {
            id: viewPlaceholder
            verticalOffset: wallImage.height / 2

            text: qsTr("Group is empty")
            hintText: !ownKeepassDatabase.readOnly ?
                          (ownKeepassDatabase.type === DatabaseType.DB_TYPE_KEEPASS_1 &&
                          groupId === "0" ? qsTr("Pull down to add password groups") :
                                          qsTr("Pull down to add password groups or entries")) : ""

            Image {
                id: wallImage
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../wallicons/wall-group.png"
            }
        }

        DatabaseMenu {
            id: databaseMenu
            menuLabelText: Global.activeDatabase

            onNewPasswordGroupClicked: {
                // empty searchField
                searchField.text = ""
                pageStack.push(Global.env.mainPage.editGroupDetailsDialogComponent,
                               { "createNewGroup": true, "parentGroupId": groupId })
            }

            onNewPasswordEntryClicked: {
                // empty searchField
                searchField.text = ""
                pageStack.push(Global.env.mainPage.editEntryDetailsDialogComponent,
                               { "createNewEntry": true, "parentGroupId": groupId })
            }

            onSearchClicked: {
                // empty searchField
                searchField.text = ""
                // toggle search bar
                if (groupsAndEntriesPage.state === "SEARCH_BAR_HIDDEN") {
                    // show search bar
                    groupsAndEntriesPage.state = "SEARCH_BAR_SHOWN"
                    // save to settings
                    ownKeepassSettings.showSearchBar = true
                } else if (groupsAndEntriesPage.state === "SEARCH_BAR_SHOWN" ||
                           groupsAndEntriesPage.state === "SEARCHING") {
                    // steal focus from search bar so that is not active next time when the user
                    // selects "Show search" from pulley menu, otherwise its behaviour is weird
                    listView.focus = true
                    // hide search bar a bit delayed to let the pulley menu snap back and avoid motor saw sound
                    searchBarHiddenTimer.restart()
                    // save to settings
                    ownKeepassSettings.showSearchBar = false
                }
            }
        }

        ApplicationMenu {
            helpContent: groupId === "0" ? "MasterGroupsPage" : "SubGroupsPage"
        }

        VerticalScrollDecorator {}

        delegate: Global.env.mainPage.kdbListItemComponent
    }

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: {
            if (result === DatabaseAccessResult.RE_DB_LOAD_ERROR) __showLoadErrorPage()
        }
        onMasterGroupsLoaded: {
            if (result === DatabaseAccessResult.RE_DB_LOAD_ERROR) __showLoadErrorPage()
            // automatically focus search bar on master group page but not on sub-group pages
            if (ownKeepassSettings.showSearchBar && ownKeepassSettings.focusSearchBarOnStartup && !isEmpty) {
                searchField.focus = true
            }
        }
    }

    Timer {
        id: searchBarHiddenTimer
        interval: 500
        onTriggered: groupsAndEntriesPage.state = "SEARCH_BAR_HIDDEN"
    }

    state: "LOADING"

    states: [
        State {
            name: "LOADING"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: false
                enableNewPasswordGroupsMenuItem: false
                enableNewPasswordEntryMenuItem: false
                enableSearchMenuItem: false; isTextHideSearch: false }
            PropertyChanges { target: viewPlaceholder; enabled: false }
            PropertyChanges { target: searchNoEntriesFoundPlaceholder; enabled: false }
            PropertyChanges { target: busyIndicator; running: true }
            PropertyChanges { target: pageHeader; title: qsTr("Loading") }
            PropertyChanges { target: searchField; enabled: false }
            // Don't set cover state here, it will overwrite cover state from Query password dialog

//            PropertyChanges { target: rectState; color: "white" }
        },
        State {
            name: "SEARCH_BAR_HIDDEN"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: true
                enableNewPasswordGroupsMenuItem: true
                enableNewPasswordEntryMenuItem: groupId !== "0"
                enableSearchMenuItem: !kdbListModel.isEmpty; isTextHideSearch: false }
            PropertyChanges { target: viewPlaceholder; enabled: kdbListModel.isEmpty }
            PropertyChanges { target: searchNoEntriesFoundPlaceholder; enabled: false }
            PropertyChanges { target: busyIndicator; running: false }
            PropertyChanges { target: pageHeader
                title: groupId === "0" ? qsTr("Password groups") :
                                       groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: searchField; enabled: false }
            PropertyChanges { target: applicationWindow.cover
                title: groupId === "0" ? qsTr("Password groups") :
                                       groupsAndEntriesPage.pageTitle
                state: "GROUPS_VIEW" }

//            PropertyChanges { target: rectState; color: "red" }
        },
        State {
            name: "SEARCH_BAR_SHOWN"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: true
                enableNewPasswordGroupsMenuItem: true
                enableNewPasswordEntryMenuItem: groupId !== "0"
                enableSearchMenuItem: !kdbListModel.isEmpty; isTextHideSearch: true }
            PropertyChanges { target: viewPlaceholder; enabled: kdbListModel.isEmpty }
            PropertyChanges { target: searchNoEntriesFoundPlaceholder; enabled: false }
            PropertyChanges { target: busyIndicator; running: false }
            PropertyChanges { target: pageHeader
                title: groupId === "0" ? qsTr("Password groups") :
                                       groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: searchField
                enabled: !kdbListModel.isEmpty }
            PropertyChanges { target: applicationWindow.cover
                title: groupId === "0" ? qsTr("Password groups") :
                                       groupsAndEntriesPage.pageTitle
                state: "GROUPS_VIEW" }

//            PropertyChanges { target: rectState; color: "yellow" }
        },
        State {
            name: "SEARCHING"
            PropertyChanges { target: databaseMenu; enableDatabaseSettingsMenuItem: true
                enableNewPasswordGroupsMenuItem: true
                enableNewPasswordEntryMenuItem: groupId !== "0"
                enableSearchMenuItem: true/*searchField.text.length === 0*/; isTextHideSearch: true }
            PropertyChanges { target: viewPlaceholder; enabled: false }
            PropertyChanges { target: searchNoEntriesFoundPlaceholder; enabled: kdbListModel.isEmpty }
            PropertyChanges { target: pageHeader
                title: groupId === "0" ? qsTr("Search in all groups") :
                                       qsTr("Search in") + " " + groupsAndEntriesPage.pageTitle }
            PropertyChanges { target: searchField; enabled: true }
            PropertyChanges { target: applicationWindow.cover
                title: groupId === "0" ? qsTr("Search in all groups") :
                                       qsTr("Search in") + " " + groupsAndEntriesPage.pageTitle
                state: "SEARCH_VIEW" }

//            PropertyChanges { target: rectState; color: "green" }
        }
    ]

    onStatusChanged: {
        if (__closeOnError && status === PageStatus.Active) {
            pageStack.pop(pageStack.previousPage(groupsAndEntriesPage))
        } else if (status === PageStatus.Active) {

            // check if page state needs to change because search bar state was changed on a sub-page
            if (ownKeepassDatabase.type === DatabaseType.DB_TYPE_KEEPASS_1 &&
                    ownKeepassSettings.showSearchBar &&
                    state === "SEARCH_BAR_HIDDEN") {
                state = "SEARCH_BAR_SHOWN"
            } else if (!ownKeepassSettings.showSearchBar && state !== "SEARCH_BAR_HIDDEN") {
                // steal focus from search bar
                listView.focus = true
                state = "SEARCH_BAR_HIDDEN"
            } else {
                // restore group title and state in cover page
                switch (state) {
                case "SEARCH_BAR_HIDDEN":
                    applicationWindow.cover.title = groupId === "0" ? qsTr("Password groups") :
                                                                    groupsAndEntriesPage.pageTitle
                    applicationWindow.cover.state = "GROUPS_VIEW"
                    break
                case "SEARCH_BAR_SHOWN":
                    applicationWindow.cover.title = groupId === "0" ? qsTr("Password groups") :
                                                                    groupsAndEntriesPage.pageTitle
                    applicationWindow.cover.state = "GROUPS_VIEW"
                    break
                case "SEARCHING":
                    applicationWindow.cover.title = groupId === "0" ? qsTr("Search in all groups") :
                                                                    qsTr("Search in") + " " + groupsAndEntriesPage.pageTitle
                    applicationWindow.cover.state = "SEARCH_VIEW"
                    break
                default:
                    applicationWindow.cover.title = pageTitle
                    applicationWindow.cover.state = "GROUPS_VIEW"
                    break
                }
            }
            // set ID of currently viewed group
            Global.activeGroupId = groupId
            // set menu label, it will have changed after initialization of this page in QueryPasswordDialog
            databaseMenu.menuLabelText = Global.activeDatabase
        }
    }

    Component.onCompleted: {
        if (initOnPageConstruction) {
            init()
        }
    }
}
