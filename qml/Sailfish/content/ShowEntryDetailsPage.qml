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
import "../scripts/Global.js" as Global

Page {
    id: showEntryDetailsPage

    property string pageTitle: ""
    // ID of the keepass entry to be shown
    property int entryId: 0

    function setTextFields(title, url, username, password, comment) {
        pageHeader.title = title
        entryUrlTextField.text = url
        entryUsernameTextField.text = username
        entryPasswordTextField.text = password
        entryCommentTextField.text = comment

        // set also cover
        applicationWindow.cover.coverState = Global.constants.databaseEntryOpened
        applicationWindow.cover.entryTitle = title
        applicationWindow.cover.url = url
        applicationWindow.cover.username = username
        applicationWindow.cover.password = password
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        ViewPlaceholder {
            enabled: !entryUrlTextField.enabled && !entryUsernameTextField.enabled &&
                     !entryPasswordTextField.enabled && !entryCommentTextField.enabled
            text: "No content"
            hintText: "Pull down to edit Password Entry and add Url, Username, Password and comment"
        }

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
                    text: qsTr("Show more Details")
// TODO implement "show more details"
                    onClicked: {}
                }

                MenuItem {
                    text: "Edit Password Entry"
                    onClicked: {
                        pageStack.push(editEntryDetailsDialogComponent,
                                       { "entryId": showEntryDetailsPage.entryId })
                    }
                }
            }

            TextField {
                id: entryUrlTextField
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: "Url"
                color: Theme.primaryColor
            }

            TextField {
                id: entryUsernameTextField
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: "Username"
                color: Theme.primaryColor
            }

            Item {
                enabled: entryPasswordTextField.text !== ""
                visible: entryPasswordTextField.text !== ""
                width: parent.width
                height: entryPasswordTextField.height

                TextField {
                    id: entryPasswordTextField
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    readOnly: true
                    echoMode: TextInput.Password
                    label: "Password"
                    color: Theme.primaryColor
                }

                IconButton {
                    id: showPasswordButton
                    width: icon.width
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    icon.source: "image://theme/icon-m-ambience"
                    highlighted: entryPasswordTextField.echoMode === TextInput.Normal
                    onClicked: {
                        if (entryPasswordTextField.echoMode === TextInput.Normal)
                            entryPasswordTextField.echoMode = TextInput.Password
                        else
                            entryPasswordTextField.echoMode = TextInput.Normal
                    }
                }
            }

            TextArea {
                id: entryCommentTextField
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: "Comment"
                color: Theme.primaryColor
            }
        }
    }

    Component.onCompleted: {
        console.log("showEntryDetailsPage" + pageTitle)
        // set reference in kdbListItemInternal object
        kdbListItemInternal.showEntryDetailsPageRef = showEntryDetailsPage
        // set entry ID and load entry details to show in this page
        kdbEntry.entryId = showEntryDetailsPage.entryId
        kdbEntry.loadEntryData()
    }
    Component.onDestruction: {
        // unset again
        kdbListItemInternal.showEntryDetailsPageRef = null
    }
}
