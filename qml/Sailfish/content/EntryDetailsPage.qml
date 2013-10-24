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
    id: entryDetailsPage

    property string pageTitle: ""
    // ID of the keepass entry to be edited
    property alias entryId: kdbEntry.entryId
    // creation of new entry needs parent group ID
    property int parentGroupId: 0
    property bool parentNeedUpdate: false

    // internal stuff
    property bool __changeBackToDefaultState: false

    function __saveChanges() {
        console.log("Save entry: " + entryTitle.text + ", " + entryPassword.text)
        if (entryDetailsPage.state === "") {
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
        if (__changeBackToDefaultState) {
            entryDetailsPage.state = ""
        } else {
            pageStack.pop()
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

            PageHeaderExtended {
                id: pageHeader
                title: pageTitle
                subTitle: "ownKeepass"
            }

            PullDownMenu {
                MenuItem {
// TODO write entry settings page
                    text: qsTr("Entry Settings")
                    onClicked: pageStack.push(Qt.resolvedUrl("EntrySettingsDialog.qml").toString())
                }

                MenuItem {
                    text: "Edit Password Entry"
                    onClicked: {
                        // change state of page
                        entryDetailsPage.state = "editEntry"
                        __changeBackToDefaultState = true
                    }
                }
            }

            TextField {
                id: entryTitle
                enabled: false
                visible: false
                width: parent.width
                readOnly: true
                label: "Title"
                placeholderText: "Set Title"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryUrl
                width: parent.width
                readOnly: true
                label: "Url"
                placeholderText: "Set Url"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryUsername
                width: parent.width
                readOnly: true
                label: "Username"
                placeholderText: "Set Username"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryPassword
                width: parent.width
                readOnly: true
                label: "Password"
                placeholderText: "Set Password"
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryVerifyPassword
                width: parent.width
                readOnly: true
                label: "Verify Password"
                placeholderText: "Verify Password"
                errorHighlight: entryPassword.text !== text
                EnterKey.highlighted: !errorHighlight
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: entryComment
                width: parent.width
                readOnly: true
                label: "Comment"
                placeholderText: "Set Comment"
                EnterKey.onClicked: parent.focus = true
            }

            Button {
                id: createOrSaveEntryButton
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: false
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                onClicked: __saveChanges()
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
            entryTitle.text = title;
            entryUrl.text = url;
            entryUsername.text = username;
            entryPassword.text = password;
            entryVerifyPassword.text = password;
            entryComment.text = comment;
        }
        onEntryDataSaved: { // returns result
// TODO check save result
        }
        onNewEntryCreated: { // returns result, newEntryId
// TODO problem of empty page shown when EntryDetailsPage is closed
//            console.log("new entry created: " + newEntryId + " result: " + result)
//            // after new entry was created from group view open the entry page
//            pageStack.push(Qt.resolvedUrl("EntryDetailsPage.qml").toString(),
//                           { entryId: newEntryId })
        }
    }

    Component.onCompleted: {
        console.log("Entry Details Page State: " + entryDetailsPage.state)
        if(entryDetailsPage.state !== "createNewEntry") {
            kdbEntry.loadEntryData()
        }

//        if (!createNewEntry) {
//            kdbEntry.loadEntryData()
//        }
        entryTitle.focus = true
    }

    states: [
        State {
            name: "createNewEntry"
            PropertyChanges { target: pageHeader; title: qsTr("New Password Entry") }
            PropertyChanges { target: entryTitle; readOnly: false; enabled: true; visible: true }
            PropertyChanges { target: entryUrl; readOnly: false }
            PropertyChanges { target: entryUsername; readOnly: false }
            PropertyChanges { target: entryPassword; readOnly: false }
            PropertyChanges { target: entryVerifyPassword; readOnly: false }
            PropertyChanges { target: entryComment; readOnly: false }
            PropertyChanges {
                target: createOrSaveEntryButton
                enabled: entryTitle.text !== "" && entryPassword.text === entryVerifyPassword.text
                opacity: entryTitle.text !== "" && entryPassword.text === entryVerifyPassword.text
                text: "Create"
            }
            StateChangeScript { script: console.log("state = createNewEntry") }
        },
        State {
            name: "editEntry"
            PropertyChanges { target: pageHeader; title: qsTr("Edit Password Entry") }
            PropertyChanges { target: entryTitle; readOnly: false; enabled: true; visible: true }
            PropertyChanges { target: entryUrl; readOnly: false }
            PropertyChanges { target: entryUsername; readOnly: false }
            PropertyChanges { target: entryPassword; readOnly: false }
            PropertyChanges { target: entryVerifyPassword; readOnly: false }
            PropertyChanges { target: entryComment; readOnly: false }
            PropertyChanges {
                target: createOrSaveEntryButton
                enabled: entryTitle.text !== "" && entryPassword.text === entryVerifyPassword.text
                opacity: entryTitle.text !== "" && entryPassword.text === entryVerifyPassword.text
                text: "Save"
            }
            StateChangeScript { script: console.log("state = editEntry") }
        }
    ]
}
