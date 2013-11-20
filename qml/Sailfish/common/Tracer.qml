import QtQuick 2.0

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
}
