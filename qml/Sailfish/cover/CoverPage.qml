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
    property int coverState: Global.constants.databaseClosed

    property alias entryTitle: entryLabel.text
    property alias url: urlLabel.text
    property alias username: usernameLabel.text
    property alias password: passwordLabel.text

//    property alias url: showEntryCover.url
//    property alias username: showEntryCover.username
//    property alias password: showEntryCover.password

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

    Item {
//        id: showEntryCover
        enabled: coverState === Global.constants.databaseEntryOpened
        visible: enabled

        anchors.fill: parent

//        Image {
//            id: image
//            y: Theme.paddingMedium
//            anchors.horizontalCenter: parent.horizontalCenter
//            opacity: 0.4
//            source: (Global.developmentMode === 1 ? "/opt/sdk/ownKeepass" : "") + "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
//        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: image.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: Theme.paddingSmall
            anchors.bottomMargin: Theme.paddingSmall
            width: parent.width - 2 * Theme.paddingSmall
            spacing: 0 //Theme.paddingSmall

            Label {
                width: parent.width
                color: Theme.secondaryColor
                opacity: 0.6
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                text: "ownKeepass"
            }

            Label {
                id: entryLabel
                width: parent.width
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
//                enabled: false
//                visible: enabled
                width: parent.width
                color: Theme.secondaryColor
                opacity: 0.6
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                text: urlLabel.text !== "" ? "Url" : "No url"
            }

            Label {
                id: urlLabel
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
//                enabled: usernameLabel.text !== ""
//                visible: enabled
                width: parent.width
                color: Theme.secondaryColor
                opacity: 0.6
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                text: usernameLabel.text !== "" ? "Username" : "No username"
            }

            Label {
                id: usernameLabel
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
//                enabled: passwordLabel.text !== ""
//                visible: enabled
                width: parent.width
                color: Theme.secondaryColor
                opacity: 0.6
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                text: passwordLabel.text !== "" ? "Password" : "No password"
            }

            Label {
                id: passwordLabel
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



//        Label {
//            id: label
//            anchors.centerIn: parent
//            width: parent.width - 2*Theme.paddingMedium
//            height: width
//            color: Theme.secondaryColor
//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            wrapMode: Text.Wrap
//            fontSizeMode: Text.Fit
//        }
//    }

//    Label {
//        id: label
//        anchors.centerIn: parent
//        text: "ownKeepass"
//    }
    
//    CoverActionList {
//        id: coverAction
        
//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }
        
//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
//    }
}


