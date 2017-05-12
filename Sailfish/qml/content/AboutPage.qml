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
                source: "/usr/share/icons/hicolor/256x256/apps/harbour-ownkeepass.png"
                width: height
                height: Screen.sizeCategory >= Screen.Large ?
                            implicitHeight :
                            implicitHeight * (Screen.height / 1920)
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("ownKeepass is a Keepass 1 and 2 compatible password safe application")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Version") + " " + ownKeepassSettings.version + "<br>\
Copyright &#169; 2013-2017 Marko Koschak"
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
                    onClicked: Qt.openUrlExternally("https://twitter.com/jobe2k")
                }

                Button {
                    anchors.bottom: parent.bottom
                    width: (parent.width / 2) * 0.95
                    text: qsTr("Email")
                    onClicked: Qt.openUrlExternally("mailto:marko.koschak@tisno.de")
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
                    onClicked: Qt.openUrlExternally("https://flattr.com/profile/jobe")
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

            SectionHeader {
                text: qsTr("Credits")
            }

            SilicaLabel {
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("My best appreciations go to:") + "<br><br>" +
                      qsTr("Jolla (for continuing where Nokia stopped)") + "<br>" +
                      qsTr("The KeepassX project (for a Qt implementation of Keepass)") + "<br>" +
                      //: %1 and %2 are placeholders for links to the project on transifex and github
                      qsTr("And finally many thanks to all translators on %1 and contributors on %2 (for keeping me motivated to work on ownKeepass)")
                .arg("<a href=\"https://www.transifex.com/projects/p/jobe_m-ownKeepass/\">transifex</a>")
                .arg("<a href=\"https://github.com/jobe-m/ownkeepass/graphs/contributors\">GitHub</a>") + "<br><br>" +
                qsTr("Alphabetical list of all translators:") + "<br><br>" +
                "_panta_ (Panayiotis Tembriotis)<br>" +
                "akalmykov (Anton Kalmykov)<br>" +
                "alert.aleksandar00 (Alert Aleksandar)<br>" +
                "Artemys<br>" +
                "carmenfdezb (Carmen Fernández B.)<br>" +
                "Cermit (Heinz)<br>" +
                "cow<br>" +
                "deryo (I won't tell)<br>" +
                "dglent (Dimitrios Glentadakis)<br>" +
                "Dude259 (Gizmo Muppet)<br>" +
                "esaintor (Saintor Batkhuu)<br>" +
                "eson (Åke Engelbrektson)<br>" +
                "flywheeldk (Peter Jespersen)<br>" +
                "fri<br>" +
                "fri666 (Agustí Clara)<br>" +
                "Getmantsev (Andrey Getmantsev)<br>" +
                "ghostofasmile (fravaccaro)<br>" +
                "helicalgear<br>" +
                "hellomax (Max Max)<br>" +
                "JaviMerino (Javi Merino)<br>" +
                "Jordi<br>" +
                "jotakinhan (miikka kukko)<br>" +
                "kanne (Petri Makijarvi)<br>" +
                "kjetil_kilhavn (Kjetil Kilhavn)<br>" +
                "koenigseggCCGT (lorenzo facca)<br>" +
                "limsup (Andras Toth)<br>" +
                "mijnheer (André Koot)<br>" +
                "mjoan<br>" +
                "Nerfiaux (Guillaume ARIAUX)<br>" +
                "olebr (Ole Jakob Brustad)<br>" +
                "pakoR<br>" +
                "PawelSpoon<br>" +
                "pljmn (Nathan Follens)<br>" +
                "reviewjolla (Simo Ruoho)<br>" +
                "rgsidler (R.G. Sidler)<br>" +
                "rla88 (Riku Lahtinen)<br>" +
                "Savvoritias (Marinus Savoritias)<br>" +
                "Sthocs<br>" +
                "tichy (Tichy)<br>" +
                "Tomasz_Amborski (Tomasz Amborski)<br>" +
                "TylerTemp (Tyler Temp)<br>" +
                "umglurf<br>" +
                "Vistaus (Heimen Stoffels)<br>" +
                "xmlich02 (Jozef Mlích)<br><br>" +
                qsTr("I hope you have as much fun using ownKeepass as I have creating it!")
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
        }
    }
}
