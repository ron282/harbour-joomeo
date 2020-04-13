import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: idDialogPage

    canAccept: idText.text.length > 0

    property string name
    property string caption
    property string header


    Column {
        width: parent.width

        DialogHeader {
            acceptText: header
        }

        TextField {
            id: idText
            anchors { left: parent.left; right: parent.right }
            label: caption; placeholderText: label
            EnterKey.enabled: text || inputMethodComposing
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            text: name
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            name = idText.text
        }
    }
}



