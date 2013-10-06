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
/*!
    \qmlclass SilicaListItem
    \inherits ListItem

    \brief A common listitem component which contains two lines of text.

   \qml

   \endqml
*/
ListItem {
    id: kdbListItem

    property alias text: firstLabel.text
    property alias subText: secondLabel.text
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
            id: firstLabel
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeMedium
            color: kdbListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        }

        Label {
            id: secondLabel
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
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
