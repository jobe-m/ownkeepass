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

Dialog {
    id: entryDetailsDialog

    property bool createNewEntry: false
    // ID of the keepass entry to be edited
    property alias entryId: kdbEntry.entryId
    // creation of new entry needs parent group ID
    property int parentGroupId: 0
    property bool parentNeedUpdate: false

    // internal stuff
    property string __originalEntryTitle: ""
    property string __originalEntryUrl: ""
    property string __originalEntryUsername: ""
    property string __originalEntryPassword: ""
    property string __originalEntryComment: ""

    function __saveChanges() {
        console.log("Save entry: " + entryTitle.text + ", pw: " + entryPassword.text)
        if (createNewEntry) {
            // create new group in database, save and update list model data
            kdbEntry.createNewEntry(entryTitle.text,
                                    entryUrl.text,
                                    entryUsername.text,
                                    entryPassword.text,
                                    entryComment.text,
                                    parentGroupId)
        } else {
            // save changes of existing group to database and update list model data
            kdbEntry.saveEntryData(entryTitle.text,
                                   entryUrl.text,
                                   entryUsername.text,
                                   entryPassword.text,
                                   entryComment.text)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: "Save"
                title: createNewEntry ? "Create Password Entry" : "Edit Password Entry"
            }

            SilicaLabel {
                text: createNewEntry ? "Create new Password Entry:" :
                                       "Edit Password Entry:"
            }

            TextField {
                id: entryTitle
                width: parent.width
                label: "Title"
                placeholderText: "Set Title"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryUrl
                width: parent.width
                label: "Url"
                placeholderText: "Set Url"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryUsername
                width: parent.width
                label: "Username"
                placeholderText: "Set Username"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryPassword
                width: parent.width
                label: "Password"
                placeholderText: "Set Password"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryVerifyPassword
                width: parent.width
                label: "Verify Password"
                placeholderText: "Verify Password"
                errorHighlight: entryPassword.text !== text
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryComment
                width: parent.width
                label: "Comment"
                placeholderText: "Set Comment"
                EnterKey.onClicked: parent.focus = true
            }
        }
    }

    KdbEntry {
        id: kdbEntry
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
            entryTitle.text = title
            __originalEntryTitle = title
            entryUrl.text = url
            __originalEntryUrl = url
            entryUsername.text = username
            __originalEntryUsername = username
            entryPassword.text = password
            __originalEntryPassword = password
            entryVerifyPassword.text = password
            entryComment.text = comment
            __originalEntryComment = comment
        }
        onEntryDataSaved: { // returns result
// TODO check save result
        }
        onNewEntryCreated: { // returns result, newEntryId
// TODO problem of empty page shown when EntryDetailsDialog is closed
//            console.log("new entry created: " + newEntryId + " result: " + result)
//            // after new entry was created from group view open the entry page
//            pageStack.push(Qt.resolvedUrl("EntryDetailsPage.qml").toString(),
//                           { entryId: newEntryId })
        }
    }

    Component.onCompleted: {
        if (!createNewEntry) {
            kdbEntry.loadEntryData()
        }
        entryTitle.focus = true
    }

    onAccepted: __saveChanges()

    onRejected: {
        console.log("onReject in EditEntryDetailsDialog")
// TODO poping of EditEntryDetailsDialog page does not work because it is disrupted by the new Dialog below
// try to replace the QueryDialog by an RemorsePopup or RemorseItem
        if (__originalEntryTitle !== entryTitle.text || __originalEntryUrl !== entryUrl.text ||
                __originalEntryUsername !== entryUsername.text || __originalEntryPassword !== entryPassword.text ||
                __originalEntryComment !== entryComment.text) {
            var dialog = pageStack.push("../common/QueryDialog.qml", { "headerAcceptText": "Yes",
                                            "titleText": "Save Changes",
                                            "message": "Do you want to save your changes in the Password Entry?" })
            dialog.accepted.connect(function() {
                __saveChanges()
            })
            pageStack.pop()
        }
    }
}
