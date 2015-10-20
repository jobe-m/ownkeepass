import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    anchors.fill: parent
    color: "red"
    opacity: 0.3

    Rectangle {
        anchors.fill: parent
        border.color: parent.color
        border.width: 1
        color: "transparent"
        opacity: 1.0
    }

    Label {
        text: parent.width + "x" + parent.height
        font.pixelSize: Theme.fontSizeTiny
        color: "red"
    }
}
