/***************************************************************************
**
** Copyright (C) 2013-2014 Marko Koschak (marko.koschak@tisno.de)
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
    id: searchPage

    // ID of the keepass group which should be shown
    property int searchGroupId: 0
    property string pageTitle: "Search"

    Item {
        id: headerBox
        property int neutralPos: 0
        y: 0 - listView.contentY + neutralPos
        z: 1
        width: parent.width
        height: pageHeader.height + searchField.height

        Component.onCompleted: {
            neutralPos = listView.contentY
        }

        PageHeaderExtended {
            id: pageHeader
            anchors.top: parent.top
            width: parent.width
            title: searchPage.pageTitle
            subTitle: "ownKeepass"
        }

        SearchField {
            id: searchField
            anchors.top: pageHeader.bottom
            width: parent.width
            placeholderText: "Search"

            onHeightChanged: {
                // recalculate neutral position when search field appears and disappears
                if (height === implicitHeight) {
                    parent.neutralPos -= implicitHeight
                } else if (height === 0) {
                    parent.neutralPos += implicitHeight
                }
            }

            onTextChanged: {
                if (text !== "") {
                    kdbSearchListModel.searchEntriesInKdbDatabase(searchField.text)
                } else {
                    kdbSearchListModel.clearListModel()
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
        model: kdbSearchListModel

        ViewSearchPlaceholder {
            id: searchNoEntriesFoundPlaceholder
            text: "No Entries found"

            onClicked: {
                searchField.forceActiveFocus()
            }
        }


        header: Item {
            // This is just a placeholder for the header box. To avoid the
            // list view resetting the input box everytime the model resets,
            // the search entry is defined outside the list view.
            height: headerBox.height
        }

        DatabaseMenu {
            id: databaseMenu
            menuLabelText: Global.databaseUiName
            enableDatabaseSettingsMenuItem: true
        }

        ApplicationMenu {}

        VerticalScrollDecorator {}

        delegate: Global.env.mainPage.kdbListItemComponent
    }

    KdbListModel {
        id: kdbSearchListModel
    }

    onStatusChanged: {
        // set cover state
        if (status === PageStatus.Active) {
            applicationWindow.cover.coverState = Global.constants.databaseOpened
        }
    }

    Component.onCompleted: {
        kdbSearchListModel.searchRootGroupId = searchPage.searchGroupId
        kdbSearchListModel.clearListModel()
        searchField.forceActiveFocus()
    }
}
