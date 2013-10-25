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

// plugin is in local imports directory
//import FileBrowser 1.0

Page {
    id: fileBrowserPage

    property string path: ""
    // specify whether file or directory should be choosen
    property bool chooseDirectory: false
    property string pageTitle: ""
    property string parentPageObjectName: ""

    // specify which file types should be visible in the file browser
// TODO file type comes from settings
    property string fileTypefilter: "*.kdb *.kdbx"

// TODO remove later when pop to root page is working
    property int pageCount: 1

    signal fileChoosen(string fileName, string path)
    signal directoryChoosen(string path)

    // must be called by parent object to correctly initialize file browser
    function initFileBrowser() {
        internal.loadDirectoryList()
        internal.setRootFileBrowserPageObjectName()
    }

//    header: Header {
//        Label {
//            anchors.fill: parent
//            anchors.margins: 10
//            text: qsTr("Path: ") + fileBrowserPage.path
//            wrapMode: Text.NoWrap
//            elide: Text.ElideMiddle
//            font.family: Style.ShowEntryFont
//            font.pixelSize: Style.ShowEntryFontSize
//            font.bold: true
//            color: Theme.accentColor
//        }
//    }

//    toolBar: MainToolbar {
//        id: maintoolBar
//        onBackIconClicked: pageStack.pop()
//    }

//    Component.onCompleted: {
//        console.log("page name: " + fileBrowserPage.name)
//        if (!internal.initialized) internal.loadDirectoryList()
//    }

    /*FileBrowser*/ListModel {
        id: fileBrowserListModel
    }

//    onPageContainerChanged: addItems()

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: fileBrowserListModel

        header: PageHeaderExtended {
            title: "File Browser"
            subTitle: "/sdcard/"
        }

        ViewPlaceholder {
            enabled: listView.count == 0
            text: "Nothing here"
            hintText: "Pull down for options"
        }

        PullDownMenu {
            MenuItem {
                text: "Jump to the end"
                onClicked: listView.scrollToBottom()
            }
            MenuItem {
                text: "Create new file"
            }
        }

        PushUpMenu {
            spacing: Theme.paddingLarge
            MenuItem {
                text: "Return to Top"
                onClicked: listView.scrollToTop()
            }
        }

        VerticalScrollDecorator {}

        delegate: ListItem {
            id: listItem
            menu: contextMenuComponent
            function remove() {
                remorseAction("Deleting", function() { fileBrowserListModel.remove(index) })
            }
            ListView.onRemove: animateRemoval()
            onClicked: {
                console.log( "Clicked on " + model.name + " type: " + model.itemType + " id: " + model.id)
                switch (model.itemType) {
                case FileBrowserListModel.FOLDER:
                    pageStack.push(Qt.resolvedUrl("FileBrowserPage.qml").toString(),
                                   { //fileTypeToBrowse: fileBrowserPage.fileTypeToBrowse,
                                     parentPageObjectName: fileBrowserPage.parentPageObjectName,
                                     pageTitle: fileBrowserPage.pageTitle,
                                     filename: model.name,
                                     path: model.subtitle,
//                                     rootPage: fileBrowserPage.rootPage,
                                     pageCount: fileBrowserPage.pageCount + 1 })
                    break
                case FileBrowserListModel.FILE:
                    internal.returnChoosenFile(model.name, model.subtitle)
                    break
                default:
// TODO error handling
                    break
                }
            }
            Label {
                x: Theme.paddingLarge
                text: model.name
                anchors.verticalCenter: parent.verticalCenter
                font.capitalization: Font.Capitalize
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    MenuItem {
                        text: "Delete"
                        onClicked: remove()
                    }
                    MenuItem {
                        text: qsTr("Open")
                        onClicked: {
                            internal.returnChoosenFile(model.name, model.subtitle)
                        }
                    }

                    MenuItem {
//                        enabled: model.itemType === FileBrowserListModel.FILE
                        text: qsTr("Delete")
                        onClicked: {
                            if (model.itemType === FileBrowserListModel.FILE) {
                                deleteQuery.deleteItemType = KdbListModel.ENTRY
                                deleteQuery.titleText = qsTr("DELETE \"%1\"").arg(model.name)
                                deleteQuery.message = qsTr("Are you sure you want to delete selected keepass database file?")
                                deleteQuery.open()
                            }
                        }
                    }
                }
            }
        }
    }




