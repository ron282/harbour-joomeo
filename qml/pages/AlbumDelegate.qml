import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

BackgroundItem {
    property string sessionId
    readonly property bool showContextMenu: down && _pressAndHold
    property bool _pressAndHold

    layer.effect: PressEffect {}
    layer.enabled: down
    _showPress: false

    onPressAndHold: {
        _pressAndHold = true
        idAlbumPage.focus = true
    }

    onDownChanged: {
        if (!down) {
            _pressAndHold = false
        }
    }

    Image {
        id: idAlbumDelegateImage
        source: HttpRequests.getFileUrl( sessionId, albumId, fileId, "small")
        rotation: fileRotation
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.height: idGridPhotos.cellHeight
        sourceSize.width: idGridPhotos.cellWidth

        anchors.fill: parent
        anchors.margins: 5

        smooth: true
        clip: true

        onStatusChanged:{
            if (status == Image.Ready) {
                idBusyIndicator.running = false
                idBusyIndicator.visible = false
            }
        }

        BusyIndicator {
            id: idBusyIndicator
            anchors.centerIn: parent
            running: true
            visible: true
        }
    }

    Rectangle {
        id: idDetails
        width: parent.width
        height: messageIcon.height
        anchors.bottom: idAlbumDelegateImage.bottom

        opacity: 0.3
        color: "black"
        visible: (nbComments > 0) || (rating > 0)
    }

    Image {
        id: ratingIcon1
        source: "image://theme/icon-s-favorite"
        visible: rating > 2
        anchors { verticalCenter: idDetails.verticalCenter; left:parent.left; leftMargin: 2 }
    }
    Image {
        id: ratingIcon2
        source: "image://theme/icon-s-favorite"
        visible: rating > 6
        anchors { verticalCenter: idDetails.verticalCenter; left:ratingIcon1.right; leftMargin: 2 }
    }
    Image {
        id: ratingIcon3
        source: "image://theme/icon-s-favorite"
        visible: rating > 10
        anchors { verticalCenter: idDetails.verticalCenter; left:ratingIcon2.right; leftMargin: 2 }
    }
    Image {
        id: ratingIcon4
        source: "image://theme/icon-s-favorite"
        visible: rating > 14
        anchors { verticalCenter: idDetails.verticalCenter; left:ratingIcon3.right; leftMargin: 2 }
    }

    Image {
        id: messageIcon
        source: "image://theme/icon-m-activity-messaging"
        visible: nbComments > 0
        height: ratingIcon1.height
        fillMode: Image.PreserveAspectFit
        anchors { right: parent.right; rightMargin: 2; verticalCenter: idDetails.verticalCenter }
    }
    Rectangle {
        id: mask
        color: "black"
        anchors.fill: idAlbumDelegateImage
        visible: false
    }

    ShaderEffect {
        id: shaderItem
        property variant source: idAlbumDelegateImage
        property variant maskSource: mask

        enabled: false
        visible: false
        anchors.fill: idAlbumDelegateImage
        smooth: true

        fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform highp float qt_Opacity;
        uniform lowp sampler2D source;
        uniform lowp sampler2D maskSource;
        void main(void) {
            gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
        }
    "
    }
}
