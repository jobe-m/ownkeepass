/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass.KeepassX1 1.0

Page {
    id: lockPage

    SilicaFlickable {
        id: lockView
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator { }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable
        ApplicationMenu {
            helpContent: "LockPage"
        }

        Column {
            id: col
            width: parent.width
            spacing: 0

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: qsTr("Password Safe")
            }

            Image {
                width: 492
                height: 492
                source: "../../wallicons/wall-ownKeys.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SilicaLabel {
                text: qsTr("Unlock your Keepass Password Safe:") + "\n"
            }

            Item {
                width: parent.width
                height: passwordField.height

                TextField {
                    id: passwordField
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    label: qsTr("Master password")
                    placeholderText: qsTr("Enter master password")
                    text: ""
                    EnterKey.highlighted: text !== ""
                    EnterKey.iconSource: text.length === 0 ?
                                             "image://theme/icon-m-enter-close" : "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        if (text.length !== 0) {
                            parent.focus = true
                            database.unlock(passwordField.text)
                            passwordField.text = ""
                        }
                    }
                    focusOutBehavior: -1
                }

                IconButton {
                    id: showPasswordButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: passwordField.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" :
                                                                               "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        if (passwordField.echoMode === TextInput.Normal) {
                            passwordField.echoMode = TextInput.Password
                        } else {
                            passwordField.echoMode = TextInput.Normal
                        }
                    }
                }
            }
        }
    }

/*    KdbDatabase {
        id: database
        onDatabaseOpened: {
            console.log("Database unlocked again")
        }

        onErrorOccured: {
            console.log("Error on database unlock")
        }
    }
*/
    Component.onCompleted: {
        Global.env.kdbDatabase.lock()
    }
}
