import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: idComment

    signal clicked

    height: column.height

    Column {
        id: column
        anchors.left:parent.left
        anchors.right: parent.right
        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.highlightText
            wrapMode: Text.WordWrap
            text: decodeURIComponent(commentName) +" - "+Qt.formatDateTime(new Date(parseFloat(commentDate)), qsTr("dd MMM yyyy"))
        }
        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
            text: decodeURIComponent(commentText)
        }
    }
}

