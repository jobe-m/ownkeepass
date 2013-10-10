/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of KeepassMe.
**
** KeepassMe is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** KeepassMe is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with KeepassMe.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 1.1
import com.nokia.meego 1.1
import "common"
import "common/Constants.js" as Constants
import KeepassX 1.0

Page {
    id: searchPage

    property int parentGroupId: 0
    property string pageTitle: qsTr("Search")

    Component.onCompleted: searchBox.setFocus()

    tools: commonTools

    KdbListModel {
        id: kdbSearchListModel
        // if parentGroupId is zero then search will be performed in all groups
        // otherwise only in the sub-tree of the group
        searchRootGroupId: searchPage.parentGroupId
        onSearchEntriesCompleted: if (result === KdbListModel.RE_LOAD_ERROR) infoDialog.open()
    }

    PageHeader {
        id: pageHeader
        pageTitle: searchPage.pageTitle
    }

    ListView {
        anchors.top: searchBoxContainer.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: false
        model: kdbSearchListModel

        delegate: ListItem {
            id: listItem
//            iconSource: Qt.resolvedUrl("covers/" + model.cover).toString()
            text: model.name
            subText: model.subtitle
            onClicked: {
                pageHeader.forceActiveFocus()
                searchBox.closeKeypad()
                switch (model.itemType) {
                case KdbListModel.GROUP:
                    pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                                   { pageTitle: model.name, groupId: model.id })
                    break
                case KdbListModel.ENTRY:
                    pageStack.push(Qt.resolvedUrl("EntryDetailsPage.qml").toString(),
                                   { pageTitle: model.name, entryId: model.id })
                    break
                }
            }
            onPressAndHold: {
                pageHeader.forceActiveFocus()
                searchBox.closeKeypad()
                listItemMenu.itemType = model.itemType
                listItemMenu.itemName = model.name
                listItemMenu.itemId = model.id
                listItemMenu.open()
            }
        }
    }

    Rectangle {
        id: searchBoxContainer
        anchors.top: pageHeader.bottom
        width: parent.width
        height: searchBox.height
        color: theme.inverted ? Constants.COLOR_INVERTED_BACKGROUND : Constants.COLOR_BACKGROUND

        SearchBox {
            id: searchBox
            anchors.top: parent.top
            placeHolderText: "search"
            onSearchTextChanged: {
                if (searchText !== "") {
                    kdbSearchListModel.searchEntriesInKdbDatabase(searchText)
                    setFocus()
                } else {
                    kdbSearchListModel.clearListModel()
                }
            }
            onSearchFinished: {
                closeKeypad()
                pageHeader.focus = true
            }
        }
    }

    ListItemMenu {
        id: listItemMenu
    }

    QueryDialog {
        id: infoDialog
        titleText: "Load Error"
        message: "Could not load all items from database. That's strange!"
        acceptButtonText: "OK"
    }

    CommonToolBar {
        id: commonTools
        onBackIconClicked: pageStack.pop()
    }

    CommonMenu {
        id: commonMenu
    }
}
