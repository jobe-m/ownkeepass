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
    id: settingsPage

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
            SectionHeader {
                text: "Settings"
            }

            SilicaLabel {
                text: "This is the path where new Keepass Password Safe files will be stored:"
            }

            TextField {
                id: defaultFilePath
                width: parent.width
                label: "Default file path"
                placeholderText: label
                text: "/home/user/myDocs/"
//                horizontalAlignment: textAlignment
                EnterKey.onClicked: parent.focus = true
            }

            SectionHeader {
                text: "Keepass Database"
            }

            TextSwitch {
                id: useKeyFile
                text: "Create key file"
                description: "Switch this on if you want to create a key file together with a new Keepass Password Safe file"
            }

            Column {
                width: parent.width
//                spacing: Theme.paddingSmall / 2

                ComboBox {
                    id: usedEncryption
                    width: settingsPage.width
                    label: "Default encryption in use:"
                    menu: ContextMenu {
                        MenuItem { text: "AES/Rijndael" }
                        MenuItem { text: "Twofish" }
                    }
                }

                SilicaLabel {
                    text: "Choose encryption which will be used as default for a new Keepass Password Safe file"
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            SectionHeader {
                text: "UI Settings"
            }

            Slider {
                id: inactivityLockTime
                value: 30
                minimumValue: 5
                maximumValue: 300
                stepSize: 5
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                valueText: value.toFixed(0)
                label: "Inactivity lock time (seconds)"
            }

            TextSwitch {
                id: hideEmptyEntries
                text: "Hide empty Password entries"
            }

            TextSwitch {
                id: extendedListView
                text: "Extended list view"
                description: "If you switch this on the username and passwords are shown in the entries of the list view"
            }

            SectionHeader {
                text: "File Browser"
            }

            TextSwitch {
                id: showOnlyKeepassFiles
                text: "Show only related files"
                description: "Switch this on to see only files with file extention .kdb and .key"
            }
        }
    }
}
