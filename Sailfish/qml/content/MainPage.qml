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

// TODO This page will be used in "non-simple mode" which is not yet implemented

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../common"
import "../scripts/Global.js" as Global

Page {
    id: page

    /* internal */
    property bool __createNewDatabase: false
    property string __databaseFilePath: ""
    property string __keyFilePath: ""

    //
    function setPasswordPageProperties() {
        passwordPageLoader.item.passwordLabelText = __createNewDatabase ?
                    "Type in a master password for locking your new Keepass database:" :
                    "Type in master password for unlocking your Keepass database:"
        passwordPageLoader.item.pageTitle = "Password"
        passwordPageLoader.item.showVerifyPasswordField = __createNewDatabase
    }

    //
    function openPasswordPage(createNewDatabase) {
        // save internally
        __createNewDatabase = createNewDatabase

// TODO
        // check if .lock file exists and ask user to open database in read mode
        // or to discard .lock file and open database in read-write mode
// TODO
        // create .lock file

        // check if page was already loaded and set properties
        if (passwordPageLoader.status === Loader.Ready) {
            setPasswordPageProperties()
        } else {
            // load password page
            passwordPageLoader.source = "common/PasswordPage.qml"
        }
        // open password page
        pageStack.push( {page: passwordPageLoader.item} )
    }

    //
    function setSelectDatabasePageProperties() {
        selectDatabasePageLoader.item.createNewDatabase = __createNewDatabase
    }

    // opens selectDatabase page where the user can search, select or create a new keepass database file
    // parameter type bool
    function openSelectDatabasePage(createNewDatabase) {
        // save internally
        __createNewDatabase = createNewDatabase
        // check if page was already loaded and set properties
        if (selectDatabasePageLoader.status === Loader.Ready) {
            setSelectDatabasePageProperties()
        } else {
            // load selectDatabase page
            selectDatabasePageLoader.source = "SelectDatabasePage.qml"
        }
        // open selectDatabase page
        pageStack.push(selectDatabasePageLoader.item)
    }

    //
    function updateRecentDatabaseList(databaseFilePath, keyFilePath) {
        Global.config.addNewRecent(databaseFilePath, keyFilePath)
        recentDatabasesRepeater.model = 0
        recentDatabasesRepeater.model = Global.config.getNumberOfRecents()
    }

    function saveFilePaths(databaseFilePath, keyFilePath) {
        // save internally
        __databaseFilePath = databaseFilePath
        __keyFilePath = keyFilePath
    }

    Loader {
        id: passwordPageLoader
        onLoaded: setPasswordPageProperties()
    }

    Loader {
        id: selectDatabasePageLoader
        onLoaded: setSelectDatabasePageProperties()
    }

    Connections {
        target: passwordPageLoader.item
        onPasswordChanged: { // returns password
            if (__createNewDatabase) {
                // create new Keepass database
                kdbDatabase.create(password)
            } else {
                // open existing Keepass database
                kdbDatabase.open(password, false)
            }
        }
    }

    Connections {
        target: selectDatabasePageLoader.item
        onDatabaseFileSelected: {
            updateRecentDatabaseList(databaseFilePath, keyFilePath)
            saveFilePaths(databaseFilePath, keyFilePath)
            openPasswordPage(createNewDatabase)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}
        
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: "Help"
                onClicked: pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
            }
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"))
            }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Create new database"
                onClicked: {
                    console.log("Clicked on Create new database")
                    // open new page and create a new database file
                    openSelectDatabasePage(true)
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Open database"
                onClicked: {
                    console.log("Clicked on Open database")
                    // open new page and select an existing database file
                    openSelectDatabasePage(false)
                }
            }

            SectionHeader {
                enabled: recentDatabasesRepeater.model !== 0
                visible: recentDatabasesRepeater.model !== 0
                text: "Recent databases:"
            }

            Repeater {
                id: recentDatabasesRepeater
                model: 0

                Column {
                    width: parent.width
                    height: children.height
                    SilicaListItem {
                        text: Global.config.recentDatabaseNames[index]
                        description: Global.config.recentDatabasePaths[index]
                        onClicked: {
//                            console.log("Clicked on: " + Global.config.recentDatabaseNames[index])
                            openPasswordPage(false)
                            saveFilePaths(Global.config.recentDatabaseFilePaths[index],
                                                   Global.config.recentKeyFilePaths[index])
//                            updateRecentDatabaseList(Global.config.recentDatabaseFilePaths[index],
//                                                              Global.config.recentKeyFilePaths[index])
                        }
                    }
                }
            }

            Component.onCompleted: {
                Global.config.initArrays()
                Global.config.addNewRecent("/sdcard/test.kdb", "")
                Global.config.addNewRecent("/sdcard/keepass/notes.kdb", "")
                recentDatabasesRepeater.model = Global.config.getNumberOfRecents()
            }


/*//////////////////////
            SectionHeader {
                text: __createNewDatabase ? "Create new Password Safe" : "Open existing Password Safe"
            }

            SilicaLabel {
                enabled: __createNewDatabase
                visible: __createNewDatabase
                text: "Choose a name for your new Keepass Password Safe:"
            }

            TextField {
                id: newKeepassFileName
                width: parent.width
                label: "Name"
                placeholderText: "Enter name"
//                text: Config.lastOpenedKdbFileName
//                horizontalAlignment: Config.TextFieldAlignment
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
            }

            SilicaLabel {
                text: __createNewDatabase ? "Type in a master password for locking your Keepass Password Safe:" :
                                            "Type in master password for unlocking your Keepass Password Safe:"
            }

            TextField {
                id: password
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                label: "Password"
                placeholderText: "Enter password"
                text: "qwertz"
//                horizontalAlignment: textAlignment
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: confirmPassword.focus = true
            }

            TextField {
                id: confirmPassword
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                enabled: __createNewDatabase && password.text || text
                visible: __createNewDatabase
                errorHighlight: password.text != text
                label: "Confirm Password"
                placeholderText: label
                text: "qwertz"
                opacity: enabled ? 1 : 0.5
                Behavior on opacity { NumberAnimation { } }
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.highlighted: !errorHighlight
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    if (errorHighlight)
                        password.focus = true
                    else
                        __openKeepassDatabase(__createNewDatabase)
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: newKeepassFileName.text != "" && !confirmPassword.errorHighlight
                text: __createNewDatabase ? "Create" : "Open"
                onClicked: __openKeepassDatabase(__createNewDatabase)
            }

            SectionHeader {
                text: __createNewDatabase ? "Open existing Password Safe" :
                                            "Open another Password Safe"
            }

            ComboBox {
                id: existingKeepassDatabase
                width: page.width
                label: "Choose Keepass file:"
                menu: ContextMenu {
                    Repeater {
                        model: ["<no file selected>", "notes.kdb", "diary.kdb"]
                        MenuItem { text: modelData }
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: existingKeepassDatabase.currentIndex > 0
                text: "Open"
                onClicked: __openKeepassDatabase(false)
            }
*/
        }
    }
}


