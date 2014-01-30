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

Label {
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignLeft
    font.pixelSize: Theme.fontSizeSmall
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    linkColor: Theme.highlightColor
    text: "To open an existing Keepass database you need to provice the following details:<br><br>\
\
<b>Database Location</b><br><br>\
\
Here you specify from where the database file will be opened. To make opening as easy as possible you \
should place the database file in one of the following locations: \
\"Documents on Phone\", \"SD Card\", \"Android Storage\" or \"Dropbox Local Storage\". If you have trouble \
with ownKeepass not finding the file make sure it is in desired place by looking it up in a File Browser. \
Documents on Phone is usually ~/Documents, the SD Card is located at /run/user/100000/media/sdcard, the Android Storage \
is at /data/sdcard and the Dropbox Local Storage you will find at ~/dropbox. \
To sync your database with Dropbox you can use Sailbox which is available in Jolla Harbour for download.<br><br>\
\
Advice: If you upload your Keepass database to Dropbox please make sure you use a locally stored key file in addition \
to the master password. This key file should not be uploaded to the cloud service.<br><br>\
\
<b>Database path and file name</b><br><br>\
\
Please specify in this text field the file name of your Keepass database file which is located in one of above \
locations.<br><br>\
\
<b>Use Key File</b><br><br>\
\
If you need a key file for opening your Keepass database please check this option. The following two \
options will occure automatically on the page.<br><br>\
\
<b>Key File Location</b><br><br>\
\
The same as for database location also applies here. Except that the key file cannot be loaded from \"Dropbox Local \
Storage\" in order to protect your security by design.<br><br>\
\
<b>Key File Path and File Name</b><br><br>\
\
Please type in here the file name of the key file which is located in one of above \
locations.<br><br>\
\
<b>Master Password</b><br><br>\
\
Type in here the password for your Keepass database.<br><br>\
\
<b>Open automatically</b><br><br>\
\
Check this option if you want that ownKeepass automatically opens this database again when you start the application the \
next time. You will be forwarded directly to the password query dialog.<br><br>"
}
