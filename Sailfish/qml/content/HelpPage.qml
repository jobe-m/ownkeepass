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
protect sensible data like passwords for web pages, credit card numbers, \
PINs, TANs and other bits of information which should be kept secret. All that information \
is saved in a database file which is encrypted and stored locally on the phone. To open \
the database you need to know the master password of the database. The used database \
format is compatible to Keepass version 1. That means you can use Keepass on your desktop \
system to decrypt and open that database file, too.<br><br>\
\
Please note that currently ownKeepass cannot load or save Keepass version 2 databases. This is \
planned for a future release of ownKeepass.<br><br>\
\
<b>Some words about Keepass database security</b><br>\
The database code in ownKeepass is based on the KeepassX project and as such conains a lot of \
security related features. It uses proven crypto algorithms like Advanced Encryption Standard \
(AES / Rijndael) or Twofish with 128 bits block size and 256 bits key size, SHA-256 as hashing \
algorithm and in-memory encryption of all passwords. Furthermore it protects the master \
password against Dictonary Attacks by hashing and encrypting it before \
using it to decrypt the Keepass database. This feature is called key transformation rounds and can be \
adjusted in database settings. Anyway that all just adds additional security to two points which \
you should be aware of: Always use a long enough and difficult to guess master password and protect \
your system from spyware which might be specialized to attack ownKeepass. The second is law #1 of the \
<a href=\"http://technet.microsoft.com/en-us/library/cc722487.aspx\">10 Immutable Laws of Security</a>: \
\"If a bad guy can persuade you to run his program on your \
computer, it's not your computer anymore\".<br><br>\
\
<b>Sharing Keepass database between your jolla phone and your desktop/tablet/etc.</b>\
\
"
            }
        }
    }
}
