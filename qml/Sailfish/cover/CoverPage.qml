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
import "../scripts/Global.js" as Global

CoverBackground {
    id: coverPage
    property int coverState: Global.constants.databaseClosed

    property alias entryTitle: entryTitleLabel.text
    property alias username: entryUsernameLabel.text
    property alias password: entryPasswordLabel.text

    signal lockDatabase()

    CoverPlaceholder {
        enabled: coverState === Global.constants.databaseClosed
        visible: enabled
        text: "Database locked"
        icon.source: (Global.developmentMode === 1 ? "/opt/sdk/ownKeepass" : "") + "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    CoverPlaceholder {
        enabled: coverState === Global.constants.databaseOpened
        visible: enabled
        text: "Database opened"
        icon.source: (Global.developmentMode === 1 ? "/opt/sdk/ownKeepass" : "") + "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    CoverPlaceholder {
        enabled: coverState === Global.constants.databaseUnsavedChanges
        visible: enabled
        text: "Warning! Unsaved changes"
        icon.source: (Global.developmentMode === 1 ? "/opt/sdk/ownKeepass" : "") + "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    Item {
        enabled: coverState === Global.constants.databaseEntryOpened
        visible: enabled

        anchors.fill: parent

        Label {
            id: appName
            y: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.secondaryColor
            opacity: 0.6
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            text: "ownKeepass"
        }

        Label {
            id: entryTitleLabel
            anchors.top: appName.bottom
            anchors.topMargin: -Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Item {
            anchors.top: entryTitleLabel.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.paddingSmall
                spacing: 0

                Label {
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.6
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    text: entryUsernameLabel.text !== "" ? "Username" : "No username"
                }

                Label {
                    id: entryUsernameLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.6
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    text: entryPasswordLabel.text !== "" ? "Password" : "No password"
                }

                Label {
                    id: entryPasswordLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }

    // Cover action on opened database
    CoverActionList {
        enabled: coverState === Global.constants.databaseOpened
        iconBackground: false

        CoverAction {
// TODO update icon
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                // emit signal to lock database
                lockDatabase()
            }
        }
    }

    // Cover action for entry
    CoverActionList {
        enabled: coverState === Global.constants.databaseEntryOpened
        iconBackground: false
        
        CoverAction {
// TODO update icon
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                // emit signal to lock database
                lockDatabase()
            }
        }
        
        CoverAction {
            property int clipboardState: Global.constants.clipboardUnused
// TODO updatge icon
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: {
                // copy entry detail into clipboard, round robin -> username, password, empty clipboard
                switch (clipboardState) {
                case Global.constants.clipboardUnused:
                    systemClipboard.text = coverPage.username
                    clipboardState = Global.constants.clipboardUsernameDropped
// TODO updatge icon
                    break
                case Global.constants.clipboardUsernameDropped:
                    systemClipboard.text = coverPage.password
                    clipboardState = Global.constants.clipboardPasswordDropped
// TODO updatge icon
                    break
                case Global.constants.clipboardPasswordDropped:
                    systemClipboard.text = ""
                    clipboardState = Global.constants.clipboardUnused
// TODO updatge icon
                    break
                }
            }
        }
    }

// TODO uncomment when clipboard is functional in SDK
//    Clipboard {
//        id: systemClipboard
//    }
}


