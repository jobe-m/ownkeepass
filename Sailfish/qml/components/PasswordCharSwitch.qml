/***************************************************************************
**
** Copyright (C) 2017 Marko Koschak (marko.koschak@tisno.de)
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

Column {
    id: passwordCharSwitch

    property string a: "a"
    property string b: "b"
    property string c: "c"
    property string d: "d"
    property alias checked: charSwitch.checked

    width: (Screen.width/4) - Theme.paddingLarge
    spacing: -Theme.paddingLarge

    Switch {
        id: charSwitch
        anchors.horizontalCenter: parent.horizontalCenter
        checked: passwordCharSwitch.checked
    }

    Row {
        width: children.width
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            spacing: -Theme.paddingMedium

            Label {
                text: passwordCharSwitch.a
                color: charSwitch.pressed ? Theme.highlightColor : Theme.primaryColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                text: passwordCharSwitch.c
                color: charSwitch.pressed ? Theme.highlightColor : Theme.primaryColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                opacity: 0.6
            }
        }

        Column {
            spacing: -Theme.paddingMedium

            Label {
                text: passwordCharSwitch.b
                color: charSwitch.pressed ? Theme.highlightColor : Theme.primaryColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                opacity: 0.6
            }

            Label {
                text: passwordCharSwitch.d
                color: charSwitch.pressed ? Theme.highlightColor : Theme.primaryColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
            }
        }
    }
}
