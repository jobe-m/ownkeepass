import QtQuick 2.0
import Sailfish.Silica 1.0

PageHeader {

    property string subTitle: ""

    Label {
        text: subTitle
        color: Theme.highlightColor
        anchors {
            right: parent.right
            rightMargin: Theme.paddingLarge
            bottom: parent.bottom
            bottomMargin: Theme.paddingSmall
        }
        font {
            pixelSize: Theme.fontSizeExtraSmall
            family: Theme.fontFamilyHeading
        }
    }
}
