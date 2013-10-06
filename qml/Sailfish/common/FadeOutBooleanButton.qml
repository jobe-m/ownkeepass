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

// TODO add some descriptive test for this commonly usable button element

Button {

    property bool condition: true
    property bool trueCondition: true
    property bool falseCondition: false
    property string trueButtonText: ""
    property string falseButtonText: ""

    signal clicked

    anchors.horizontalCenter: parent.horizontalCenter
    // button is not accessible if user has not yet entered any text on "create new group" or
    // if user has not yet changed the name of the existing group
    enabled: condition ? trueCondition : falseCondition
    opacity: condition ? (trueCondition ? 1.0 : 0.2) : (falseCondition ? 1.0 : 0.2)
    text: condition ? trueButtonText : falseButtonText
    onClicked: clicked()

    Behavior on opacity { NumberAnimation { duration: 200 } }
}
