/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass 1.0
import "../scripts/Global.js" as Global


Dialog {
    id: movePasswordEntryDialog

    // ID of the keepass entry to be moved into another group
    property string itemId: ""
    // ID of group where item is currently placed. This is used to filter out the parent group from the list of groups.
    property string oldGroupId: ""
    // ID of the new parent group of the password item
    property string newGroupId: ""
    // Name of password entry to show in dialog cation text
    property string nameOfPasswordEntry: ""
    //
    property KdbEntry kdbEntryToMove

    // forbit page navigation if new group is not yet selected
    canNavigateForward: newGroupId !== ""
    allowedOrientations: applicationWindow.orientationSetting

    onAccepted: {
        // Now trigger moving of password entry
        kdbEntryToMove.entryId = itemId
        kdbEntryToMove.moveEntry(newGroupId)
    }

    KdbListModel {
        id: movePasswordEntryListModel
        onMasterGroupsLoaded: Global.env.mainPage.errorHandler(result, errorMsg)
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
            }
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
            text: qsTr("Move password entry \"%1\" into following group:").arg(movePasswordEntryDialog.nameOfPasswordEntry)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        SilicaListView {
            id: listView
            y: header.y + header.height + dialogLabel.height + Theme.paddingMedium
            width: parent.width
            height: parent.height - y
            model: movePasswordEntryListModel
            clip: true

            VerticalScrollDecorator {}

            delegate: BackgroundItem {
                id: movePasswordEntryListItem
                height: Theme.itemSizeMedium
                enabled: model.id !== movePasswordEntryDialog.oldGroupId
                opacity: enabled ? 1.0 : 0.2

                Rectangle {
                    color: Theme.highlightColor
                    visible: model.id === movePasswordEntryDialog.newGroupId
                    anchors.fill: parent
                    opacity: 0.5
                }

                Image {
                    id: iconBackground
                    x: model.itemLevel * (width / Global.icon_indent_in_listview)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.itemSizeMedium
                    height: Theme.itemSizeMedium
                    source: "image://IconBackground"
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }

                Image {
                    anchors.centerIn: iconBackground
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    source: "image://KeepassIcon/" + model.iconUuid
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    opacity: model.id === movePasswordEntryDialog.newGroupId ? 0.7 : 1.0
                }

                Item {
                    anchors.left: iconBackground.right
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.rightMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    height: itemTitle.height + (Theme.paddingSmall / 2) + itemDescription.height

                    Label {
                        id: itemTitle
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: parent.width
                        text: model.name
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: Theme.fontSizeMedium
                        color: movePasswordEntryListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        opacity: model.id === movePasswordEntryDialog.newGroupId ? 0.7 : 1.0
                        truncationMode: TruncationMode.Fade
                    }

                    Label {
                        id: itemDescription
                        anchors.left: parent.left
                        anchors.top: itemTitle.bottom
                        anchors.topMargin: Theme.paddingSmall / 2
                        width: parent.width
                        text: model.subTitle
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: movePasswordEntryListItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        opacity: model.id === movePasswordEntryDialog.newGroupId ? 0.7 : 1.0
                    }
                }

                onClicked: {
                    if(model.id === movePasswordEntryDialog.newGroupId) {
                        movePasswordEntryDialog.newGroupId = "0";
                    } else {
                        movePasswordEntryDialog.newGroupId = model.id;
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        movePasswordEntryListModel.loadGroupListFromDatabase()
    }
}
