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
    text: "On this page you can change default settings of the ownKeepass application.<br><br>\
\
<b>Default encryption</b><br><br>\
\
Adjust the default encryption algorithm which is used when you create a new Keepass database. \
The encryption algorithm can be changed also later after creation of your \
database in the database settings.<br><br>\
\
<b>Key transformation rounds</b><br><br>\
\
Set the default value for key transformation rounds for a new Keepass database. \
This value controls the amount of encryption rounds computed \
on the master password. Adjusting this value has direct effect on the time \
needed to decrypt the database on loading. But setting this value higher makes \
the database more robust against brute force attacks. \
As a good compromise between security and usability you should adjust the value so that opening \
the database takes one second on your phone.<br><br>\
\
<b>UI settings</b><br><br>\
\
The inactivity lock time value is used to automatically lock the Keepass \
database after the specified amount of time has elapsed after the ownKeepass \
application went in background. Thus the inactivity timer is also active \
when ownKeepass is minimized to the cover state on home screen.<br><br>\
\
If you want to see username and password of all password entries already \
in the list views you can switch \"Extended list view\" on.<br><br>\
\
<b>Cover settings</b><br><br>\
\
Here you can adjust functionality and information shown on the cover page. \
You can enable showing username and password in cleartext of the currently \
opened password entry on the cover. \
Moreover you can also enable or disable both cover actions. The first action is to lock \
the database. The second cover action triggers either copying of the \
username and password into the clipboard or deleting of the clipboard \
content.<br>"
}
