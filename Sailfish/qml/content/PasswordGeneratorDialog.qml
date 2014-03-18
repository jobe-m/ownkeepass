/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
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
import "../scripts/Global.js" as Global
import "../common"
import harbour.ownKeepass.PasswordGenerator 1.0

Dialog {
    id: passwordGeneratorDialog

    property string generatedPassword: ""

    PasswordGenerator {
        id: passwordGenerator
        length: 12 // ownKeepassSettings.pwGenLength
        lowerLetters: true // ownKeepassSettings.pwGenLowerLetters
        upperLetters: true // ownKeepassSettings.pwGenUpperLetters
        numbers: true // ownKeepassSettings.pwGenNumbers
        specialCharacters: false // ownKeepassSettings.pwGenSpecialChars
        excludeLookAlike: true // ownKeepassSettings.pwGenExcludeLookAlike
        charFromEveryGroup: true // ownKeepassSettings.pwGenCharFromEveryGroup
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        PullDownMenu {
            MenuLabel {
                enabled: text !== ""
                text: applicationWindow.databaseUiName
            }
        }

        ApplicationMenu {
            disableSettingsItem: true
        }

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Generate password"
            }

//            SilicaLabel {
//                id: dialogTitle
//                font.pixelSize: Theme.fontSizeLarge
//                font.bold: true
//                text: "Generate password"
//            }

            Item {
                width: parent.width
                height: generatedPasswordTextArea.height + genPwTextAreaSeparator.height

                TextField {
                    id: generatedPasswordTextArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: showPasswordButton.left
                    echoMode: TextInput.Password
                    readOnly: true
                    label: "Password"
                    color: Theme.primaryColor
                }

                Separator {
                    id: genPwTextAreaSeparator
                    anchors.top: generatedPasswordTextArea.bottom
                    anchors.left: parent.left
                    width: generatedPasswordTextArea.width
                }

                IconButton {
                    id: showPasswordButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    icon.source: generatedPasswordTextArea.echoMode === TextInput.Normal ? "../../wallicons/icon-l-openeye.png" : "../../wallicons/icon-l-closeeye.png"
                    onClicked: {
                        if (generatedPasswordTextArea.echoMode === TextInput.Normal) {
                            generatedPasswordTextArea.echoMode = TextInput.Password
                        } else {
                            generatedPasswordTextArea.echoMode = TextInput.Normal
                        }
                    }
                }
            }

            Row {
                width: children.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                Switch {
                    id: lowerLetters
                    icon.source: "image://theme/icon-l-shuffle"
                    checked: true // ownKeepassSettings.pwGenLowerLetters
                    onCheckedChanged: {
                        generatedPasswordTextArea = passwordGenerator.generatePassword()
//                        ownKeepassSettings.pwGenLowerLetters =
                                passwordGenerator.lowerLetters = checked
                    }
                }

                Switch {
                    id: upperLetters
                    icon.source: "image://theme/icon-l-star"
                    checked: true // ownKeepassSettings.pwGenUpperLetters
                    onCheckedChanged: {
                        generatedPasswordTextArea = passwordGenerator.generatePassword()
//                        ownKeepassSettings.pwGenUpperLetters =
                                passwordGenerator.upperLetters = checked
                    }
                }

                Switch {
                    id: numbers
                    icon.source: "image://theme/icon-l-right"
                    checked: true // ownKeepassSettings.pwGenNumbers
                    onCheckedChanged: {
                        generatedPasswordTextArea = passwordGenerator.generatePassword()
//                        ownKeepassSettings.pwGenNumbers =
                                passwordGenerator.numbers = checked
                    }
                }

                Switch {
                    id: specialChars
                    icon.source: "image://theme/icon-l-usb"
                    checked: false // ownKeepassSettings.pwGenSpecialChars
                    onCheckedChanged: {
                        generatedPasswordTextArea = passwordGenerator.generatePassword()
//                        ownKeepassSettings.pwGenSpecialChars =
                                passwordGenerator.specialCharacters = checked
                    }
                }
            }

            Slider {
                id: passwordLength
                width: parent.width - Theme.paddingSmall * 2
                anchors.horizontalCenter: parent.horizontalCenter
                minimumValue: 4
                maximumValue: 64
                stepSize: 1
                valueText: value
                label: "Length"
                value: 12 // ownKeepassSettings.pwGenLength
                onValueChanged: {
                    passwordGenerator.length = value
                    generatedPasswordTextArea = passwordGenerator.generatePassword()
                    // ownKeepassSettings.pwGenLength = value
                }
            }

            TextSwitch {
                id: excludeLookAlike
                checked:true // ownKeepassSettings.pwGenExcludeLookAlike
                text: "Exclude look-alike characters"
                onCheckedChanged: {
                    passwordGenerator.excludeLookAlike = checked
                    generatedPasswordTextArea = passwordGenerator.generatePassword()
                    // ownKeepassSettings.pwGenExcludeLookAlike = checked
                }
            }

            TextSwitch {
                id: charFromEveryGroup
                checked: true // ownKeepassSettings.pwGenCharFromEveryGroup
                text: "Ensure that the password contains characters from every group"
                onCheckedChanged: {
                    passwordGenerator.charFromEveryGroup = checked
                    generatedPasswordTextArea = passwordGenerator.generatePassword()
                    // ownKeepassSettings.pwGenCharFromEveryGroup = checked
                }
            }
        }
    }

    Component.onCompleted: {
        generatedPasswordTextArea = passwordGenerator.generatePassword()
    }
//    Component.onDestruction: {
//    }

    onDone: {
        generatedPassword = generatedPasswordTextArea.text
    }
}
