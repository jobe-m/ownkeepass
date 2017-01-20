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
    id: selectKdbIconDialog

    property string newIconUuid: ""

    // private stuff
    readonly property int _width: mainPage.orientation & Orientation.LandscapeMask ? Screen.height / 9 : Screen.width / 5
    readonly property int _height: Screen.width / 5

    canNavigateForward: newIconUuid.length !== 0
    allowedOrientations: applicationWindow.orientationSetting

    onAccepted: {
        // save new icon Id
        editGroupDetailsDialog.iconUuid = newIconUuid
    }

    SilicaFlickable {
        anchors.fill: parent

        DialogHeader {
            id: header
            acceptText: qsTr("Select")
            cancelText: qsTr("Cancel")
            spacing: 0
        }

        SilicaListView {
            width: parent.width
            anchors.top: header.bottom
            anchors.bottom: parent.bottom

            // Show a scollbar when the view is flicked, place this over all other content
            VerticalScrollDecorator {}

            model: iconSectionsModel
            section.property: "sectionName"
            section.criteria: ViewSection.FullString
            section.delegate:  SectionHeader {
                id: sectionHeader
                text: section
            }

            delegate: SilicaGridView {
                width: selectKdbIconDialog.width
                height: contentHeight

                model: iconListModel
                cellWidth: selectKdbIconDialog._width
                cellHeight: selectKdbIconDialog._height

                delegate: iconDelegate
            }
        }
    }

    ListModel {
        id: iconSectionsModel

        ListElement {
            sectionName: qsTr("Keepass Icons")
        }

        ListElement {
            sectionName: qsTr("Custom Database Icons")
        }

        ListElement {
            sectionName: qsTr("ownKeepass Icon Pack")
        }
    }

    IconListModel {
        id: iconListModel
    }

    Component {
        id: iconDelegate

        Item {
            width: selectKdbIconDialog._width
// TODO adapt size for jolla tablet
            //Screen.sizeCategory >= Screen.Large ?
            //       (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.195) : (Screen.height * 0.122)) :
            //       (mainPage.orientation & Orientation.LandscapeMask ? (Screen.height * 0.081) : (Screen.height * 0.063))
            height: selectKdbIconDialog._height

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

/*            OpacityRampEffect {
                sourceItem: iconBackground
                slope: 0.25
                offset: 0.0
                clampFactor: -0.75
                direction: OpacityRamp.BottomToTop
            }
*/
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
        // Load standard group icons + custom database icons if there are any
        iconListModel.initListModel(IconListModel.LOAD_STANDARD_GROUP_ICONS)
    }
}
