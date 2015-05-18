/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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
import harbour.ownkeepass.KeepassX1 1.0
import "../scripts/Global.js" as Global

Dialog {
    id: fileSystemDialog

    // Index for location
    // 0 - No location / Don't change location
    // 1 - Device Memory
    // 2 - SD Card
    // 3 - Android Storage
    property int locationIndex: 0
    // Relative path of file inside location including file name
    property string relativePath: ""
    // Absolute path of file including file name
    property string absolutePath: ""
    // Set default state
    // States: OPEN_FILE, CREATE_NEW_FILE
    state: "OPEN_FILE"

    // internal
    // Name of directory is used to cd into it
    property string __dirName: ""
    property string __absoluteDirPath: ""

    onAccepted: {
        // create relative path to location out of absolute path
        if (state === "OPEN_FILE") {
            relativePath = absolutePath.replace(ownKeepassHelper.getLocationRootPath(locationIndex), "")
        } else {
            relativePath = __absoluteDirPath.replace(ownKeepassHelper.getLocationRootPath(locationIndex), "") +
                    "/" + fileNameField.text
        }
        if (relativePath.charAt(0) === '/') {
            relativePath = relativePath.slice(1, relativePath.length)
        }
    }

    FileBrowserListModel {
        id: fileBrowserListModel
        onShowErrorBanner: {
            var title = qsTr("Problem with SD card")
            var message = qsTr("SD cards with multiple partitions are not supported.")
            Global.env.infoPopup.show(Global.info, title, message)
        }
    }

    NumberAnimation {
        id: outAnimation
        target: listView
        property: "opacity"
        duration: 100
        easing.type: Easing.InOutQuad
        from: 1.0
        to: 0.0
        running: false

        onStopped: {
            fileBrowserListModel.cd(__dirName)
            inAnimation.start()
        }
    }

    NumberAnimation {
        id: inAnimation
        target: listView
        property: "opacity"
        duration: 100
        easing.type: Easing.OutInQuad
        from: 0.0
        to: 1.0
        running: false

        onStopped: {
            listView.enabled = true;
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: fileBrowserListModel.showHiddenFiles ?
                          //: Used in file browser to hide the system files
                          qsTr("Hide system files") :
                          //: Used in file browser to show the hidden system files
                          qsTr("Show system files")
                onClicked: {
                    fileBrowserListModel.showHiddenFiles = !fileBrowserListModel.showHiddenFiles
                }
            }

            MenuItem {
                id: showFileFilterMenuItem
                visible: enabled
                text: fileBrowserListModel.showFileFilter ?
                          //: Used in file browser to hide the file name filter
                          qsTr("Hide file filter") :
                          //: Used in file browser to show the file name filter
                          qsTr("Show file filter")
                onClicked: {
                    fileBrowserListModel.showFileFilter = !fileBrowserListModel.showFileFilter
                }
            }
        }

        DialogHeader {
            id: header
            //: As in select file
            acceptText: qsTr("Select")
            cancelText: qsTr("Cancel")
        }

        Item {
            id: newFileName
            visible: enabled
            y: header.y + header.height
            width: parent.width
            height: fileNameField.height

            TextField {
                id: fileNameField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                errorHighlight: text.length === 0
                label: qsTr("New file name")
                placeholderText: qsTr("Enter new file name")
                text: ""
                EnterKey.enabled: !errorHighlight
                EnterKey.highlighted: text !== ""
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    parent.focus = true
                    accept()
                    close()
                }
                focusOutBehavior: -1
            }

/*            Label {
                id: breadcrum
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingSmall
                text: fileBrowserListModel.breadcrumPath
                opacity: 0.6
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }
*/
        }

        Item {
            id: fileFilter
            visible: enabled
            opacity: enabled ? 1.0 : 0.0
            y: header.y + header.height
            width: parent.width
            height: enabled ? fileFilterField.height : 0
            onEnabledChanged: {
                if (enabled) {
                    var array = fileFilterField.text.split(" ")
                    fileBrowserListModel.fileFilter = array
                }
            }

            Behavior on height {
                NumberAnimation { duration: 500 }
            }

            Behavior on opacity {
                FadeAnimation { duration: 500 }
            }

            TextField {
                id: fileFilterField
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                errorHighlight: text.length === 0
                label: qsTr("File filter")
                placeholderText: qsTr("Set file filter")
                text: "*.kdb"
                EnterKey.enabled: !errorHighlight
                EnterKey.highlighted: text !== ""
                EnterKey.onClicked: {
                    parent.focus = true
                    var array = text.split(" ")
                    fileBrowserListModel.fileFilter = array
                    console.log(array)
                }
                focusOutBehavior: -1
            }
        }

        SilicaListView {
            id: listView
            width: parent.width
            height: parent.height - y
            model: fileBrowserListModel
            clip: true

            VerticalScrollDecorator {}

            delegate: BackgroundItem {
                id: delegate
                enabled: model.valid
                opacity: model.valid ? 1.0 : 0.2

                Rectangle {
                    color: Theme.highlightColor
                    visible: model.path === absolutePath
                    anchors.fill: parent
                    opacity: 0.5
                }

                Image {
                    id: icon
                    source: "image://theme/icon-m-" + model.icon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    height: label.height
                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: label
                    x: icon.x + icon.width + 6
                    y: icon.y - icon.height + 6
                    text: model.file === ".." ? qsTr("Back") :
                              //: "Device Memory" is used in the file browser and means all files which are saved under home folder of the user
                              model.file === "..1" ? qsTr("Device Memory") :
                              model.file === "..2" ? qsTr("SD Card") :
                              model.file === "..3" ? qsTr("Android Storage") :
                              model.file
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                }

                onClicked: {
                    if(model.location !== 0) {
                        locationIndex = model.location
                        listView.enabled = false;
                        __dirName = model.path
                        __absoluteDirPath = model.path
                        absolutePath = "";
                        outAnimation.start()
                    } else {
                        if(model.icon !== "other") {
                            listView.enabled = false;
                            __dirName = model.file
                            __absoluteDirPath = model.path
                            absolutePath = "";
                            outAnimation.start()
                        } else {
                            if(model.path === absolutePath) {
                                absolutePath = "";
                            } else {
                                absolutePath = model.path;
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (absolutePath !== "") {
            fileBrowserListModel.loadFilePath(absolutePath)
            absolutePath = ""
        }
    }

    states: [
        State {
            name: "OPEN_FILE"
            PropertyChanges { target: fileSystemDialog; canAccept: absolutePath !== "" }
            PropertyChanges { target: newFileName; enabled: false }
            PropertyChanges { target: listView; y: header.y + header.height + fileFilter.height }
//                y: fileFilter.enabled ? header.y + header.height + fileFilter.height :
//                                        header.y + header.height
//            }
            PropertyChanges { target: fileBrowserListModel; showDirsOnly: false }
            PropertyChanges { target: showFileFilterMenuItem; enabled: true }
            PropertyChanges { target: fileFilter; enabled: fileBrowserListModel.showFileFilter}
        },
        State {
            name: "CREATE_NEW_FILE"
            PropertyChanges { target: fileSystemDialog; canAccept: fileBrowserListModel.validDir && fileNameField.text }
            PropertyChanges { target: newFileName; enabled: true }
            PropertyChanges { target: listView; y: header.y + header.height + newFileName.height }
            PropertyChanges { target: fileBrowserListModel; showDirsOnly: true }
            PropertyChanges { target: showFileFilterMenuItem; enabled: false }
            PropertyChanges { target: fileFilter; enabled: false }
        }
    ]
}
