/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
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
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: "Change log"
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "\
<b>v1.0.17 Intermediate beta release</b>\
<ul>\
<li>Open a Keepass database by typing in the master password without bothering any \
other details (adjustable with \"Single database loading\" in application settings)</li>\
<li>Clipboard cleared after 10 seconds (adjustable in application settings)</li>\
<li>Possibility to show master password when opening a database</li>\
</ul>\
<br>\
<b>v1.0.15 Password generator implemented</b>\
<ul>\
<li>A password generator can be opened when editing a password entry by clicking on the gear-wheel</li>\
<li>Refactored the about page, put license info on separate page and added change log page</li>\
<li>A popup info banner appears now after installation of a new ownKeepass version</li>\
<li>Updated icon for info popup banner</li>\
</ul>\
<br>\
<b>v1.0.12 Bugfix release for Sailfish OS version 1.0.4.20</b>\
<ul>\
<li>Fixed corrupted search bar after updating Sailfish OS version to 1.0.4.20</li>\
<li>Fixed bug with SD card location not accessible after updating Sailfish OS to version 1.0.4.20</li>\
<li>If no SD card inserted the location item for SD card is disabled</li>\
</ul>\
<br>\
<b>v1.0.9 Search bar implemented</b>\
<ul>\
<li>New search bar gives now faster access to search for specific password entry after opening the Keepass database</li>\
</ul>\
<br>\
<b>v1.0.5 Bugfix release </b>\
<ul>\
<li>Keepass database is copied to new location if \"Sailbox local storage\" is used to store the database</li>\
</ul>\
<br>\
<b>v1.0.4 Changed Sailbox local storage location</b>\
<ul>\
<li>New version of Sailbox in Jolla store changed the download location. Because of that \"Sailbox local storage\" location was changed from $HOME/dropbox to $HOME/Downloads</li>\
</ul>\
<br>\
<b>v1.0.3 Bug fixes, cover update and more help text</b>\
<ul>\
<li>Display a warning when the user selects \"Android storage\" as Database location</li>\
<li>Cover page layout has now a more consistent look</li>\
<li>Changing to a new password entry now resets the cover page copy-to-clipboard function</li>\
<li>On creation or opening of a database from local dropbox folder a warning info banner is displayed with security advices</li>\
<li>On \"Create new database\" page it is now mandatory to use a key file if the new database location is the local dropbox folder</li>\
</ul>\
<br>\
<b>v1.0.0 First release going to Jolla Harbour</b>\
<ul>\
<li>Loading Keepass version 1 databases</li>\
<li>Create, edit and delete password groups and entries</li>\
<li>Changes to database are saved automatically in background</li>\
<li>Recent Database list for fast access to the 5 last used database files</li>\
<li>Active cover which shows currently opened password entry + cover actions for locking database and copy user name and password into clipboard</li>\
<li>Database settings (master password, encryption and key transformation rounds) can be adjusted</li>\
<li>Some nice graphics and Sailfish like UI behaviour</li>\
</ul>\
"
                onLinkActivated: {
                    console.log(link + " link activated")
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}

/*
<b>v1.0. </b>\
<ul>\
<li></li>\
<li></li>\
<li></li>\
</ul>\
<br>\
*/
