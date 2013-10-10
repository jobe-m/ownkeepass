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
import KeepassPlugin 1.0

Page {
    id: editGroupDetailsPage

    // ID of the keepass entry which should be edited
    property alias groupId: kdbGroup.groupId
    // creation of new group needs parent group ID
    property int parentGroupId: 0
    property bool createNewGroup: false

    // internal stuff
    property string __originalGroupName: ""

    function __saveChangesAndClose() {
        console.log("New group title: " + groupTitle.text)
        if (createNewGroup) {
            // create new group in database, save and update list model data
            kdbGroup.createNewGroup(groupTitle.text, parentGroupId)
        } else {
            // save changes of existing group to database and update list model data
            kdbGroup.saveGroupData(groupTitle.text)
        }
        pageStack.pop()
    }

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

            PageHeader {
                title: createNewGroup ? qsTr("Create new group") : qsTr("Edit group")
            }

            SilicaLabel {
                text: createNewGroup ? qsTr("Type in a name for the new group:") : qsTr("Change name of group:")
            }

            TextField {
                id: groupTitle
                width: parent.width
                label: "Name of group"
                placeholderText: label
                EnterKey.onClicked: parent.focus = true
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                // button is not accessible if user has not yet entered any text on "create new group" or
                // if user has not yet changed the name of the existing group
                enabled: createNewGroup ? groupTitle.text !== "" : __originalGroupName !== groupTitle.text
                opacity: createNewGroup ? (groupTitle.text !== "" ? 1.0 : 0.2) : __originalGroupName !== groupTitle.text ? 1.0 : 0.2
                text: createNewGroup ? "Create" : "Save"
                onClicked: __saveChangesAndClose()

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    KdbGroup {
        id: kdbGroup
//        groupId: groupId
        onGroupDataLoaded: {
            groupTitle.text = title
            __originalGroupName = title
         }
        onGroupDataSaved: { // returns result
// TODO check delete result
        }
        onNewGroupCreated: { // returns result, NewGroupId
// TODO check delete result
        }
    }

    Component.onCompleted: {
        if (!createNewGroup) {
            console.log("Group ID: " + groupId)
            console.log("Load Data for Group ID: " + kdbGroup.groupId)
            kdbGroup.loadGroupData()
        }
        groupTitle.focus = true
    }
}
