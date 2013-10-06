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

            KeepassPageHeader {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }
            SectionHeader {
                text: "Help"
            }

            SilicaLabel {
                text: "ownKeepass is a password safe application where you can store your passwords or other " +
                      "secret data like PIN or TAN numbers. All data is encrypted and can only be " +
                      "accessed by knowing the master password of the password safe. " +
                      "ownKeepass can open Keepass database files compatible with Keepass version 1 on Windows or " +
                      "KeepassX 0.4.3 on Windows/MacOS/Linux. Please note that it cannot open Keepass version 2 " +
                      "database files. If you share your Keepass database with a desktop system it is " +
                      "recommended that you use KeepassX 0.4.3. By doing so you archive maximum compatibility " +
                      "since the database code of KeepassMe is based on KeepassX 0.4.3." +
                      "\n\n" +
                      "Settings:\n\n" +
                      "The default location for you Keepass database file is \"/user/home/MyDocs/notes.kdb\". " +
                      "You can change it in the Application Settings at \"Path to Keepass database file\".\n" +
                      "If you want to use a key file together with your Keepass database file add a valid path and file name " +
                      "into \"Path to Keepass key file (optional)\", e.g. \"/user/home/MyDocs/keyfile\". " +
                      "" +
                      "\n\n" +
                      "Password Groups:\n\n" +
                      "" +
                      "" +
                      "\n\n" +
                      "Password Entries:\n\n" +
                      "" +
                      "" +
                      "\n\n" +
                      "Search:\n\n" +
                      "" +
                      "" +
                      "\n"            }
        }
    }
}
