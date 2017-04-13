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

ListItem {
    id: entryTextArea

    property string text: ""
    property alias label: entryLabel.text
    property string menuLabel: ""
    property bool passwordMode: false

    // private
    property bool _passwordEchoMode: false
    property string _passwordEcho: ""

    signal itemClicked
    signal menuClicked

    enabled: text !== ""
    visible: enabled
    contentHeight: enabled ? labelColumn.height : 0
    width: parent ? parent.width : Screen.width
    menu: menuLabel.length === 0 ? null : contextMenuComponent

    onClicked: {
        // Check if the user pressed on the password mode button
        if ((passwordMode) && (mouse.x > entryTextArea.width - passwordModeButton.width)) {
            _passwordEchoMode = !_passwordEchoMode
        } else {
            itemClicked()
        }
    }

    onTextChanged: {
        if (passwordMode) {
            var echo = "\u2022"
            var i = 1
            _passwordEcho = "\u2022"
            while (i < text.length) {
                _passwordEcho += echo
                i++
            }
        }
    }

    Column {
        id: labelColumn
        width: parent.width
        spacing: Theme.paddingSmall

        Item {
            height: Theme.paddingSmall
            width: parent.width
        }

        Item {
            height: entryText.height
            width: parent.width

            SilicaLabel {
                id: entryText
                anchors.top: parent.top
                width: entryTextArea.passwordMode ?
                           Screen.width - Theme.horizontalPageMargin - passwordModeButton.width :
                           Screen.width - Theme.horizontalPageMargin * 2
                font.pixelSize: Theme.fontSizeMedium
                text: entryTextArea._passwordEchoMode ? _passwordEcho : entryTextArea.text
                color: entryTextArea.highlighted ? Theme.highlightColor : Theme.primaryColor
                Component.onCompleted: {
                    if (entryTextArea.passwordMode) {
                        font.family = 'monospace'
                    }
                }
            }

            Text {
                id: passwordModeButton
                visible: entryTextArea.passwordMode
                anchors.top: parent.top
                width: Theme.itemSizeMedium
                x: parent.width - width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeMedium
                text: entryTextArea._passwordEchoMode ? "abc" : "\u2022\u2022\u2022"
                textFormat: Text.PlainText
                color: entryTextArea.pressed ? Theme.highlightColor : Theme.primaryColor
            }

        }

        SilicaLabel {
            id: entryLabel
            font.pixelSize: Theme.fontSizeSmall
            color: entryTextArea.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

        Item {
            height: Theme.paddingSmall
            width: parent.width
        }
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
            id: contextMenu

            MenuItem {
                id: entryMenuItem
                text: entryTextArea.menuLabel
                onClicked: menuClicked()
            }
        }
    }
}
