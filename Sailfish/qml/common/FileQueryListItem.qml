/***************************************************************************
**
** Copyright (C) 2017 Marko Koschak (marko.koschak@tisno.de)
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
import "../scripts/Global.js" as Global

ListItem {
    id: fileQueryListItem

    property int locationIndex: 0
    property string relativePath: ""
    property string absolutePath: ""
    property bool createNewFile: true
    property string fileFilter: ""

    width: parent.width
    height: filePathArea.height > filePathIcon.height ? filePathArea.height : filePathIcon.height
    menu: null

    onClicked: {
        var dialog = pageStack.push(Qt.resolvedUrl("../common/FileSystemDialog.qml").toString(), {
                                        "locationIndex": fileQueryListItem.locationIndex,
                                        "absolutePath": fileQueryListItem.absolutePath,
                                        "fileFilter": fileQueryListItem.fileFilter,
                                        "state": fileQueryListItem.createNewFile ? "CREATE_NEW_FILE" : "OPEN_FILE" })
        dialog.accepted.connect(function() {
            fileQueryListItem.locationIndex = dialog.locationIndex
            fileQueryListItem.relativePath = dialog.relativePath
            fileQueryListItem.absolutePath = dialog.absolutePath
        })
    }

    Label {
        id: filePathArea

        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: filePathIcon.left
        anchors.rightMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        text: Global.getLocationName(fileQueryListItem.locationIndex) + fileQueryListItem.relativePath
        opacity: 0.6
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
    }

    Image {
        id: filePathIcon
        source: "image://theme/icon-m-right"
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
    }
}
