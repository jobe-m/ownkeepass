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
import "../scripts/Global.js" as Global

Cover {
    id: coverPage
    anchors.centerIn: parent
    width: Theme.coverSizeLarge.width
    height: Theme.coverSizeLarge.height

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightColor, 0.2)

        Image {
            id: coverBackgroundImage
            enabled: coverState === Global.constants.databaseEntryOpened
            visible: enabled
            width: parent.width * 0.85
            height: width
            anchors.top: parent.top
            anchors.right: parent.right
            source: "../../wallicons/cover-cloud.png"
            opacity: 0.1
        }
    }

    property int coverState: Global.constants.databaseClosed
    property alias entryTitle: entryTitleLabel.text
    property alias username: entryUsernameLabel.text
    property alias password: entryPasswordLabel.text

    signal lockDatabase()

    // internal
    property int clipboardState: Global.constants.clipboardUnused
    function copyToClipboard() {
        // copy entry detail into clipboard, round robin -> username, password, empty clipboard
        switch (clipboardState) {
        case Global.constants.clipboardUnused:
            infoTextView.text = "Username copied into clipboard"
            entryDetailsView.opacity = 0.0
            infoTextView.opacity = 1.0
            infoTextTimer.restart()
            Clipboard.text = coverPage.username
            clipboardState = Global.constants.clipboardUsernameDropped
            break
        case Global.constants.clipboardUsernameDropped:
            infoTextView.text = "Password copied into clipboard"
            entryDetailsView.opacity = 0.0
            infoTextView.opacity = 1.0
            infoTextTimer.restart()
            Clipboard.text = coverPage.password
            clipboardState = Global.constants.clipboardPasswordDropped
            break
        case Global.constants.clipboardPasswordDropped:
            infoTextView.text = "Clipboard empty"
            entryDetailsView.opacity = 0.0
            infoTextView.opacity = 1.0
            infoTextTimer.restart()
            Clipboard.text = ""
            clipboardState = Global.constants.clipboardUnused
            break
        }
    }

    Timer {
        id: infoTextTimer
        repeat: false
        interval: 2000
        onTriggered: {
            infoTextFadeOut.start()
            entryDetailsFadeIn.start()
        }
    }

    NumberAnimation {
        id: infoTextFadeOut
        target: infoTextView
        property: "opacity"
        duration: 500
        to: 0.0
    }
    NumberAnimation {
        id: entryDetailsFadeIn
        target: entryDetailsView
        property: "opacity"
        duration: 500
        to: 1.0
    }

    SilicaCoverPlaceholder {
        enabled: coverState === Global.constants.databaseClosed
        visible: enabled
        text: "Database locked"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    SilicaCoverPlaceholder {
        enabled: coverState === Global.constants.databaseOpened
        visible: enabled
        text: "Database opened"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    SilicaCoverPlaceholder {
        enabled: coverState === Global.constants.databaseUnsavedChanges
        visible: enabled
        text: "You have some unsaved changes"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    SilicaCoverPlaceholder {
        enabled: !ownKeepassSettings.showUserNamePasswordOnCover && (coverState === Global.constants.databaseEntryOpened)
        visible: enabled
        text: entryTitle + " entry opened"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-ownkeepass.png"
    }

    Item {
        enabled: ownKeepassSettings.showUserNamePasswordOnCover && (coverState === Global.constants.databaseEntryOpened)
        visible: enabled

        anchors.fill: parent

        Label {
            id: appName
            y: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.secondaryColor
            opacity: 0.6
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            text: "ownKeepass"
        }

        Label {
            id: entryTitleLabel
            anchors.top: appName.bottom
            anchors.topMargin: -Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Item {
            id: entryDetailsView
            anchors.top: entryTitleLabel.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.paddingSmall
                spacing: 0

                Label {
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.6
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    text: entryUsernameLabel.text !== "" ? "Username" : "No username"
                }

                Label {
                    id: entryUsernameLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.6
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    text: entryPasswordLabel.text !== "" ? "Password" : "No password"
                }

                Label {
                    id: entryPasswordLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Item {
            id: infoTextView
            property alias text: infoTextLabel.text
            opacity: 0.0
            anchors.top: entryTitleLabel.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Label {
                id: infoTextLabel
                anchors.centerIn: parent
                width: parent.width - 2 * Theme.paddingLarge
                height: width
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                fontSizeMode: Text.Fit
                font.family: Theme.fontFamily
            }
        }
    }

    // Lock database cover action on opened database
    CoverActionList {
        enabled: ownKeepassSettings.lockDatabaseFromCover && ((coverState === Global.constants.databaseOpened) || (!ownKeepassSettings.copyNpasteFromCover && (coverState === Global.constants.databaseEntryOpened)))
        iconBackground: false

        CoverAction {
            iconSource: "../../covericons/locker.png"
            onTriggered: {
                // emit signal to lock database
                lockDatabase()
            }
        }
    }

    // Lock database and copy'n'paste cover action for entry
    CoverActionList {
        enabled: ownKeepassSettings.lockDatabaseFromCover && ownKeepassSettings.copyNpasteFromCover && (coverState === Global.constants.databaseEntryOpened)
        iconBackground: false

        CoverAction {
            iconSource: "../../covericons/locker.png"
            onTriggered: {
                // emit signal to lock database
                lockDatabase()
            }
        }

        CoverAction {
            iconSource: "../../covericons/copy.png"
            onTriggered: copyToClipboard()
        }
    }

    // Copy'n'paste cover action for entry
    CoverActionList {
        enabled: !ownKeepassSettings.lockDatabaseFromCover && ownKeepassSettings.copyNpasteFromCover && (coverState === Global.constants.databaseEntryOpened)
        iconBackground: false

        CoverAction {
            iconSource: "../../covericons/copy.png"
            onTriggered: copyToClipboard()
        }
    }
}