/*
        anchors.fill: parent
        clip: false
        model: fileBrowserListModel
        delegate: SilicaListItem {
            id: listItem
//            iconSource: Qt.resolvedUrl("covers/" + model.cover).toString()
            text: model.name
//            description: model.subtitle
            onClicked: {
                console.log( "Clicked on " + model.name + " type: " + model.itemType + " id: " + model.id)
                switch (model.itemType) {
                case FileBrowserListModel.FOLDER:
                    pageStack.push(Qt.resolvedUrl("FileBrowserPage.qml").toString(),
                                   { //fileTypeToBrowse: fileBrowserPage.fileTypeToBrowse,
                                     parentPageObjectName: fileBrowserPage.parentPageObjectName,
                                     pageTitle: fileBrowserPage.pageTitle,
                                     filename: model.name,
                                     path: model.subtitle,
//                                     rootPage: fileBrowserPage.rootPage,
                                     pageCount: fileBrowserPage.pageCount + 1 })
                    break
                case FileBrowserListModel.FILE:
                    internal.returnChoosenFile(model.name, model.subtitle)
                    break
                default:
// TODO error handling
                    break
                }
            }
            onPressAndHold: {
                // here a sub menu pops up at the group item in the list view
                contextMenu.open(listItem)
            }

            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: qsTr("Open")
                    onTriggered: {
                        internal.returnChoosenFile(model.name, model.subtitle)
                    }
                }

                MenuItem {
                    enabled: model.itemType === FileBrowserListModel.FILE
                    text: qsTr("Delete")
                    onTriggered: {
                        if (model.itemType === FileBrowserListModel.FILE) {
                            deleteQuery.deleteItemType = KdbListModel.ENTRY
                            deleteQuery.titleText = qsTr("DELETE \"%1\"").arg(model.name)
                            deleteQuery.message = qsTr("Are you sure you want to delete selected keepass database file?")
                            deleteQuery.open()
                        }
                    }
                }
            }
        }
    }
*/

// TODO change this label for the path into a top status bar
//    Label {
//        id: filePathLabel
//        anchors.bottom: parent.bottom
//        width: parent.width
//        font.family: Style.ShowEntryCaptionFont
//        font.pixelSize: Style.ShowEntryCaptionFontSize
//        font.bold: true
//        color: Theme.mode === Theme.Light ? "#808080" : "#acacac"
//        text: "Path: " + fileBrowserPage.path
//    }

//    QueryDialog {
//        id: deleteQuery
//        property int deleteItemType: 0
//        rejectButtonText: qsTr("NO")
//        acceptButtonText: qsTr("YES")
//        acceptButton.highlighted: true
//        onAccepted: {
//// TODO delete file
//        }
//    }

    QtObject {
        id: internal
        property bool initialized: false
//        function setPageTitle() {
//            switch (fileBrowserPage.fileTypeToBrowse) {
//            case "Database":
//                return "Choose database file"
//            case "Keyfile":
//                return "Choose key file"
//            default:
//                // error case
//                console.log("ERROR: unknown fileTypeToBrowse entry")
//                pageStack.pop({ page: fileBrowserPage.rootPage })
//            }
//        }

        function returnChoosenDirectory(path) {

        }

        function returnChoosenFile(fileName, path) {
            // emit signal with choosen file name from root file browser page
            var rootFileBrowserPage = pageStack.find(
                        function(page) {
                            return page.objectName === "rootFileBrowserPage"
                        })
            console.log("rootFileBrowserPage: " + rootFileBrowserPage)
            console.log("returnChoosenFile: " + fileName + " - " + path)
            rootFileBrowserPage.fileChoosen(fileName, path + "/")

            // close all file browser pages on page stack
            var parentPage = pageStack.find(
                        function(page) {
                            return page.objectName === fileBrowserPage.parentPageObjectName
                        })
            console.log("parentpage: " + parentPage)
//            pageStack.pop(parentPage)

//            parentPage.databaseName = fileName
//            parentPage.pathToDatabase = path

            // pop to root page
            for (var i = 0; i < fileBrowserPage.pageCount; i++) {
                pageStack.pop()
            }
        }

        // set object name for root page of the file browser so that we can send signals out
        function setRootFileBrowserPageObjectName() {
            fileBrowserPage.objectName = "rootFileBrowserPage"
        }

        // update list model with files and directories from given path
        function loadDirectoryList() {
            console.log("Loading filepath: " + fileBrowserPage.path + " filter: " + fileBrowserPage.fileTypefilter)
//            fileBrowserListModel.loadDirectoryList(fileBrowserPage.path, fileBrowserPage.fileTypefilter)
            // BEDIN testing code
            var entries = (pageContainer && pageContainer.depth % 2 == 1) ? 40 : 5
            var spaceIpsumWords = ["Since", "long", "run", "every", "planetary", "civilization", "endangered", "impacts", "space", "every", "surviving",
                                   "civilization", "obliged", "become", "spacefaring", "because", "exploratory", "romantic", "zeal", "most", "practical",
                                   "reason", "imaginable", "staying", "alive", "long-term", "survival", "stake", "have", "basic", "responsibility", "species",
                                   "venture", "other", "worlds", "one", "small", "step", "man", "one", "giant", "leap", "mankind", "powered", "flight",
                                   "total", "about", "eight", "half", "minutes", "seemed", "gone", "lash", "gone", "from", "sitting", "still", "launch",
                                   "pad", "Kennedy", "Space", "Center", "traveling", "17500", "miles", "hour", "eight", "half", "minutes", "still",
                                   "recall", "making", "some", "statement", "air", "ground", "radio", "benefit", "fellow", "astronauts", "who", "also",
                                   "program", "long", "time", "well", "worth", "took", "been", "wait", "mind-boggling"]

            for (var index = 0; index < entries; index++) {
                fileBrowserListModel.append({"name": spaceIpsumWords[index*2] + " " + spaceIpsumWords[index*2+1]})
            }
            // END testing code
            internal.initialized = true
        }
    }
}
