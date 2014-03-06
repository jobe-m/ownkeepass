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
    text: "On this dialog you can change database internal settings of your currently opened Keepass \
database file.<br><br>\
\
<b>Master password</b><br><br>\
Here you can type in a new master password for the Keepass database. Please note that if you forgot your master \
password there is no way to recover the password. It is not saved in the Keepass database and there is also no backdoor \
to open the database without your password. Furhtermore make sure you choose a long password of around 10 - 15 \
characters and use a mixture of small and big letters, numbers and special characters. Repeat the password in the \
\"Confirm Master Password\" field.<br><br>\
\
<b>Encryption currently in use</b><br><br>\
This is the encryption algorithm which is used to cipher the Keepass database content.<br><br>\
\
<b>Key transformation rounds</b><br><br>\
\
Set the default value for key transformation rounds for your Keepass database. \
This value controls the amount of encryption rounds computed \
on the master password. Adjusting this value has direct effect on the time \
needed to decrypt the database on loading. But setting this value higher makes \
the database more robust against brute force attacks. \
As a good compromise between security and usability you should adjust the value so that opening \
the database takes one second on your phone.<br><br>"
}
