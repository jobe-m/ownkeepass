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
    text: "Here you can create a new database where ownKeepass will store your sensitive data.<br><br>\
\
<b>Database Location</b><br><br>\
\
First you need to specify where the database file will be stored. Available options are \"Documents on phone\", \
\"SD Card\" and \"Sailbox local storage\". \
Take the first option \"Documents on phone\" if you want the database to be \
located on the phone or choose \"SD Card\" to place the database on the removable SD Card. You need to have a FAT32 \
formated SD Card inserted into the phone. There is currently no warning if the SD Card is not present or not correctly \
recognized. Please make sure the SD Card is properly detected by looking at it in a File Browser. \
The third option \"Sailbox local storage\" can be used together with Sailbox. \
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
<b>Use Key File</b><br><br>\
\
A key file can be used additionally to a master password to protect the Keepass database. Both are used together to \
generate a pass key which will open the database. So by using a file with lots of data inside the generated pass key \
becomes in principle stronger against attacks. You can use for example a random picture as key file.<br><br>\
\
<b>Key File Location</b><br><br>\
\
The same as for database location also applies here. Except that the key file location cannot be set to \"Dropbox Local \
Storage\" in order to protect your security by design.<br><br>\
\
<b>Key File Path and File Name</b><br><br>\
\
Give here the relative path and file name of a file which you want to use as a key file for your database. E.g. you can \
choose here a picture as a key file.<br><br>\
\
<b>Master Password</b><br><br>\
\
Here goes the password for your new Keepass database. Please make sure you choose a long password of around 10 - 15 \
characters and use a mixture of small and big letters, numbers and special characters. Repeat the password in the \
\"Confirm Password\" field.<br><br>\
\
<b>Open automatically</b><br><br>\
\
Check this option if you want that ownKeepass automatically opens this database again when you start the application the \
next time. You will be forwarded directly to the password query dialog.<br><br>"
}
