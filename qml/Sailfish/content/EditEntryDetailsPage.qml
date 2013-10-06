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

// plugin is in local imports directory
import KeepassX 1.0

Page {
    id: editEntryDetailsPage

    // ID of the keepass entry to be edited
    property int entryId: 0
    // creation of new entry needs parent group ID
    property int parentGroupId: 0
    property bool parentNeedUpdate: false
    property bool createNewEntry: false

    Component.onCompleted: {
        if (!createNewEntry) {
            kdbEntry.loadEntryData()
        }
        entryTitle.setFocus()
    }

    KdbEntry {
        id: kdbEntry
        entryId: editEntryDetailsPage.entryId
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
            entryTitle.editText = title;
            entryUrl.editText = url;
            entryUsername.editText = username;
            entryPassword.editText = password;
            entryComment.editText = comment;
        }
        onEntryDataSaved: { // returns result
// TODO check save result
        }
        onNewEntryCreated: { // returns result, newEntryId
// TODO problem of empty page shown when ShowEntryDetailsPage is closed
//            console.log("new entry created: " + newEntryId + " result: " + result)
//            // after new entry was created from group view open the entry page
//            pageStack.push(Qt.resolvedUrl("ShowEntryDetailsPage.qml").toString(),
//                           { entryId: newEntryId })
        }
    }

    PageHeader {
        id: pageHeader
        enableButtons: true
        onRejected: pageStack.pop()
        onAccepted: {
            console.log("Save clicked")
            if (entryTitle.getNewText() !== "") {
                if (editEntryDetailsPage.createNewEntry) {
                    // create new group in database, save and update list model data
                    kdbEntry.createNewEntry(entryTitle.getNewText(),
                                            entryUrl.getNewText(),
                                            entryUsername.getNewText(),
                                            entryPassword.getNewText(),
                                            entryComment.getNewText(),
                                            editEntryDetailsPage.parentGroupId)
                } else {
                    // save changes of existing group to database and update list model data
                    kdbEntry.saveEntryData(entryTitle.getNewText(),
                                           entryUrl.getNewText(),
                                           entryUsername.getNewText(),
                                           entryPassword.getNewText(),
                                           entryComment.getNewText())
                }
                pageStack.pop()
            } else {
                infoDialog.open()
            }
        }
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

            Item {
                width: parent.width
                height: caption.height
                Label {
                    id: caption
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
// TODO add to constants
                    anchors.topMargin: 10
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    elide: Text.ElideRight
                    platformStyle: LabelStyle {
                        textColor: theme.inverted ? Constants.COLOR_INVERTED_SECONDARY_FOREGROUND : Constants.COLOR_SECONDARY_FOREGROUND
                        fontFamily: Constants.FONT_FAMILY
                        fontPixelSize: Constants.FONT_DEFAULT
                    }
                    text: createNewEntry ? qsTr("Create new Keepass Entry") : qsTr("Edit Keepass Entry")
                }
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }

            CaptionTextField {
                id: entryTitle
                captionText: "Title:"
                onReturnKeyClicked: entryUrl.setFocus()
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }

            CaptionTextField {
                id: entryUrl
                captionText: "Url:"
                inputMethod: Qt.ImhNoAutoUppercase
                onReturnKeyClicked: entryUsername.setFocus()
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }

            CaptionTextField {
                id: entryUsername
                captionText: "Username:"
                inputMethod: Qt.ImhNoAutoUppercase
                onReturnKeyClicked: entryPassword.setFocus()
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }


            CaptionTextField {
                id: entryPassword
                captionText: "Password:"
                inputMethod: Qt.ImhNoAutoUppercase
                onReturnKeyClicked: entryComment.setFocus()
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }

            CaptionTextArea {
                id: entryComment
                captionText: "Comment:"
                onReturnKeyClicked: entryComment.closeKeypad()
            }

            Item { width: parent.width; height: Constants.SPACE_LABEL }
        }
    }

    QueryDialog {
        id: infoDialog
        titleText: "Empty title"
        message: "Please specify a title for your password entry."
        acceptButtonText: "OK"
        onAccepted: entryTitle.setFocus()
    }
}
