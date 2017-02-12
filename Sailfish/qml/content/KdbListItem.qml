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
import harbour.ownkeepass 1.0
import "../common"
import "../scripts/Global.js" as Global

ListItem {
    id: kdbListItem

    property string text: model.name
    property string subText: model.subtitle
    property bool selected: false
    property bool groupItem: model.itemType === DatabaseItemType.GROUP
    property int showLevel: 0

    menu: ownKeepassDatabase.readOnly ? null : contextMenuComponent
    contentHeight: enabled ? Theme.itemSizeMedium : 0
    width: parent ? parent.width : screen.width
    enabled: showLevel === model.itemLevel
    visible: enabled

    function listItemRemoveGroup() {
        kdbGroupForDeletion.groupId = model.id
        remorseAction("Deleting group", function() { kdbGroupForDeletion.deleteGroup() })
    }
    function listItemRemoveEntry() {
        kdbEntryForDeletion.entryId = model.id
        remorseAction("Deleting entry", function() { kdbEntryForDeletion.deleteEntry() })
    }

    ListView.onAdd: AddAnimation {
        target: kdbListItem
    }
    ListView.onRemove: RemoveAnimation {
        target: kdbListItem
    }

    onClicked: {
        // Check if the user touched the group or entry icon and open the icon selection dialog
        if (mouse.x < Theme.itemSizeMedium) {
            // Save item id of group or entry
            // It will be needed when saving the new icon uuid
            kdbListItemInternal.itemId = model.id
            if (model.itemType === DatabaseItemType.GROUP) {
                // Load group details so that we have them when saving the new icon uuid
                kdbGroup.groupId = model.id
                kdbGroup.loadGroupData()
            } else {
                // Load entry details ...
                kdbEntry.entryId = model.id
                kdbEntry.loadEntryData()
            }
            // open new dialog with grid of all icons
            pageStack.push( editItemIconDialogComponent,
                           { "newIconUuid": model.iconUuid,
                             "itemType": model.itemType })
        } else {
            switch (model.itemType) {
            case DatabaseItemType.GROUP:
                pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                               { "pageTitle": model.name, "groupId": model.id })
                break
            case DatabaseItemType.ENTRY:
                pageStack.push(showEntryDetailsPageComponent,
                               { "pageTitle": model.name, "entryId": model.id })
                break
            }
        }
    }

    Rectangle {
        id: itemIcon
        x: model.itemLevel * (width / Global.icon_indent_in_listview)
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        color: "white"
    }

    OpacityRampEffect {
        sourceItem: itemIcon
        slope: 0.25
        offset: 0.0
        clampFactor: -0.75
        direction: OpacityRamp.BottomToTop
    }

    Image {
        anchors.centerIn: itemIcon
        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
        source: "image://KeepassIcon/" + model.iconUuid
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        opacity: kdbListItem.highlighted ? 0.5 : 1.0
    }

    Item {
        anchors.left: itemIcon.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - Theme.paddingLarge * 2 - Theme.paddingSmall - itemIcon.width
        height: model.itemType === DatabaseItemType.ENTRY && kdbListItem.subText.length === 0 ?
                    itemTitle.height :
                    itemTitle.height + (Theme.paddingSmall / 2) + itemDescription.height

        Label {
            id: itemTitle
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            text: kdbListItem.text
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: itemDescription
            enabled: kdbListItem.subText.length !== 0
            visible: enabled
            anchors.left: parent.left
            anchors.top: itemTitle.bottom
            anchors.topMargin: Theme.paddingSmall / 2
            width: parent.width
            text: kdbListItem.subText
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeExtraSmall
            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
            font.family: Theme.fontFamily
        }
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
            id: contextMenu

            MenuItem {
                enabled: ownKeepassDatabase.type !== DatabaseType.DB_TYPE_KEEPASS_2 || model.itemType === DatabaseItemType.GROUP
                text: qsTr("Edit")
                onClicked: {
                    switch (model.itemType) {
                    case DatabaseItemType.GROUP:
                        pageStack.push(editGroupDetailsDialogComponent,
                                       { "groupId": model.id })
                        break
                    case DatabaseItemType.ENTRY:
                        pageStack.push(editEntryDetailsDialogComponent,
                                       { "entryId": model.id })
                        break
                    }
                }
            }

            MenuItem {
                enabled: ownKeepassDatabase.type !== DatabaseType.DB_TYPE_KEEPASS_2
                text: qsTr("Delete")
                onClicked: {
                    switch (model.itemType) {
                    case DatabaseItemType.GROUP:
                        listItemRemoveGroup()
                        break
                    case DatabaseItemType.ENTRY:
                        listItemRemoveEntry()
                        break
                    }
                }
            }

            MenuItem {
                enabled: (model.itemType === DatabaseItemType.ENTRY) && (ownKeepassDatabase.type !== DatabaseType.DB_TYPE_KEEPASS_2)
                visible: model.itemType === DatabaseItemType.ENTRY
                //: used in menu to move the password entry into another group
                text: qsTr("Move")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("MovePasswordEntryDialog.qml").toString(), {
                                       "itemId": model.id,
                                       "oldGroupId": Global.activeGroupId,
                                       "nameOfPasswordEntry": model.name,
                                       "kdbEntryToMove": kdbEntryToMove
                                   })
                }
            }
        }
    } // end contextMenuComponent
}
