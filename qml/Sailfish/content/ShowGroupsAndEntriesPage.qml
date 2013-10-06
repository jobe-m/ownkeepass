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
import KeepassPlugin 1.0

Page {
    id: showGroupsAndEntriesPage

    // ID of the keepass group which should be shown
    property int groupId: 0
    property bool loadMasterGroups: false
    property string pageTitle: qsTr("Groups and entries")

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: kdbListModel

        header: KeepassPageHeader {
            title: pageTitle
            subTitle: "ownKeepass"
        }

        ViewPlaceholder {
            enabled: listView.count == 0
            text: "No content"
            hintText: loadMasterGroups ? "Pull down to add password groups" : "Pull down to add password groups or entries"
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Database Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("DatabaseSettingsPage.qml").toString())
            }

            MenuItem {
                text: "New Password Group"
                onClicked: pageStack.push(Qt.resolvedUrl("EditGroupDetailsPage.qml").toString(),
                                          { createNewGroup: true, parentGroupId: groupId })
            }
            MenuItem {
                enabled: !loadMasterGroups
                visible: !loadMasterGroups
                text: "New Password Entry"
                onClicked: pageStack.push(Qt.resolvedUrl("EditEntryDetailsPage.qml").toString(),
                                          { createNewEntry: true, parentGroupId: groupId })
            }
        }

        KpPushUpMenu {}

        VerticalScrollDecorator {}

        delegate: ListItem {
            id: kdbListItem

            property string text: model.name // ""
            property string subText: model.subtitle // ""
            property bool selected: false
            property bool groupItem: model.itemType === KdbListModel.GROUP // false

            menu: contextMenuComponent
            contentHeight: col.height
            width: parent ? parent.width : screen.width

            function __removeGroup() {
                kdbGroup.groupId = model.id
                remorseAction("Deleting group", function() { kdbGroup.deleteGroup() })
            }
            function __removeEntry() {
                kdbEntry.entryId = model.id
                remorseAction("Deleting entry", function() { kdbEntry.deleteEntry() })
            }

            ListView.onRemove: animateRemoval()
            onClicked: {
                switch (model.itemType) {
                case KdbListModel.GROUP:
                    pageStack.push(Qt.resolvedUrl("ShowGroupsAndEntriesPage.qml").toString(),
                                   { "pageTitle": model.name, "groupId": model.id })
                    break
                case KdbListModel.ENTRY:
                    pageStack.push(Qt.resolvedUrl("ShowEntryDetailsPage.qml").toString(),
                                   { "pageTitle": model.name, "entryId": model.id })
                    break
                }
            }

            Column {
                id: col
                width: parent.width
                height: children.height
                spacing: Theme.paddingSmall

                Label {
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    text: kdbListItem.text
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: Theme.fontSizeMedium
                    color: kdbListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    text: kdbListItem.subText
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: kdbListItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                }
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    MenuItem {
                        text: qsTr("Edit")
                        onClicked: {
                            switch (model.itemType) {
                            case KdbListModel.GROUP:
                                pageStack.push(Qt.resolvedUrl("EditGroupDetailsPage.qml").toString(), {
                                                   "groupId": model.id })
                                break
                            case KdbListModel.ENTRY:
                                pageStack.push(Qt.resolvedUrl("EditEntryDetailsPage.qml").toString(),
                                               { "entryId": model.id })
                                break
                            }
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            switch (model.itemType) {
                            case KdbListModel.GROUP:
                                __removeGroup()
                                break
                            case KdbListModel.ENTRY:
                                __removeEntry()
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    KdbListModel {
        id: kdbListModel
        onGroupsAndEntriesLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage()
        onSearchEntriesCompleted: {}
        onMasterGroupsLoaded: if (result === KdbListModel.RE_LOAD_ERROR) __showLoadErrorPage
    }

    KdbGroup {
        id: kdbGroup
        onGroupDeleted: if (result === KdbGroup.RE_SAVE_ERROR) __showSaveErrorPage()
    }

    KdbEntry {
        id: kdbEntry
        onEntryDeleted: if (result === KdbEntry.RE_SAVE_ERROR) __showSaveErrorPage()
    }

    Component.onCompleted: {
//    onPageContainerChanged: {
        if (loadMasterGroups) {
            kdbListModel.loadMasterGroupsFromDatabase()
        } else {
            kdbListModel.loadGroupsAndEntriesFromDatabase(groupId)
        }
    }

    function __showLoadErrorPage() {
        pageStack.push(infoDialogPage, {
                           "headerText": "Info",
                           "titleText": "Load Error",
                           "message": "Could not load all items from database. That's strange!"
                       })
    }

    function __showSaveErrorPage() {
        pageStack.push(infoDialogPage, {
                           "headerText": "Info",
                           "titleText": "Save Error",
                           "message": "Could not save your changes to database. That's strange!"
                       })
    }
}
