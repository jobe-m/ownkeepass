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


// TODO We have currently only simple mode
//            TextSwitch {
//                id: simpleMode
//                enabled: false
//                text: "Use Simple Mode"
//                description: "In simple mode below default Keepass database is automatically loaded on application start. " +
//                             " If you switch this off you get a list of recently opened Keepass database files instead."
//            }

            Column {
                width: parent.width

                TextField {
                    id: defaultDatabaseFilePath
                    width: parent.width
                    label: "Default database file path"
                    placeholderText: label
                    text: "/home/user/myDocs/"
                    EnterKey.onClicked: parent.focus = true
                }

                SilicaLabel {
// TODO We have currently only simple mode
//                    text: simpleMode.checked ?
//                              "This is the name and path of default Keepass database file" :
//                              "This is the path where new Keepass Password Safe files will be stored"
                    text: "This is the name and path of default Keepass database file"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: "Keepass Database"
            }

            TextSwitch {
                id: useKeyFile
                text: "Create Key File"
                description: "Switch this on if you want to create a key file together with a new Keepass Password Safe file"
            }

            TextField {
                id: defaultKeyFilePath
                enabled: useKeyFile.checked
                opacity: useKeyFile.checked ? 1.0 : 0.0
                height: useKeyFile.checked ? implicitHeight : 0
                width: parent.width
                label: "Default key file path"
                placeholderText: label
                text: ""
                EnterKey.onClicked: parent.focus = true
                Behavior on opacity { NumberAnimation { duration: 500 } }
                Behavior on height { NumberAnimation { duration: 500 } }
            }

            Column {
                width: parent.width

                ComboBox {
                    id: defaultEncryption
                    width: settingsPage.width
                    label: "Default Encryption in use:"
                    menu: ContextMenu {
                        MenuItem { text: "AES/Rijndael" }
                        MenuItem { text: "Twofish" }
                    }
                }

                SilicaLabel {
                    text: "Choose encryption which will be used as default for a new Keepass Password Safe file"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            SectionHeader {
                text: "UI Settings"
            }

            Slider {
                id: inactivityLockTime
                value: 3
                minimumValue: 0
                maximumValue: 10
                stepSize: 1
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                valueText: calculateInactivityTime(value)
                label: "Inactivity Lock Time"
                /*
                  0 = immediately
                  1 = 5 seconds
                  2 = 10 seconds
                  3 = 30 seconds
                  4 = 1 minute
                  5 = 2 minutes
                  6 = 5 minutes
                  7 = 10 minutes
                  8 = 30 minutes
                  9 = 60 minutes
                  10 = unlimited
                  */
                function calculateInactivityTime(value) {
                    switch (value) {
                    case 0:
                        return "Immediately"
                    case 1:
                        return "5 Seconds"
                    case 2:
                        return "10 Seconds"
                    case 3:
                        return "30 Seconds"
                    case 4:
                        return "1 Minute"
                    case 5:
                        return "2 Minutes"
                    case 6:
                        return "5 Minutes"
                    case 7:
                        return "10 Minutes"
                    case 8:
                        return "30 Minutes"
                    case 9:
                        return "60 Minutes"
                    case 10:
                        return "Unlimited"
                    }
                }
            }

            TextSwitch {
                id: extendedListView
                text: "Extended List View"
                description: "If you switch this on username and password are shown below entry title in list views"
            }
        }
    }
}
