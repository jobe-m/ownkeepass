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
import "../components"
import harbour.ownkeepass 1.0

Dialog {
    id: passwordGeneratorDialog

    property string generatedPassword: ""

    canNavigateForward: !generatedPasswordField.errorHighlight
    allowedOrientations: applicationWindow.orientationSetting

    PasswordGenerator {
        id: passwordGenerator
        length: ownKeepassSettings.pwGenLength
        lowerLetters: ownKeepassSettings.pwGenLowerLetters
        upperLetters: ownKeepassSettings.pwGenUpperLetters
        numbers: ownKeepassSettings.pwGenNumbers
        specialCharacters: ownKeepassSettings.pwGenSpecialChars
        excludeLookAlike: ownKeepassSettings.pwGenExcludeLookAlike
        charFromEveryGroup: ownKeepassSettings.pwGenCharFromEveryGroup
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        PullDownMenu {
            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
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
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Accept")
                cancelText: qsTr("Discard")
            }

            PasswordField {
                id: generatedPasswordField
                width: parent.width
                showEchoModeToggle: true
                readOnly: true
                label: qsTr("Generated password")
                placeholderText: qsTr("No char group selected")
                errorHighlight: text.length === 0
                onErrorHighlightChanged: {
                    if (errorHighlight) {
                        font.family = defaultFontFamily
                        placeholderText = qsTr("No char group selected")
                    } else {
                        // First clear placeholder text so that it does not seem to jump bigger before fading out
                        placeholderText = ""
                        font.family = 'monospace'
                    }
                }

                color: Theme.primaryColor
                Component.onCompleted: {
                    defaultFontFamily = font.family
                    font.family = 'monospace'
                }
                property string defaultFontFamily: ""
            }

            Slider {
                id: passwordLength
                width: parent.width - Theme.paddingSmall * 2
                anchors.horizontalCenter: parent.horizontalCenter
                minimumValue: 4
                maximumValue: 64
                stepSize: 1
                valueText: value
                label: qsTr("Length")
                value: ownKeepassSettings.pwGenLength
                onValueChanged: {
                    passwordGenerator.length = value
                    generatedPasswordField.text = passwordGenerator.generatePassword()
                    ownKeepassSettings.pwGenLength = value
                }
            }

            Row {
                width: children.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                PasswordCharSwitch {
                    a: "a"; b: "b"; c: "c"; d: "d"
                    checked: ownKeepassSettings.pwGenLowerLetters
                    onCheckedChanged: {
                        passwordGenerator.lowerLetters = checked
                        generatedPasswordField.text = passwordGenerator.generatePassword()
                        ownKeepassSettings.pwGenLowerLetters = checked
                    }
                }

                PasswordCharSwitch {
                    a: "A"; b: "B"; c: "C"; d: "D"
                    checked: ownKeepassSettings.pwGenUpperLetters
                    onCheckedChanged: {
                        passwordGenerator.upperLetters = checked
                        generatedPasswordField.text = passwordGenerator.generatePassword()
                        ownKeepassSettings.pwGenUpperLetters = checked
                    }
                }


                PasswordCharSwitch {
                    a: "1"; b: "2"; c: "3"; d: "4"
                    checked: ownKeepassSettings.pwGenNumbers
                    onCheckedChanged: {
                        passwordGenerator.numbers = checked
                        generatedPasswordField.text = passwordGenerator.generatePassword()
                        ownKeepassSettings.pwGenNumbers = checked
                    }
                }

                PasswordCharSwitch {
                    a: "#"; b: "/"; c: "@"; d: "$"
                    checked: ownKeepassSettings.pwGenSpecialChars
                    onCheckedChanged: {
                        passwordGenerator.specialCharacters = checked
                        generatedPasswordField.text = passwordGenerator.generatePassword()
                        ownKeepassSettings.pwGenSpecialChars = checked
                    }
                }
            }

            TextSwitch {
                id: excludeLookAlike
                checked: ownKeepassSettings.pwGenExcludeLookAlike
                text: qsTr("Exclude look-alike characters")
                onCheckedChanged: {
                    passwordGenerator.excludeLookAlike = checked
                    generatedPasswordField.text = passwordGenerator.generatePassword()
                    ownKeepassSettings.pwGenExcludeLookAlike = checked
                }
            }

            TextSwitch {
                id: charFromEveryGroup
                checked: ownKeepassSettings.pwGenCharFromEveryGroup
                text: qsTr("Ensure that the password contains characters from every group")
                onCheckedChanged: {
                    passwordGenerator.charFromEveryGroup = checked
                    generatedPasswordField.text = passwordGenerator.generatePassword()
                    ownKeepassSettings.pwGenCharFromEveryGroup = checked
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Generate")
                onClicked: {
                    generatedPasswordField.text = passwordGenerator.generatePassword()
                }
            }
        }
    }

    Component.onCompleted: {
        generatedPasswordField.text = passwordGenerator.generatePassword()
    }

    onDone: {
        generatedPassword = generatedPasswordField.text
    }
}
