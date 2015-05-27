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

ListItem {
    id: kdbListItem

    property string text: model.name
    property string subText: model.subtitle
    property bool selected: false
    property bool groupItem: model.itemType === KdbListModel.GROUP

    menu: contextMenuComponent
    contentHeight: Theme.itemSizeMedium
    width: parent ? parent.width : screen.width

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
        x: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        width: 80
        height: 80
        radius: 5
        color: "white"
        opacity: 0.1
    }

    Image {
        x: Theme.paddingLarge + 8 // 8 = (80-Theme.iconSizeMedium)/2
        anchors.verticalCenter: parent.verticalCenter
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
                enabled: model.itemType === KdbListModel.ENTRY
                visible: enabled
                text: qsTr("Move")
                onClicked: {
                    pageStack.push(movePasswordEntryDialogComponent,
                                   { "itemId": model.id, "parentGroupId": 0 /* FIXME */ })
                }
            }
        }
    } // end contextMenuComponent

    Component {
        id: movePasswordEntryDialogComponent
        Dialog {
            id: movePasswordEntryDialog

            // ID of the keepass entry to be moved into another group
            property int itemId: 0
            // ID of group where item is currently placed. This is used to filter out the parent group from the list of groups.
            property int parentGroupId: 0
            // ID of the new parent group of the password item
            property int newGroupId: 0

            // forbit page navigation if new group is not yet selected
            canNavigateForward: true /* FIXME */

            KdbListModel {
                id: movePasswordEntryListModel
            }

            SilicaFlickable {
                anchors.fill: parent

                PullDownMenu {
                    MenuLabel {
                        enabled: text !== ""
                        text: applicationWindow.databaseUiName
                    }
                }

                ApplicationMenu {
                    disableSettingsItem: true
                }

                DialogHeader {
                    id: header
                    //: "Accept" in dialog for choosing group to move password entry into
                    acceptText: qsTr("Accept")
                    cancelText: qsTr("Cancel")
                }

                SilicaLabel {
                    id: dialogLabel
                    y: header.y + header.height
                    width: parent.width
                    text: qsTr("Choose new parent group for password entry:")
                }

                SilicaListView {
                    id: listView
                    width: parent.width
                    height: parent.height - y
                    model: movePasswordEntryListModel
                    clip: true

                    VerticalScrollDecorator {}

                    delegate: BackgroundItem {
                        id: movePasswordEntryListItem

                        Rectangle {
                            color: Theme.highlightColor
                            visible: model.id === editEntryDetailsDialog.newGroupId
                            anchors.fill: parent
                            opacity: 0.5
                        }

                        Image {
                            x: Theme.paddingLarge + 8 // 8 = (80-Theme.iconSizeMedium)/2
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            source: "../../entryicons/_49.png"
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            opacity: highlighted ? 0.5 : 1.0
                        }

                        Item {
                            anchors.left: itemIcon.right
                            anchors.leftMargin: Theme.paddingSmall
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - Theme.paddingLarge * 2 - Theme.paddingSmall - itemIcon.width
                            height: itemTitle.height + (Theme.paddingSmall / 2) + itemDescription.height

                            Label {
                                id: itemTitle
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width
                                text: model.name
                                horizontalAlignment: Text.AlignLeft
                                font.pixelSize: Theme.fontSizeMedium
                                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                                truncationMode: TruncationMode.Fade
                            }

                            Label {
                                id: itemDescription
                                anchors.left: parent.left
                                anchors.top: itemTitle.bottom
                                anchors.topMargin: Theme.paddingSmall / 2
                                width: parent.width
                                text: model.subtitle
                                horizontalAlignment: Text.AlignLeft
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: highlighted ? Theme.highlightColor : Theme.secondaryColor
                            }
                        }

                        onClicked: {
                            if(model.id === editEntryDetailsDialog.newGroupId) {
                                editEntryDetailsDialog.newGroupId = 0;
                            } else {
                                editEntryDetailsDialog.newGroupId = model.id;
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                movePasswordEntryListModel.loadMasterGroupsFromDatabase()
            }
        }
    } // end movePasswordEntryDialogComponent
}
