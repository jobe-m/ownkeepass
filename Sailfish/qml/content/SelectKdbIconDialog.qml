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

Dialog {
    id: selectKdbIconDialog

    allowedOrientations: applicationWindow.orientationSetting

    Component {
        id: iconDelegate

        Item {
            width: Screen.width / 5
            height: width

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
                    }
                }
            }

            OpacityRampEffect {
                sourceItem: iconBackground
                slope: 0.25
                offset: 0.0
                clampFactor: -0.75
                direction: OpacityRamp.BottomToTop
            }

            Image {
                id: icon
                anchors.centerIn: parent
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                opacity: iconMouseArea.pressed ? 0.5 : 1.0
                source: "../../entryicons/icf" + index + ".png"
            }

//            Label {
//                anchors.centerIn: parent
//                color: "red"
//                text: index
//            }
        }
    }

    SilicaGridView {
        width: parent.width
        height: parent.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        header: DialogHeader {
            acceptText: qsTr("Use")
            cancelText: qsTr("Cancel")
        }

        model: 69
        cellWidth: Screen.width / 5
        cellHeight: cellWidth

        delegate: iconDelegate
    }
}
