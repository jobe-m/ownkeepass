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
                subTitle: qsTr("Password Safe")
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: qsTr("Change log")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "\
<b>v1.1.5 Sort in alphabetical order</b>\
<ul>\
<li>Password entries and groups in list view are now sorted alphabetically per default</li>\
<li>Sorting of list view is switchable in application settings</li>\
</ul>\
<br>\
<b>v1.1.4 Unified start page and hidden files in file browser</b>\
<ul>\
<li>Enabled handling of multiple databases on start page per default. In fact after introducing the file \
browser it is not neccessary to hide the database opening dialogs from the average user any more ;) So \
\"expert mode\" is gone for now.</li>\
<li>Now it is also possible to select hidden files and folders from file browser</li>\
<li>Fix a bug in recent database list with localization of database location</li>\
<li>Bugfix for language seletion: English could not be selected if system language was not set to English</li>\
<li>Fixed a bug on start page where after app start always the default database \"Documents/ownkeepass/notes.kdb\" was preloaded in database details</li>\
</ul>\
<br>\
<b>v1.1.1 Bugfix release</b>\
<ul>\
<li>Bugfix: File browser doesn't allow SD card selection</li>\
<li>Update French and Danish translations</li>\
<li>Added new translation for Norwegian Bokmål</li>\
</ul>\
<br>\
<b>v1.1.0 Database fast unlock and file browser</b>\
<ul>\
<li>Added fast unlock feature which allows quick access to a locked database. \
When you first open your password safe you are asked for your full password. But after you subsequently \
lock it you can unlock quickly with a partial password which consists of the first 3 characters of the master password.</li>\
<li>Amount of retries available on fast unlock page is adjustable from 0 (no retry) up to 5 retries</li>\
<li>Added file browser in order to select database file when opening or creating a new Keepass database. \
The recent opened database list needs to be reinitialized and thus is set to empty.</li>\
<li>Added new translations for Chinese, Danish, French, Italian and Russian</li>\
</ul>\
<br>\
<b>v1.0.24 Translation update</b>\
<ul>\
<li>Added new translation for Spanish</li>\
<li>Many translation updates and bugfixes</li>\
</ul>\
<br>\
<b>v1.0.23 Bugfixes and new translations</b>\
<ul>\
<li>Translation updates and bugfixes for Finnish and Swedish</li>\
<li>New translations for German, Catalan, Czech and Dutch.</li>\
</ul>\
<br>\
<b>v1.0.22 Translation update</b>\
<ul>\
<li>Added Finnish and Swedish translation</li>\
</ul>\
<br>\
<b>v1.0.21 Bugfix Release</b>\
<ul>\
<li>Search was not working on Sailfish OS 1.1.0.38 Uitukka</li>\
<li>Now also searching from a sub-group really only searches within that group and not in the entire database</li>\
</ul>\
<br>\
<b>v1.0.20 Updated dialogs</b>\
<ul>\
<li>Adapted dialog appearance for Sailfish OS 1.1.0.38 Uitukka</li>\
</ul>\
<br>\
<b>v1.0.19 Small bugfixes</b>\
<ul>\
<li>Change background of cover page to match default appearance</li>\
<li>Bugfix: When changing a database to use a key file the key file path was not saved \
in recently opened database list item</li>\
</ul>\
<br>\
<b>v1.0.18 Simplified main page</b>\
<ul>\
<li>Open one Keepass database from main page by typing the master password without bothering any \
other details (adjustable with \"Expert user mode\" in application settings)</li>\
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
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}
