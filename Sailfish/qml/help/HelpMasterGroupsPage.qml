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
    text: "This page is showing main password groups of your Keepass database. \
A password group is a container for password entries. Thus in order to store a \
password entry you need to create at least one group first.<br><br>\
\
You can use main password groups to organize your password entries. For \
example create groups for \"Online shops\", \"Email Accounts\", \"Social media \
pages\", etc.<br><br>\
\
A search bar can be enabled from pulley menu which is shown on top of the \
password group list. If you want that the search bar automatically gets focus \
when you open the Keepass database please open the setting page and check the \
corresponding switch.<br><br>"
}
