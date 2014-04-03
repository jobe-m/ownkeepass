/***************************************************************************
**
** Copyright (C) 2013-2014 Marko Koschak (marko.koschak@tisno.de)
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

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "About ownKeepass"
                subTitle: "Password Safe"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                text: "ownKeepass is a Keepass 1.x compatible password safe application"
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "Version " + ownKeepassSettings.version + "<br>\
Copyright &#169; 2013-2014 Marko Koschak<br>"
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                text: "ownKeepass is distributed under the terms \
of the GNU General Public License (GPL) version 2 or (at your \
option) version 3."
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "View license"
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "View change log"
                onClicked: pageStack.push(Qt.resolvedUrl("ChangeLogPage.qml"))
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "<b>Credits</b><br><br>\
Jolla for continuing where Nokia stopped<br>\
The KeepassX project<br>\
Petri Mäkijärvi for good hints and testing<br><br>\
\
<a href=\"https://github.com/jobe-m/ownkeepass\">https://github.com/jobe-m/ownkeepass</a><br><br>\
\
I hope you have as much fun using ownKeepass as I had creating it!"
                onLinkActivated: {
                    console.log(link + " link activated")
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}
