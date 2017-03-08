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
import harbour.ownkeepass 1.0
import "../common"
import "../scripts/Global.js" as Global

Page {
    id: showEntryDetailsPage

    // ID of the keepass entry to be shown
    property string entryId: ""

    allowedOrientations: applicationWindow.orientationSetting

// TODO feature/save_kdb2_entry
// get list view from kdbEntry somehow
    ListModel {
        id: customKeyValueList
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        ViewPlaceholder {
            enabled: !entryUrlTextArea.enabled && !entryUsernameTextArea.enabled &&
                     !entryPasswordTextField.enabled && !entryCommentTextArea.enabled
            verticalOffset: wallImage.height / 2

            text: qsTr("No content")
            hintText: !ownKeepassDatabase.readOnly ?
                          qsTr("Pull down to add URL, username, password and comment") : ""

            Image {
                id: wallImage
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../wallicons/wall-key.png"
                width: height
                height: implicitHeight * Screen.height / 1920
            }
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
                    // trigger cleaning of clipboard after specific time
                    applicationWindow.mainPageRef.clipboardTimerStart()
                }
            }

            MenuItem {
                enabled: entryPasswordTextField.text !== ""
                visible: enabled
                text: qsTr("Copy password")
                onClicked: {
                    Clipboard.text = entryPasswordTextField.text
                    // trigger cleaning of clipboard after specific time
                    applicationWindow.mainPageRef.clipboardTimerStart()
                }
            }

            MenuItem {
                enabled: !ownKeepassDatabase.readOnly && (ownKeepassDatabase.type !== DatabaseType.DB_TYPE_KEEPASS_2)
                visible: !ownKeepassDatabase.readOnly
                text: qsTr("Edit password entry")
                onClicked: {
                    pageStack.push(editEntryDetailsDialogComponent,
                                   { "entryId": entryId })
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
                title: kdbEntry.title
                subTitle: "ownKeepass"
                subTitleOpacity: 0.5
                subTitleBottomMargin: orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
            }

            TextArea {
                id: entryUrlTextArea
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: qsTr("URL")
                color: Theme.primaryColor
                text: kdbEntry.url
            }

            TextArea {
                id: entryUsernameTextArea
                width: parent.width
                enabled: text !== ""
                visible: text !== ""
                readOnly: true
                label: qsTr("Username")
                color: Theme.primaryColor
                text: kdbEntry.userName
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
                    font.family: 'monospace'
                    text: kdbEntry.password

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
                    font.family: 'monospace'

                    Behavior on opacity { FadeAnimation {} }
                }

                IconButton {
                    id: showPasswordButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
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
                text: kdbEntry.notes
            }

            Repeater {
                model: customKeyValueList
// TODO feature/save_dkb2_entry

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
        // set entry ID and load entry details to show in this page
        kdbEntry.entryId = entryId
        kdbEntry.loadEntryData()
    }

    onStatusChanged: {
        // if page gets active set cover state
        if (status === PageStatus.Active) {
            applicationWindow.cover.state = "ENTRY_VIEW"
            applicationWindow.cover.title = pageHeader.title
        }
    }
}
