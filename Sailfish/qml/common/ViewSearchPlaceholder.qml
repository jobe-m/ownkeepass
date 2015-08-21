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

Item {
    id: viewSearchPlaceholder
    property alias text: mainLabel.text
    property alias hintText: hintLabel.text

    signal clicked

    enabled: true
    opacity: enabled ? 1.0 : 0

    onEnabledChanged: {
        if (enabled && !_content) {
            _content = activeContent.createObject(viewSearchPlaceholder)
        }
    }

    // Internal stuff
    property Item _content
    Behavior on opacity { FadeAnimation { duration: 300 } }

    Item {
        width: parent.width
        height: mainLabel.height + hintLabel.height
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: mainLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font {
                pixelSize: Theme.fontSizeExtraLarge
                family: Theme.fontFamilyHeading
            }
            color: Theme.highlightColor
            opacity: 0.6
        }

        Text {
            id: hintLabel
            anchors.top: mainLabel.bottom
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font {
                pixelSize: Theme.fontSizeLarge
                family: Theme.fontFamilyHeading
            }
            color: Theme.highlightColor
            opacity: 0.4
        }
    }

    Component {
        // content we don't need until we're active
        id: activeContent
        MouseArea {
            anchors.fill: parent

            onClicked: {
                viewSearchPlaceholder.clicked()
            }
        }
    }
}
