/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
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
import "../common"

Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

            SilicaLabel {
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                text: "Help"
            }

            SilicaLabel {
                text: "ownKeepass is a password safe application with the purpose to \
store login information like username and password for web pages, credit card numbers, \
PINs, TANs and other bits of information which should be kept secret. All that information \
is saved in a database file which is encrypted and stored locally on the phone. To open \
the database you need to know the master password of the database. The used database \
format is compatible to Keepass version 1. That means you can use Keepass on your desktop \
system to decrypt and open that database file, too.<br><br>\
\
Please note that currently ownKeepass cannot load or save Keepass version 2 databases. This is \
planned for a future release of ownKeepass.<br><br>\
\
Some words about Keepass database security\
The database code in ownKeepass is based on the KeepassX project.\
\
\
"
            }
        }
    }
}
