import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

// Network error dialog

Dialog {

    property alias message : idMessage.text

    Column {
        spacing: 10
        anchors.fill: parent

        DialogHeader {
            title: qsTr("Error")
        }

        Text {
            id: idMessage
            color: Theme.highlightColor
            font.family: Theme.fontFamilyHeading
            width: parent.width
            maximumLineCount: 4
            wrapMode: Text.WordWrap
        }
    }

} // Dialog

