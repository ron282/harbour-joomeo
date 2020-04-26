import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property alias message : idMessage.text

    Column {
        width: parent.width
        spacing: Theme.paddingLarge

        PageHeader {
            title: qsTr("Error")
        }

        Text {
            id: idMessage
            anchors { left:parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right }
            color: Theme.highlightColor
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.WordWrap
        }
        Button {
            id: ok
            text: qsTr("OK")
            anchors { horizontalCenter: parent.horizontalCenter }
            onClicked: {
                pageStack.pop()
            }
        }
    }
}

