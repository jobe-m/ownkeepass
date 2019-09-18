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
import "../scripts/Global.js" as Global

Page {
    id: changeLogPage
    property bool newVersionAvailable: false

    allowedOrientations: applicationWindow.orientationSetting

    Component.onCompleted: {
        if (newVersionAvailable) {
            var title = qsTr("ownKeepass got updated")
            var message = qsTr("New version %1 now installed on your phone. Have a look in the change log for details.").arg(ownKeepassSettings.version)
            applicationWindow.infoPopup.show(Global.info, title, message)
        }
    }

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
                subTitleOpacity: 0.5
                subTitleBottomMargin: changeLogPage.orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
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
<b>v1.2.6 Translation update</b>\
<ul>\
<li>Added new translation for Belgisch-Nederlands</li>\
<li>Updated all translations from transifex</li>\
</ul>\
<br>\
<b>v1.2.5 KDBX 4 format support</b>\
<ul>\
<li>Add support for KDBX 4 database format by changing database code from KeepassX to KeepassXC (many thanks to 24mu13)</li>\
<li>Add support for new database cipher algorithms and key derivation functions like Twofish, Chacha20 and Argon2 for Keepass 2 databases</li>\
<li>Show used database cipher, key derivation function and key transformation rounds for a Keepass 2 database in database settings dialog</li>\
<li>Updated translations from transifex</li>\
</ul>\
<br>\
<b>v1.2.4 SD card</b>\
<ul>\
<li>Get SD card working again with Sailfish OS 2.2.0.29 Mouhijoki</li>\
</ul>\
<br>\
<b>v1.2.3 KDBX enhancements</b>\
<ul>\
<li>Implemented moving of password entries between groups (Keepass 2 database)</li>\
<li>Show comment of password groups in list view (Keepass 2 database)</li>\
<li>Fixed truncation mode of subtitle in list views</li>\
<li>Updated translations from transifex</li>\
</ul>\
<br>\
<b>v1.2.2 Keepass 2 write support</b>\
<ul>\
<li>Password entries in Keepass 2 databases can be created, edited and deleted</li>\
<li>Password groups in Keepass 2 databases can be created, edited and deleted</li>\
<li>Additional attributes of password entries in Keepass 2 databases can be added, changed and deleted</li>\
<li>Added possibility to copy into clipboard every item of a password entry by long-press on it</li>\
<li>Open URL in web browser by just one click on the URL text</li>\
<li>Reworked password entry editing page for Keepass 2 support</li>\
<li>Fixed scaling of icons on password generator page with higher resolution displays</li>\
<li>Updated and reordered text sections on about page</li>\
<li>Added new translations for Polish and Serbian (Not yet fully done, please help on transifex to finish them)</li>\
<li>Updated all other translations from transifex</li>\
<li>Bugfix: Specifying the wrong Keepass version on opening a database does not give a proper error notification; the display just kept showing the loading databasee message</li>\
<li>Bugfix: It was not possible to delete more than one keepass entry or group in a row</li>\
<li>Bugfix: When deleting the last password item from a group the placeholder text was not shown again</li>\
</ul>\
<br>\
<b>v1.2.1 Language bugfix</b>\
<ul>\
<li>If one of the following languages where selected directly another language was actually shown: galician, italian, hungarian, dutch, russian, finnish, swedish, chinese, greek, japanese</li>\
<li>Setting language to system default was not affected by the bug</li>\
</ul>\
<br>\
<b>v1.2.0 Changeable icons</b>\
<ul>\
<li>Implemented changing of icons for password group and entries for Keepass 1 and 2 databases</li>\
<li>Standard Keepass icons and custom database icons of Keepass 1 and 2 databases are supported</li>\
<li>Implemented \"create new\" and \"edit\" password group for Keepass 2 database</li>\
<li>Reworked error handling mechanism and added a lot of database error checks</li>\
<li>Updated source base of Keepass 2 database code to KeepassX release 2.0.2</li>\
<li>Code cleanup done, password generator code refactored</li>\
<li>Fixed some UI and layout glitches</li>\
<li>Updated all translations from transifex</li>\
</ul>\
<br>\
<b>v1.1.15 Bugfix release</b>\
<ul>\
<li>Fixed mapping of settings value for time to clear clipboard: In release 1.1.14 the time for clearing clipboard silently changed to 5 seconds if it was before set to \"disabled\"</li>\
</ul>\
<br>\
<b>v1.1.14 New icons</b>\
<ul>\
<li>Added individual icons for password entries and groups</li>\
<li>Time to clear clipboard can be adjusted between 5 seconds and 10 minutes</li>\
<li>Parent group of password entries is shown in search list view</li>\
<li>Copy-Paste cover action now skips empty username or password entries</li>\
<li>Implemented alphabetical sorting of Keepass 2 database entries</li>\
<li>Added new translation for Galician language (not yet finished, please help getting it done!)</li>\
<li>Updated all other translations</li>\
</ul>\
<br>\
<b>v1.1.13 Bugfix release</b>\
<ul>\
<li>File browser: When searching for a key file the default value for file filter is *.key</li>\
<li>Adjusted look and feel of info popups to system info popups</li>\
<li>Added snappy layout animations on main page to enhance usability</li>\
<li>Database can be dropped from recent database list on main page (in order to clean up the list from unused stuff)</li>\
<li>Added new translation for Hungarian (magyar)</li>\
<li>Added changes from Transifex to all translations</li>\
</ul>\
<br>\
<b>v1.1.12 Bugfix release</b>\
<ul>\
<li>Bugfix: Opening or creating a new Keepass database was not working when using accept button in the dialog</li>\
<li>Updated language files with translations from Transifex</li>\
</ul>\
<br>\
<b>v1.1.11 Fixes for Tablet UI</b>\
<ul>\
<li>Changed Password fields to use fixed size font which should enable to better distinguish between similar characters</li>\
<li>Updated icons and layout of main page to fit better on the tablet display</li>\
<li>Corrected a lot of page margins and text alignments due to layout changes for the tablet</li>\
<li>File browser now shows path of actual browsing directory</li>\
<li>Updated look of app icon and added scaled icons for tablet display</li>\
</ul>\
<br>\
<b>v1.1.10 Translation bugfix</b>\
<ul>\
<li>Updated all translation files</li>\
<li>Fixed bug with missing translations on the Jolla phone</li>\
</ul>\
<br>\
<b>v1.1.9 First tablet release</b>\
<ul>\
<li>First version supporting Jolla Tablet</li>\
<li>Updated and refactored about page</li>\
<li>Removed warning info popup for Keepass 2 read-only mode</li>\
<li>Search field switchable from pulley menu now also in Keepass 2 database mode</li>\
</ul>\
<br>\
<b>v1.1.8 Searching in Keepass 2 database</b>\
<ul>\
<li>Implemented search functionality for Keepass 2 databases</li>\
<li>Updated translations and added Japanese and Greek as new languages</li>\
<li>Refactored the info popup to work better with different device orientations</li>\
<li>Some minor fixes in UI in regard to new Sailfish OS 2.0 look</li>\
</ul>\
<br>\
<b>v1.1.7 Landscape orientation and Keepass 2 database read support</b>\
<ul>\
<li>Support for landscape orientation added (not only but for all TOHKBD owners :)</li>\
<li>Orientation can be adjusted in application settings (Portrait / Landscape / Dynamic)</li>\
<li>Added support for reading Keepass 2 databases</li>\
</ul>\
<br>\
<b>v1.1.6 Move password entries</b>\
<ul>\
<li>Password entries can be moved between groups now</li>\
<li>Updated icon look in list views</li>\
<li>Database can be directly closed from lock screen</li>\
<li>Added elide mode to top menu label (fixes too long database path running out of the screen)</li>\
</ul>\
<br>\
<b>v1.1.5 Sorting and file filter</b>\
<ul>\
<li>Password entries and groups in list view are now sorted alphabetically per default</li>\
<li>Sorting of list view is switchable in application settings</li>\
<li>File browser updated with a file filter which can be optionally used to filter for file types</li>\
<li>Other various code cleanup done including some small bugfixes</li>\
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
