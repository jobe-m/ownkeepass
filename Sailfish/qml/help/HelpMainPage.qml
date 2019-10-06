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

HelpPage {
    text: qsTr("ownKeepass is a password safe application for Sailfish devices \
with the purpose to protect sensible data like passwords for web \
pages, credit card numbers, PINs, TANs and other bits of information which \
should be kept secret. All that information is saved in a database file which \
is encrypted and stored locally on your phone. To open the database you need \
to know the master password of the database. ownKeepass uses a Keepass \
version 2 database. That means you can use Keepass [1] or KeepassXC [2] \
on your desktop system to decrypt and open that database file, too.") + "<br><br>" +

          qsTr("<b>Usage of help pages</b><br><br>\
\
Each page inside of ownKeepass has its own Help content. So please make use \
of it and learn about the features offered by ownKeepass.") + "<br><br>" +

          qsTr("<b>Some words about Keepass database security</b><br><br>\
\
The database code in ownKeepass is based on the KeepassXC project [2] and as \
such contains a lot of security related features. It uses proven encryption \
algorithms like AES, Twofish or ChaCha20 and \
SHA-256 and Argon2 as hashing algorithms. Furthermore it protects \
the master password against Brute-Force and Dictonary Attacks by hashing and \
encrypting it before using it to decrypt the Keepass database. This feature \
is called key transformation rounds and can be adjusted in database settings. \
Anyway that all just adds additional security to two points which \
you should be aware of:<br><br>\
(1) Always use a long enough and difficult to guess master password.<br><br>\
(2) Protect your system from spyware which might be specialized to attack \
ownKeepass. The second is law #1 of the 10 Immutable Laws of Security: \
\"If a bad guy can persuade you to run his program on your \
computer, it's not your computer anymore\".") + "<br><br>" +

          qsTr("<b>Sharing Keepass database between your Jolla \
Smartphone / Tablet and your desktop PC</b><br><br>\
\
The Keepass database file format is perfect to share your password safe \
between different systems like smartphones, tablets, desktop PC and so on. \
That is because there are a lot of Keepass implementations available for \
those platforms. Have a look at the KeepassXC download page [3] to get \
a community developed Keepass version for the desktop PC.<br>\
\
You can share your Keepass database file via SD card or via a cloud service \
like ownCloud or Dropbox. When using a cloud server I would recommend to use \
a key file in addition to the master password. \
The additional key file will be used by ownKeepass to decrypt the database. \
Store this key file only locally on your smartphone and on your desktop PC. \
Do not upload it to the cloud service. If an attacker hacks your cloud \
service he will be left without the key file. By doing so you make it even \
harder for an attacker to crack your Keepass database because the key \
file content is usually impossible to guess.") +

"<br><br>\
[1] <a href=\"https://keepass.info\">keepass.info</a><br>\
[2] <a href=\"https://keepassxc.org\">keepassXC.org</a><br>\
[3] <a href=\"https://keepassxc.org/download\">keepassXC.org/download</a><br><br>\
"
}
