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

HelpPage {
    //: Removed one sentence in section "Use key file", Changed "Home" to "Device Memory", Removed section for "Open automatically", changed <UUID> to &lt;UUID&gt; so that it will be actually shown ;)
    text: qsTr("Here you can open an existing Keepass database file.<br><br>\
\
Use the file browser to search for your Keepass database file. You will be able to look into the \
following locations: Device Memory, SD card and Android storage. If you have trouble \
with ownKeepass not finding the file please make sure to place it in below mentioned paths. \
\"Device Memory\" is located at \"%1\". If a SD card is inserted in your phone it is located at \"/media/sdcard/&lt;UUID&gt;\". \
(Please note that SD cards with more than one partition are not supported.) \"Android storage\" \
is located at \"%2\".<br><br>\
\
Advice: If you upload your Keepass database into the cloud please make sure you use a locally stored key file in addition \
to the master password. This key file should not be uploaded to the cloud service.<br><br>\
\
<b>Use key file</b><br><br>\
\
If you need a key file for opening your Keepass database please check this option.<br><br>\
\
<b>Master password</b><br><br>\
\
Type in here the password for your Keepass database.<br><br>")
    .arg(ownKeepassHelper.getHomePath())
    .arg(ownKeepassHelper.getAndroidStoragePath())
}
