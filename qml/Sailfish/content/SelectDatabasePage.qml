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

// plugin is in local imports directory
//import FileBrowser 1.0

Page {
    id: selectDatabasePage

    // Set the mode of the select database page. If false the user selects an existing database file.
    // If true the user creates a new keepass database file.
    property bool createNewDatabase: false

    // Signal to parent object with user selected data:
    // Path to keepass database file, path to key file (if user want to use one) and
    // info about creating a new database or opening an existing database.
    signal databaseFileSelected(string databaseFilePath, string keyFilePath, bool createNewDatabase)

    property string __fileTypeToBrowse: ""
    property string __directoryToBrowse: ""
    property string __pathToDatabase: "/sdcard/"
    property string __pathToKeyFile: "/"
    property string __databaseName: ""
    property string __keyFileName: ""

    // check if user choosen database file exists
    function databaseFileExists() {
        console.log("databaseFileExist: " + __pathToDatabase + __databaseName)

        var databaseFileExists = fileBrowser.fileExists(__pathToDatabase + __databaseName)
        if (createNewDatabase) {
            // on create new database
            if (databaseFileExists) {
                // file for new database already exists, ask user
                queryDialogOverwriteFile.isDatabaseFile = true
                queryDialogOverwriteFile.open()
                return false
            }
        } else {
            // on open existing database
            if (!databaseFileExists) {
                // choosen file does not exists
                queryDialogFileDoesNotExist.isDatabaseFile = true
                queryDialogFileDoesNotExist.open()
                return false
            }
        }
        return true
    }

    // check if use has choosen a key file and if it exists
    function keyFileExists() {
        console.log("databaseFileExist: " + __pathToKeyFile + __keyFileName)
        if (__keyFileName !== "") {
            var keyFileExists = fileBrowser.fileExists(__pathToKeyFile + __keyFileName)
            if (createNewDatabase) {
                // on create new database
                if (keyFileExists) {
                    // file for new keyfile already exists, ask user
                    queryDialogOverwriteFile.isDatabaseFile = false
                    queryDialogOverwriteFile.open()
                    return false
                }
            } else {
                // on open existing database
                if (!keyFileExists) {
                    // choosen key file does not exists
                    queryDialogFileDoesNotExist.isDatabaseFile = false
                    queryDialogFileDoesNotExist.open()
                    return false
                }
            }
        }
        return true
    }

    // Set properties for file browser page
    function setFileBrowserPageProperties() {
        switch (__fileTypeToBrowse) {
        case "Database":
            fileBrowserPageLoader.item.pageTitle = "Choose database file"
            break
        case "Keyfile":
            fileBrowserPageLoader.item.pageTitle = "Choose key file"
            break
        }
        fileBrowserPageLoader.item.parentPageObjectName = selectDatabasePage.objectName
        fileBrowserPageLoader.item.path = __directoryToBrowse
        fileBrowserPageLoader.item.pageCount = 1
        fileBrowserPageLoader.item.initFileBrowser()
    }

    // open file browser page
    // fileTypeToBrowse: "Database" means that the user is looking for a database file.
    //                   "Keyfile" means the user is looking for a key file.
    // directory: Contains the root directory where the file browser should start from.
    function openFileBrowserPage(fileTypeToBrowse, directory) {
        __fileTypeToBrowse = fileTypeToBrowse
        __directoryToBrowse = directory
        // check if page was already loaded and set properties
        if (fileBrowserPageLoader.status === Loader.Ready) {
            setFileBrowserPageProperties()
        } else {
            // load password page
            fileBrowserPageLoader.source = "FileBrowserPage.qml"
        }
        // open password page
        pageStack.push(fileBrowserPageLoader.item)
    }

    // Save user selected path and file name to database or keyfile.
    function saveSelectedPathAndFileName(fileName, path) {
        console.log("saveSelectedPathAndFileName: " + path + fileName)
        switch (__fileTypeToBrowse) {
        case "Database":
            __databaseName = fileName
            __pathToDatabase = path
            break
        case "Keyfile":
            __keyFileName = fileName
            __pathToKeyFile = path
            break
        }
    }

    // send signal to parent object, this function signals that selection of database and optionally key file is ready
    function sendSignalDatabaseFileSelected() {
        selectDatabasePage.databaseFileSelected(
                    __pathToDatabase + __databaseName,
                    __keyFileName === "" ? "" : __pathToKeyFile + __keyFileName,
                    selectDatabasePage.createNewDatabase)
        // reset internal states
        moreOptionsButton.checked = false
    }

//    toolBar: ButtonsToolbar {
//        rightButtonText: qsTr("CANCEL")
//        leftButtonText: qsTr("OPEN")
//        enableLeftButton: __databaseName !== ""
//        onRightButtonClicked: {
//            moreOptionsButton.checked = false
//            pageStack.pop()
//        }
//        onLeftButtonClicked: {
//            console.log("clicked on open button")
//            // user clicked on open button to open the selected database
//            if ((__databaseFileExists()) && (__keyFileExists())) {
//                sendSignalDatabaseFileSelected()
//            }
//        }
//    }

    Loader {
        id: fileBrowserPageLoader
        onLoaded: setFileBrowserPageProperties()
    }

    Connections {
        target: fileBrowserPageLoader.item
        onFileChoosen: saveSelectedPathAndFileName(fileName, path)
        onDirectoryChoosen: { // returns path
// TODO
        }
    }

//    FileBrowser {
//        id: fileBrowser
//    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: col.height

        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: createNewDatabase ? qsTr("New database") : qsTr("Open database")
            }

            // Create new Keepass database

            SilicaLabel {
                enabled: createNewDatabase
                visible: createNewDatabase
                text: qsTr("Type in a name for your new Keepass database:")
            }

            TextField {
                id: databaseName
                width: parent.width
                enabled: createNewDatabase
                visible: createNewDatabase
                label: "Database name"
                placeholderText: "Set database name"
                text: __databaseName
// TODO add Global config for text alignment
//                horizontalAlignment: textAlignment
                EnterKey.onClicked: {
                    __databaseName = text
                    parent.focus = true
//                    closeSoftwareInputPanel()
                }
                inputMethodHints: Qt.ImhNoPredictiveText
            }

            SilicaLabel {
                enabled: createNewDatabase
                visible: createNewDatabase
                text: qsTr("(Optional) Type in a name for a key file:")
            }

            TextField {
                id: keyFileName
                width: parent.width
                enabled: createNewDatabase
                visible: createNewDatabase
                label: "Key file name"
                placeholderText: "Set key file name"
                text: __keyFileName
// TODO add Global config for text alignment
//                horizontalAlignment: textAlignment
                EnterKey.onClicked: {
                    __keyFileName = text
                    parent.focus = true
                }
                inputMethodHints: Qt.ImhNoPredictiveText
            }

            // more Options

            TextSwitch {
                id: moreOptionsButton
                enabled: createNewDatabase
                visible: createNewDatabase
                text: "more options"
            }

            SilicaLabel {
                enabled: createNewDatabase && moreOptionsButton.checked
                visible: createNewDatabase && moreOptionsButton.checked
                text: qsTr("Change location where the Keepass database file will be saved:")
            }

            FileBrowserLabel {
                id: pathToNewDatabaseBrowser
                width: parent.width
                enabled: createNewDatabase && moreOptionsButton.checked
                visible: createNewDatabase && moreOptionsButton.checked
                text: __pathToDatabase
                label: "Path to database"
                placeholderText: "Set path to database"
                onFolderButtonClicked: openFileBrowserPage("Database", __pathToDatabase)
            }

            SilicaLabel {
                enabled: createNewDatabase && moreOptionsButton.checked
                visible: createNewDatabase && moreOptionsButton.checked
                text: qsTr("Change location where the key file will be saved:")
            }

            FileBrowserLabel {
                id: pathToNewKeyFileBrowser
                width: parent.width
                enabled: createNewDatabase && moreOptionsButton.checked
                visible: createNewDatabase && moreOptionsButton.checked
                text: __pathToKeyFile
                label: "Path to key file"
                placeholderText: "Set path to key file"
                onFolderButtonClicked: openFileBrowserPage("Keyfile", __pathToKeyFile)
            }

            // Open existing Keepass database

            SilicaLabel {
                enabled: !createNewDatabase
                visible: !createNewDatabase
                text: qsTr("Choose Keepass database file:")
            }

            FileBrowserLabel {
                id: pathToDatabaseBrowser
                width: parent.width
                enabled: !createNewDatabase
                visible: !createNewDatabase
                text: __pathToDatabase + __databaseName
                onFolderButtonClicked:
                    openFileBrowserPage("Database", __pathToDatabase)
            }

            SilicaLabel {
                enabled: !createNewDatabase
                visible: !createNewDatabase
                text: qsTr("(Optional) Choose key file:")
            }

            FileBrowserLabel {
                id: pathToKeyFileBrowser
                width: parent.width
                enabled: !createNewDatabase
                visible: !createNewDatabase
                text: __pathToKeyFile + __keyFileName
                onFolderButtonClicked:
                    openFileBrowserPage("Keyfile", __pathToKeyFile)
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: __databaseName !== ""
                text: createNewDatabase ? "Create" : "Open"
                onClicked: {
                    console.log("Clicked on Create/Open Button")
                    // user clicked on open button to open the selected database
                    if (databaseFileExists() && keyFileExists()) {
                        sendSignalDatabaseFileSelected()
                    }
                }
            }
        }
    }

//    QueryDialog {
//        id: queryDialogOverwriteFile
//        property bool isDatabaseFile: true
//        titleText: "OVERWRITE FILE?"
//        message: "The " + (isDatabaseFile ? "database" : "key") +
//                 " file already exists and will be overwritten. Are you sure?"
//        acceptButtonText: "YES"
//        acceptButton.highlighted: true
//        rejectButtonText: "NO"
//        onAccepted: {
//            // check if user has accepted overwriting database or key file
//            if (isDatabaseFile) {
//                // uesr has accepted overwriting database file
//                // then we need to ask for overwriting key file
//                keyFileExists()
//            } else {
//                // user accepted overwriting key file
//                // now signal to parent object that selection is ready
//                sendSignalDatabaseFileSelected()
//            }
//        }
//    }

//    QueryDialog {
//        id: queryDialogFileDoesNotExist
//        property bool isDatabaseFile: true
//        titleText: "FILE DOES NOT EXIST"
//        message: "The "  + (isDatabaseFile ? "database" : "key") +
//                 " file does not exist. Make sure you specify an existing file."
//        acceptButtonText: "OK"
//        acceptButton.highlighted: true
//    }

}
