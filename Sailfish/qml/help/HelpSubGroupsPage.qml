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
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
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
    text: "This page is showing password entries and sub-groups of your \
Keepass database. A password entry finally stores the bits of information \
secretly in the database.<br><br>\
\
It is possible to show username and password for each password entry already \
in the list view. To enable that feature open the ownKeepass settings and \
check the \"Extended list view\" switch.<br><br>\
\
A search bar can be enabled from pulley menu which is shown on top of \
the password group list. With it you can search only in the specific password \
group and all its sub-groups.<br><br>"
}
