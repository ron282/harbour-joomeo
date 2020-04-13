// No more used

import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants

Item {
    id: idComment

    signal clicked
    property string commentId
    property string name
    property string comment
    property string dateCreated

    height: idCommentDelegate.height


    Column {
        id: idCommentDelegate
        visible: true // showDetails

        width: 480

        Label {
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            text: name
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeTiny
            wrapMode: Text.WordWrap
            maximumLineCount: 1
        }
        Label {
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            text: comment
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
        }
    }
}

