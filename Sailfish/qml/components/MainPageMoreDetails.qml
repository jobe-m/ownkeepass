/***************************************************************************
**
** Copyright (C) 2013 - 2015 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass 1.0

Column {
    property alias databasePathAndNameText: databasePathAndName.text

    spacing: 0
    width: parent.width

    TextSwitch {
        id: showMoreInfoSwitch
        text: qsTr("Show more details")
    }

    Column {
        enabled: showMoreInfoSwitch.checked
        opacity: enabled ? 1.0 : 0.0
        height: enabled ? children.height : 0
        width: parent.width
        spacing: 0

        Behavior on opacity { FadeAnimation { duration: 400 } }
        Behavior on height { NumberAnimation { duration: 400 } }

        Label {
            id: databasePathAndName
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: Global.getLocationName(internal.dbFileLocation) + " " + internal.databasePath
        }

        Label {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            text: internal.keyFilePath.length !== 0 ?
                      qsTr("Key file path and name") : qsTr("No key file used")
        }

        Label {
            x: Theme.paddingLarge
//                        enabled: internal.keyFilePath.length !== 0
            visible: internal.keyFilePath.length !== 0
            width: parent.width - Theme.paddingLarge * 2
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: Global.getLocationName(internal.keyFileLocation) + " " + internal.keyFilePath
        }

        Item {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            height: databaseTypeLabel.height

            Label {
                id: databaseTypeLabel
                anchors.top: parent.top
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Database type:")
            }

            Label {
                anchors.top: parent.top
                anchors.left: databaseTypeLabel.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignLeft
                elide: Qt.ElideMiddle
                text: internal.databaseType === DatabaseType.DB_TYPE_KEEPASS_1 ?
                          "Keepass 1" :
                          internal.databaseType === DatabaseType.DB_TYPE_KEEPASS_2 ?
                              "Keepass 2" :
                              //: Here unknown is used for unknown database type
                              qsTr("Unknown")
            }
        }

        SectionHeader {
            enabled: !recentDatabaseModel.isEmpty
            opacity: enabled ? 1.0 : 0.0
//                        visible: enabled
            text: qsTr("Recent databases")

            Behavior on opacity { FadeAnimation { duration: 400 } }
        }

        Repeater {
            model: recentDatabaseModel
            delegate: recentDatabaseListItemComponent
        }
    }
}
