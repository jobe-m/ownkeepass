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
    text: qsTr("On this page you can create a new database where ownKeepass will store your sensitive data.<br><br>\
\
<b>Database location</b><br><br>\
\
First you need to specify where the database file will be stored. Available options are \"Documents on phone\", \
\"SD card\", \"Android storage\" and \"Sailbox local storage\". \
Take the first option \"Documents on phone\" if you want the database to be \
located on the phone or choose \"SD card\" to place the database on the removable SD card. There should be only one \
formatted partition on the SD card. Currently multi-partition SD cards are not supported by ownKeepass. \
If SD card is not inserted the SD card location item is disabled. \
Please make sure the SD card is properly detected by looking at it in a File Browser. \
If you want to share the Keepass database with Android Apps you can place it into \"Android storage\". \
However sharing files with the Android world can be annoying due to different file ownership and permissions. \
Please be aware of that. The last option \"Sailbox local storage\" can be used together with Sailbox. \
If you place your database there Sailbox can up- and download the file to \
the Dropbox online service. Sailbox is available in Jolla Harbour for download.<br><br>\
\
Advice: If you upload your Keepass database to Dropbox please make sure you use a locally stored key file in addition \
to the master password. This key file should not be uploaded to the cloud service.<br><br>\
\
<b>Database path and file name</b><br><br>\
\
Please specify in this text field the relative path and file name for your Keepass database file. For example you \
can type in \"ownkeepass/notes.kdb\". If you have opened ownKeepass the first time you will see that string already \
pre-filled for your convenience.<br><br>\
\
<b>Use key file</b><br><br>\
\
A key file can be used additionally to a master password to protect the Keepass database. Both are used together to \
generate a pass key which will open the database. So by using a file with lots of data inside the generated pass key \
becomes in principle stronger against attacks. You can use for example a random picture as key file.<br><br>\
\
<b>Key file location</b><br><br>\
\
The same as for database location also applies here. Except that the key file location cannot be set to \"Sailbox local \
storage\" in order to protect your security by design.<br><br>\
\
<b>Key file path and file name</b><br><br>\
\
Give here the relative path and file name of a file which you want to use as a key file for your database. E.g. you can \
choose here a picture as a key file.<br><br>\
\
<b>Master password</b><br><br>\
\
Here goes the password for your new Keepass database. Please make sure you choose a long password of around 10 - 15 \
characters and use a mixture of small and big letters, numbers and special characters. Repeat the password in the \
\"Confirm Password\" field.<br><br>\
\
<b>Open automatically</b><br><br>\
\
Check this option if you want that ownKeepass automatically opens this database again when you start the application the \
next time. You will be forwarded directly to the password query dialog.<br><br>")
}
