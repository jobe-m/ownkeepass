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

// plugins in local imports directory
import KeepassX 1.0
import MeeGoSettings 1.0

Page {
    id: showEntryDetailsPage

    // ID of the keepass entry which should be shown
    property int entryId: 0
    property string pageTitle: qsTr("Entry")

    function loadModelData() {
        kdbEntry.loadEntryData()
    }

    tools: commonTools

    Component.onCompleted: loadModelData()

    KdbEntry {
        id: kdbEntry
        entryId: showEntryDetailsPage.entryId
        onEntryDataLoaded: {
//            console.log("title: " + title)
//            console.log("url: " + url)
//            console.log("username: " + username)
//            console.log("password: " + password)
//            console.log("comment: " + comment)
//            console.log("binaryDesc: " + binaryDesc)
//            console.log("creation: " + creation)
//            console.log("lastMod: " + lastMod)
//            console.log("lastAccess: " + lastAccess)
//            console.log("expire: " + expire)
//            console.log("binarySize: " + binarySize)
//            console.log("friendlySize: " + friendlySize)
            showEntryDetailsPage.pageTitle = title;
            labelUrl.entryText = url;
            labelUsername.entryText = username;
            labelPassword.entryText = password;
            labelComment.entryText = comment;
        }
        onEntryDataSaved: {
            // reload entry data
            loadEntryData()
        }
    }

    GConfItem {
        id: settings_showEmptyEntries
        key: "/apps/ControlPanel/KeepassM/ShowEmptyEntries"
    }

    PageHeader {
        id: pageHeader
        pageTitle: showEntryDetailsPage.pageTitle
    }

    Flickable {
        id: flickable
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        contentHeight: col.height
        Column {
            id: col
            width: parent.width
            height: children.height

            CaptionLabel {
                id: labelUrl
                visible: entryText !== "" || settings_showEmptyEntries.value
                enabled: entryText !== "" || settings_showEmptyEntries.value
                captionText: "Url:"
            }

            Item {
                width: parent.width; height: Constants.SPACE_LABEL
                visible: labelUrl.entryText !== "" || settings_showEmptyEntries.value
                enabled: labelUrl.entryText !== "" || settings_showEmptyEntries.value
            }

            CaptionLabel {
                id: labelUsername
                visible: entryText !== "" || settings_showEmptyEntries.value
                enabled: entryText !== "" || settings_showEmptyEntries.value
                captionText: "Username:"
            }

            Item {
                width: parent.width; height: Constants.SPACE_LABEL
                visible: labelUsername.entryText !== "" || settings_showEmptyEntries.value
                enabled: labelUsername.entryText !== "" || settings_showEmptyEntries.value
            }

            CaptionLabel {
                id: labelPassword
                visible: entryText !== "" || settings_showEmptyEntries.value
                enabled: entryText !== "" || settings_showEmptyEntries.value
                captionText: "Password:"
            }

            Item {
                width: parent.width; height: Constants.SPACE_LABEL
                visible: labelPassword.entryText !== "" || settings_showEmptyEntries.value
                enabled: labelPassword.entryText !== "" || settings_showEmptyEntries.value
            }

            CaptionLabel {
                id: labelComment
                visible: entryText !== "" || settings_showEmptyEntries.value
                enabled: entryText !== "" || settings_showEmptyEntries.value
                captionText: "Comment:"
            }

            Item {
                width: parent.width; height: Constants.SPACE_LABEL * 4
                visible: labelComment.entryText !== "" || settings_showEmptyEntries.value
                enabled: labelComment.entryText !== "" || settings_showEmptyEntries.value
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    CommonToolBar {
        id: commonTools
        enableEditIcon: true
        enableCommonMenu: false
        onBackIconClicked: pageStack.pop()
        onEditIconClicked: pageStack.push(Qt.resolvedUrl("EditEntryDetailsPage.qml").toString(),
                                          { entryId: showEntryDetailsPage.entryId })
    }
}
