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
import harbour.ownkeepass.KeepassX1 1.0
import "../common"
import "../scripts/Global.js" as Global

ListItem {
    id: kdbListItem

    property string text: model.name
    property string subText: model.subtitle
    property bool selected: false
    property bool groupItem: model.itemType === KdbListModel.GROUP
    property int showLevel: 0

    menu: contextMenuComponent
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
        switch (model.itemType) {
        case KdbListModel.GROUP:
            pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                           { "pageTitle": model.name, "groupId": model.id })
            break
        case KdbListModel.ENTRY:
            pageStack.push(showEntryDetailsPageComponent,
                           { "pageTitle": model.name, "entryId": model.id })
            break
        }
    }

    Rectangle {
        id: itemIcon
        x: model.itemLevel * (parent.width / 20)
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
        source: model.itemType === KdbListModel.ENTRY ? "../../entryicons/_0.png" : "../../entryicons/_49.png"
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        opacity: kdbListItem.highlighted ? 0.5 : 1.0
    }

    Item {
        anchors.left: itemIcon.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - Theme.paddingLarge * 2 - Theme.paddingSmall - itemIcon.width
        height: model.itemType === KdbListModel.ENTRY && kdbListItem.subText.length === 0 ?
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
        }
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: contextMenu
            property int itemTypeFromModel: 0
            property int itemIdFromModel: 0
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    switch (model.itemType) {
                    case KdbListModel.GROUP:
                        pageStack.push(editGroupDetailsDialogComponent,
                                       { "groupId": model.id })
                        break
                    case KdbListModel.ENTRY:
                        pageStack.push(editEntryDetailsDialogComponent,
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
                        listItemRemoveGroup()
                        break
                    case KdbListModel.ENTRY:
                        listItemRemoveEntry()
                        break
                    }
                }
            }
            MenuItem {
//                id: moveMenuItem
//                property KdbEntry kdbEntryToMoveRef: kdbEntryToMove
                enabled: model.itemType === KdbListModel.ENTRY
                visible: enabled
                //: used in menu to move the password entry into another group
                text: qsTr("Move")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("MovePasswordEntryDialog.qml").toString(), {
                                       "itemId": model.id,
                                       "oldGroupId": Global.activeGroupId,
                                       "nameOfPasswordEntry": model.name,
                                       "kdbEntryToMove": kdbEntryToMove
                                   })
//                    dialog.accepted.connect(function() {
//                        moveMenuItem.kdbEntryToMoveRef.entryId = dialog.itemId
//                        moveMenuItem.kdbEntryToMoveRef.moveEntry(dialog.newGroupId)
//                    })
                }
            }
        }
    } // end contextMenuComponent
}
