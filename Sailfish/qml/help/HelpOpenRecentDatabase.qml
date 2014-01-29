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
    text: "Type in here the password for opening the database. I you choosed a key file it will be automatically \
loaded from the path you specified earlier. If you get an error on opening the database and you are sure \
that your provided password is correct check if the key file is still in the same place when you opened the \
database the last time successfully.<br><br>\
\
<b>Open automatically</b><br><br>\
\
Check this opton if you want that ownKeepass automatically opens the password query dialog again for this \
database when you start the application the next time.<br><br>"
}
