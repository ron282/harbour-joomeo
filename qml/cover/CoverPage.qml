import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        id: bgimg
        source: "qrc:///images/coverbg.png"
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
    }

/*CoverActionList {
        id: coverAction
        
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
        }
        
        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }*/
}


