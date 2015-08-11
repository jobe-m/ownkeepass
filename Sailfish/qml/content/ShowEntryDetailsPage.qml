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
    property string entryId: ""

    function setTextFields(keys, values) {
        var maxKeys = keys.length
        var i = 5
        customKeyValueList.clear()
        while (i < maxKeys) {
            console.log(keys[i] + " " + values[i])
            customKeyValueList.append({"key": keys[i], "value": values[i]})
            ++i
        }
        pageHeader.title = values[0]
        entryUrlTextArea.text = values[1]
        entryUsernameTextArea.text = values[2]
        entryPasswordTextField.text = values[3]
        entryCommentTextArea.text = values[4]

        // set also cover
        applicationWindow.cover.title = values[0]
        applicationWindow.cover.username = values[2]
        applicationWindow.cover.password = values[3]
    }

    allowedOrientations: applicationWindow.orientationSetting

    ListModel {
        id: customKeyValueList
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        SilicaViewPlaceholder {
            enabled: !entryUrlTextArea.enabled && !entryUsernameTextArea.enabled &&
                     !entryPasswordTextField.enabled && !entryCommentTextArea.enabled
            image.source: "../../wallicons/wall-key.png"
            text: qsTr("No content")
            hintText: !ownKeepassDatabase.readOnly ?
                          qsTr("Pull down to add URL, username, password and comment") : ""
        }

        PullDownMenu {
            MenuItem {
                enabled: false
                visible: ownKeepassDatabase.readOnly
                text: qsTr("Read only mode")
            }

            MenuItem {
                enabled: entryUrlTextArea.text !== ""
                visible: enabled
                text: qsTr("Copy URL")
                onClicked: {
                    Clipboard.text = entryUrlTextArea.text
                }
            }

            MenuItem {
                enabled: entryUsernameTextArea.text !== ""
                visible: enabled
                text: qsTr("Copy username")
                onClicked: {
                    Clipboard.text = entryUsernameTextArea.text
                    // trigger cleaning of clipboard after 10 seconds
                    applicationWindow.mainPageRef.clipboardTimerStart()
                }
            }

            MenuItem {
                enabled: entryPasswordTextField.text !== ""
                visible: enabled
                text: qsTr("Copy password")
                onClicked: {
                    Clipboard.text = entryPasswordTextField.text
                    // trigger cleaning of clipboard after 10 seconds
                    applicationWindow.mainPageRef.clipboardTimerStart()
                }
            }

            MenuItem {
                enabled: !ownKeepassDatabase.readOnly
                visible: enabled
                text: qsTr("Edit password entry")
                onClicked: {
                    pageStack.push(editEntryDetailsDialogComponent,
                                   { "entryId": showEntryDetailsPage.entryId })
                }
            }

            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
            }
        }

        ApplicationMenu {}

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

            TextArea {
                id: entryUrlTextArea
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: qsTr("URL")
                color: Theme.primaryColor
            }

            TextArea {
                id: entryUsernameTextArea
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: qsTr("Username")
                color: Theme.primaryColor
            }

            Item {
                enabled: entryPasswordTextField.text !== ""
                visible: entryPasswordTextField.text !== ""
                width: parent.width
                height: Math.max(entryPasswordTextField.height, entryPasswordTextArea.height)

                TextField {
                    id: entryPasswordTextField
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1.0
                    readOnly: true
                    echoMode: TextInput.Password
                    label: qsTr("Password")
                    color: Theme.primaryColor
                    Behavior on opacity { FadeAnimation {} }
                }

                TextArea {
                    id: entryPasswordTextArea
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.0
                    readOnly: true
                    label: qsTr("Password")
                    text: entryPasswordTextField.text
                    color: Theme.primaryColor
                    Behavior on opacity { FadeAnimation {} }
                }

                IconButton {
                    id: showPasswordButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: entryPasswordTextArea.opacity === 1.0 ? "../../wallicons/icon-l-openeye.png" : "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        if (entryPasswordTextField.opacity === 1.0) {
                            entryPasswordTextArea.opacity = 1.0
                            entryPasswordTextField.opacity = 0.0
                        } else {
                            entryPasswordTextArea.opacity = 0.0
                            entryPasswordTextField.opacity = 1.0
                        }
                    }
                }
            }

            TextArea {
                id: entryCommentTextArea
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: qsTr("Comment")
                color: Theme.primaryColor
            }

            Repeater {
                model: customKeyValueList

                TextArea {
                    width: parent.width
                    readOnly: true
                    label: key
                    text: value
                    color: Theme.primaryColor
                }
            }
        }
    }

    Component.onCompleted: {
        // set reference in kdbListItemInternal object
        kdbListItemInternal.showEntryDetailsPageRef = showEntryDetailsPage
        // set entry ID and load entry details to show in this page
        kdbEntry.entryId = showEntryDetailsPage.entryId
        kdbEntry.loadEntryData()
    }
    Component.onDestruction: {
        // unset again
        kdbListItemInternal.showEntryDetailsPageRef = null
        // reset cover state to database opened
    }

    onStatusChanged: {
        // if page gets active set cover state
        if (status === PageStatus.Active) {
            applicationWindow.cover.state = "ENTRY_VIEW"
            applicationWindow.cover.title = pageHeader.title
        }
    }
}
