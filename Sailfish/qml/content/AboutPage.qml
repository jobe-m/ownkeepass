/***************************************************************************
**
** Copyright (C) 2013-2014 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass 1.0
import "../common"

Page {
    id: aboutPage

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
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: qsTr("About ownKeepass")
                subTitle: qsTr("Password Safe")
                subTitleOpacity: 0.5
                subTitleBottomMargin: aboutPage.orientation & Orientation.PortraitMask ? Theme.paddingSmall : 0
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Screen.sizeCategory >= Screen.Large ?
                            "/usr/share/icons/hicolor/256x256/apps/harbour-ownkeepass.png" :
                            "/usr/share/icons/hicolor/128x128/apps/harbour-ownkeepass.png"
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("ownKeepass is a Keepass 1.x and 2.x compatible password safe application")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Version") + " " + ownKeepassSettings.version + "<br>\
Copyright &#169; 2013-2015 Marko Koschak"
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: "Twitter"
                    onClicked:Qt.openUrlExternally("https://twitter.com/jobe2k")
                }

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Email")
                    onClicked:Qt.openUrlExternally("mailto:marko.koschak@tisno.de")
                }
            }

            SectionHeader {
                text: qsTr("License")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("ownKeepass is distributed under the terms of the GNU General Public License (GPL) version 2 or (at your option) version 3.")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "<a href=\"https://github.com/jobe-m/ownkeepass\">https://github.com/jobe-m/ownkeepass</a>"
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("License")
                    onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
                }

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Change log")
                    onClicked: pageStack.push(Qt.resolvedUrl("ChangeLogPage.qml"))
                }
            }

            SectionHeader {
                text: qsTr("Credits")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("My best appreciations go to:<br><br>\
Jolla (for continuing where Nokia stopped)<br>\
The KeepassX project (for a Qt implementation of Keepass)<br>\
All translators and contributors: %1<br><br>\
\
I hope you have as much fun using ownKeepass as I have creating it!")
                .arg("Petri Mäkijärvi, Åke Engelbrektson, Agusti Clara, fri, Heimen Stoffels, Rob K, Nathan Follens, \
carmenfdezb, TylerTemp, Peter Jespersen, Jordi, Guillaume ARIAUX, Sthocs, Francesco Vaccaro, Lorenzo Facca, Alexey, \
Anton Kalmykov, Sergiy K, Kjetil Kilhavn, Jozef Mlích, R.G.Sidler, deryo, R Kake, Dimitrios Glentadakis,
André Koot")
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

            SectionHeader {
                text: qsTr("Donate or Contribute")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("If you like my work feel free to show me your gratitude. Work on a translation, \
issue a bug report or improvement idea, send me a café or just like my app and talk about it in the Jolla store :)")
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: "Flattr"
                    onClicked: Qt.openUrlExternally("http://flattr.com/thing/4296314/ownKeepass")
                }

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: "Paypal"
                    onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5KR2WTZ8FMRQQ")
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                spacing: (width / 2) * 0.1
                height: Theme.itemSizeMedium + Theme.paddingMedium

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Translate")
                    onClicked: Qt.openUrlExternally("https://www.transifex.com/projects/p/jobe_m-ownKeepass/")
                }

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Report bugs")
                    onClicked: Qt.openUrlExternally("https://github.com/jobe-m/ownkeepass/issues")
                }
            }

            SilicaLabel {
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "<br>"
            }
        }
    }
}
