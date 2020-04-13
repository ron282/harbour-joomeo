import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

BackgroundItem {
    property string sessionId
    property string fileId
    property string fileName
    property int rating
    property string nbComments

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
        height: 20

        opacity: 0.3
        color: "black"
        visible: parseInt(nbComments) > 0 || parseInt(rating) > 0
    }

    Image {
        source: "qrc:///icons/comments.png"
        visible: parseInt(nbComments) > 0
        x: 2
        anchors.verticalCenter: idDetails.verticalCenter
    }

    Image {
        id: idRating
        source: "qrc:///icons/rating.png"
        visible: rating > 0
        anchors.verticalCenter: idDetails.verticalCenter
        anchors.right:parent.right
    }

    Text {
        text: Math.round(rating/4)
        visible: rating > 0
        anchors.verticalCenter: idDetails.verticalCenter
        anchors.verticalCenterOffset: -1
        anchors.right: idRating.left
        font.pixelSize: 18
        color: "#cccccc"
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
