/***************************************************************************
**
** Copyright (C) 2016 Marko Koschak (marko.koschak@tisno.de)
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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Global.js" as Global
import "../common"
import harbour.ownkeepass 1.0

Dialog {
    id: editItemIconDialog

    property string newIconUuid: ""

    property int itemType: DatabaseItemType.ENTRY

    readonly property int _width: mainPage.orientation & Orientation.LandscapeMask ? Screen.height / 9 : Screen.width / 5
    readonly property int _height: Screen.width / 5

    canNavigateForward: newIconUuid.length !== 0
    allowedOrientations: applicationWindow.orientationSetting

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width

            DialogHeader {
                id: header
                acceptText: qsTr("Select")
                cancelText: qsTr("Cancel")
                spacing: 0
            }

            SilicaLabel {
                text: itemType === DatabaseItemType.GROUP ? qsTr("Choose an icon for the password group:") :
                                                       qsTr("Choose an icon for the password entry:")
            }

            SectionHeader {
                text: qsTr("Keepass Icons")
            }

            SilicaGridView {
                id: keepassIconGridView
                width: editItemIconDialog.width

                model: keepassIconListModel
                cellWidth: editItemIconDialog._width
                cellHeight: editItemIconDialog._height

                delegate: iconDelegate

                Connections {
                    // for breaking the binding loop on height
                    onContentHeightChanged: keepassIconGridView.height = keepassIconGridView.contentHeight
                }
            }

            SectionHeader {
                enabled: !customDatabaseIconListModel.isEmpty
                visible: enabled
                text: qsTr("Custom Database Icons")
            }

            SilicaGridView {
                id: customDatabaseIconGridView
                width: editItemIconDialog.width

                model: customDatabaseIconListModel
                cellWidth: editItemIconDialog._width
                cellHeight: editItemIconDialog._height

                delegate: iconDelegate

                Connections {
                    // for breaking the binding loop on height
                    onContentHeightChanged: customDatabaseIconGridView.height = customDatabaseIconGridView.contentHeight
                }
            }

            SectionHeader {
                enabled: !ownKeepassIconPackListModel.isEmpty
                visible: enabled
                text: qsTr("ownKeepass Icon Pack")
            }

            SilicaGridView {
                id: ownKeepassIconPackGridView
                width: editItemIconDialog.width

                model: ownKeepassIconPackListModel
                cellWidth: editItemIconDialog._width
                cellHeight: editItemIconDialog._height

                delegate: iconDelegate

                Connections {
                    // for breaking the binding loop on height
                    onContentHeightChanged: ownKeepassIconPackGridView.height = ownKeepassIconPackGridView.contentHeight
                }
            }
        }
    }

    IconListModel {
        id: keepassIconListModel
    }

    IconListModel {
        id: customDatabaseIconListModel
    }

    IconListModel {
        id: ownKeepassIconPackListModel
    }

    Component {
        id: iconDelegate

        Item {
            width: editItemIconDialog._width
// TODO adapt size for jolla tablet
            //Screen.sizeCategory >= Screen.Large ?
            //       (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.195) : (Screen.height * 0.122)) :
            //       (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.081) : (Screen.height * 0.063))
            height: editItemIconDialog._height

            Rectangle {
                color: Theme.highlightColor
                visible: model.uuid === newIconUuid
                anchors.fill: parent
                opacity: 0.5
            }
            
            Rectangle {
                id: iconBackground
                anchors.centerIn: parent
                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium
                color: "white"
                opacity: 0.2

                MouseArea {
                    id: iconMouseArea
                    anchors.fill: parent
                    onClicked: {
                        // toggle icon selection
                        if(model.uuid === newIconUuid) {
                            newIconUuid = "";
                        } else {
                            newIconUuid = model.uuid;
                        }
                    }
                }
            }

            Image {
                id: icon
                anchors.centerIn: parent
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                opacity: iconMouseArea.pressed ? 0.5 : 1.0
                source: "image://KeepassIcon/" + model.uuid
            }

//            Label {
//                anchors.centerIn: parent
//                color: "red"
//                text: index
//            }
        }
    }

    Component.onCompleted: {
        // Load Keepass group icons, custom database icons from Keepass 2 database and ownKeepass icon pack icons into list models
        if (itemType === DatabaseItemType.ENTRY) {
            keepassIconListModel.initListModel(IconListModel.LOAD_KEEPASS_ENTRY_ICONS)
        } else if (itemType === DatabaseItemType.GROUP) {
            keepassIconListModel.initListModel(IconListModel.LOAD_KEEPASS_GROUP_ICONS)
        }
        customDatabaseIconListModel.initListModel(IconListModel.LOAD_CUSTOM_DATABASE_ICONS)
        ownKeepassIconPackListModel.initListModel(IconListModel.LOAD_OWNKEEPASS_ICON_PACK_ICONS)

    }
}
