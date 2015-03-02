/***************************************************************************
**
** Copyright (C) 2013-2015 Marko Koschak (marko.koschak@tisno.de)
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
    text: qsTr("On this page you can create a new database where ownKeepass will store your sensitive data.<br><br>\
\
Open the file browser and choose a file name and a directory. You can choose to locate your database in the home \
directory of the phone, on the SD card or in the Android Storage. If the SD card entry is grey then no SD \
card is inserted or the card is not correctly detected by the System. There should be only one \
formatted partition on the SD card. Currently multi-partition SD cards are not supported by ownKeepass. \
\"Android storage\" is there to share the database with Android Apps. \
However sharing files with the Android world can be annoying due to different file ownership and permissions. \
Please be aware of that.<br><br>\
\
Advice: If you upload your Keepass database into the cloud please make sure you use a locally stored key file in addition \
to the master password. This key file should not be uploaded to the cloud service.<br><br>\
\\
<b>Use key file</b><br><br>\
\
A key file can be used additionally to a master password to protect the Keepass database. Both are used together to \
generate a pass key which will open the database. So by using a file with lots of data inside the generated pass key \
becomes in principle stronger against attacks. You can use for example a random picture as key file.<br><br>\
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
