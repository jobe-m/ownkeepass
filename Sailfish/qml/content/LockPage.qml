/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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
import "../scripts/Global.js" as Global
import harbour.ownkeepass.KeepassX1 1.0

Page {
    id: lockPage

    backNavigation: false

    SilicaFlickable {
        id: lockView
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator { }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable
        ApplicationMenu {
            helpContent: "LockPage"
        }

        Column {
            id: col
            width: parent.width
            spacing: 0

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: qsTr("Password Safe")
            }

            Image {
                width: 492
                height: 492
                source: "../../wallicons/wall-ownKeys.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SilicaLabel {
                text: qsTr("Unlock your Keepass Password Safe:") + "\n"
            }

            Item {
                width: parent.width
                height: firstFast.height

                TextField {
                    id: firstFast
                    width: parent.width / 7
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -(parent.width / 6)
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    placeholderText: "x"
                    text: ""
                    EnterKey.highlighted: text !== ""
                    EnterKey.iconSource: text.length === 0 ?
                                             "image://theme/icon-m-enter-close" : "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        if (text.length !== 0) {
                        }
                    }
                    Keys.onPressed: {
                        secondFast.focus = true
                    }

                    focusOutBehavior: -1
                    Tracer {}
                }

                TextField {
                    id: secondFast
                    width: parent.width / 7
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    placeholderText: "x"
                    text: ""
                    EnterKey.highlighted: text !== ""
                    EnterKey.iconSource: text.length === 0 ?
                                             "image://theme/icon-m-enter-close" : "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        if (text.length !== 0) {
                        }
                    }
                    Keys.onPressed: {
                        thirdFast.focus = true
                    }

                    focusOutBehavior: -1
                    Tracer {}
                }

                TextField {
                    id: thirdFast
                    width: parent.width / 7
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: parent.width / 6
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    echoMode: TextInput.Password
                    placeholderText: "x"
                    text: ""
                    EnterKey.highlighted: text !== ""
                    EnterKey.iconSource: text.length === 0 ?
                                             "image://theme/icon-m-enter-close" : "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        if (text.length !== 0) {
                            lockPage.backNavigation = true
                        }
                    }
                    Keys.onPressed: {

                    }

                    focusOutBehavior: -1
                    Tracer {}
                }
            }
        }
    }
}
