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
            width: parent.width * 0.85
            height: width
            anchors.top: parent.top
            anchors.right: parent.right
            source: "../../wallicons/cover-cloud.png"
            opacity: 0.2
        }
    }

    state: "NO_DATABASE_OPENED"
    property string databaseName: ""
    property string groupTitle: ""
    property string entryTitle: ""
    property string username: ""
    property string password: ""

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

    Item {
        anchors.fill: parent

        Label {
            id: appName
            y: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.secondaryColor
            opacity: 0.7
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            text: "ownKeepass"
        }

        Label {
            id: coverTitleLabel
            anchors.top: appName.bottom
            anchors.topMargin: -Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.primaryColor
            horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
            wrapMode: Text.NoWrap
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        OpacityRampEffect {
            enabled: coverTitleLabel.implicitWidth > coverTitleLabel.width
            sourceItem: coverTitleLabel
            slope: 2.0
            offset: 0.5
        }

        Item {
            id: entryDetailsView
            anchors.top: coverTitleLabel.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.paddingSmall
                spacing: 0

                Label {
                    id: coverTextLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    enabled: state === "ENTRY_VIEW"
                    visible: enabled
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.7
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
                    maximumLineCount: 2
                    text: ownKeepassSettings.showUserNamePasswordOnCover ? coverPage.username : ""
                }

                Label {
                    enabled: state === "ENTRY_VIEW"
                    visible: enabled
                    width: parent.width
                    color: Theme.secondaryColor
                    opacity: 0.7
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
                    maximumLineCount: 2
                    text: ownKeepassSettings.showUserNamePasswordOnCover ? coverPage.password : ""
                }
            }
        }

        Item {
            id: infoTextView
            property alias text: infoTextLabel.text
            opacity: 0.0
            anchors.top: coverTitleLabel.bottom
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
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
//                fontSizeMode: Text.Fit
            }
        }
    }

    // Lock database cover action on opened database
    CoverActionList {
        enabled: ownKeepassSettings.lockDatabaseFromCover && (
                     (state !== "NO_DATABASE_OPENED") || state !== "DATABASE_LOCKED" &&
                     (!ownKeepassSettings.copyNpasteFromCover && (state === "ENTRY_VIEW")))
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
        enabled: ownKeepassSettings.lockDatabaseFromCover &&
                 ownKeepassSettings.copyNpasteFromCover && (state === "ENTRY_VIEW")
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
        enabled: !ownKeepassSettings.lockDatabaseFromCover &&
                 ownKeepassSettings.copyNpasteFromCover && (state === "ENTRY_VIEW")
        iconBackground: false

        CoverAction {
            iconSource: "../../covericons/copy.png"
            onTriggered: copyToClipboard()
        }
    }

    states: [
        State {
            name: "NO_DATABASE_OPENED"
            PropertyChanges { target: coverTitleLabel; text: "" }
            PropertyChanges { target: coverTextLabel; text: "No database opened" }
            PropertyChanges { target: coverPage; username: ""; password: "" }
        },
        State {
            name: "DATABASE_LOCKED"
            PropertyChanges { target: coverTitleLabel; text: coverPage.databaseName }
            PropertyChanges { target: coverTextLabel; text: "Database locked" }
            PropertyChanges { target: coverPage; username: ""; password: "" }
        },
        State {
            name: "UNSAVED_CHANGES"
            PropertyChanges { target: coverTitleLabel; text: coverPage.databaseName }
            PropertyChanges { target: coverTextLabel; text: "Some unsaved changes pending" }
            PropertyChanges { target: coverPage; username: ""; password: "" }
        },
        State {
            name: "GROUPS_VIEW"
            PropertyChanges { target: coverTitleLabel; text: coverPage.groupTitle }
            PropertyChanges { target: coverTextLabel; text: "Viewing password group" }
            PropertyChanges { target: coverPage; username: ""; password: "" }
        },
        State {
            name: "SEARCH_VIEW"
            PropertyChanges { target: coverTitleLabel; text: coverPage.groupTitle }
            PropertyChanges { target: coverTextLabel; text: "Search for password entries" }
            PropertyChanges { target: coverPage; username: ""; password: "" }
        },
        State {
            name: "ENTRY_VIEW"
            PropertyChanges { target: coverTitleLabel; text: coverPage.entryTitle }
            PropertyChanges { target: coverTextLabel; text: "" }
            // Username and password will be set from outside
        }
    ]
}


