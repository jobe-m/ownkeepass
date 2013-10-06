// TODO add copyright header

import QtQuick 2.0
import Sailfish.Silica 1.0

// TODO adapt to Sailfish
Page {
    id: changePasswordPage

    property string pageTitle : "Change Password"

    tools: commonTools

    Component.onCompleted: {
        captionPasswordField.setFocus()
    }

    KdbDatabase {
        id: kdbDatabase
        onDatabasePasswordChanged: {
            if (result !== KdbDatabase.RE_OK) {
                infoDialog.message = "Could not change password for Keepass database. That's strange! Error message: " + errorMsg
                infoDialog.open()
            }
        }
    }

    PageHeader {
        id: pageHeader
        pageTitle: changePasswordPage.pageTitle
    }

    Flickable {
        id: flickable
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        contentHeight: topSpacer.height + captionPasswordField.height +
                       changePasswordButton.height + changePasswordButton.anchors.topMargin

        Item {
            id: topSpacer
            width: parent.width
            height: screen.currentOrientation === Screen.Portrait ? Constants.SPACE_LABEL * 3 : 0
        }

        CaptionPasswordField {
            id: captionPasswordField
            anchors.top: topSpacer.bottom
            passwordLabelText: "Type in a new master password for locking your Keepass database:"
            showVerifyPasswordField: true
            onPasswordChanged: {
                // simulate same behavior as if "Open" Button was clicked, ie. close the keypad
                changePasswordButton.forceActiveFocus()
                kdbDatabase.changePassword(password)
                pageStack.pop()
            }
        }

        Button {
            id: changePasswordButton
            enabled: captionPasswordField.getPassword !== ""
            anchors.top: captionPasswordField.bottom
            anchors.right: parent.right
            anchors.topMargin: Constants.SPACE_LABEL * 2
            anchors.rightMargin: 15
            width: 160
            checked: true
            text: "Save"
            onClicked: {
                kdbDatabase.changePassword(captionPasswordField.getPassword)
                pageStack.pop()
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    QueryDialog {
        id: infoDialog
        titleText: "Error during Password change"
        acceptButtonText: "OK"
    }
}
