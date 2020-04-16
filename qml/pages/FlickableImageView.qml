import QtQuick 2.0
import Sailfish.Silica 1.0
import "HttpRequests.js" as HttpRequests

SlideshowView {
    id: root

    property alias viewerOnlyMode: overlay.viewerOnlyMode
    property string sessionId
    property int sessionType

    Component.onCompleted: {

    }

    itemWidth: width
    itemHeight: height
    interactive: count > 1

    property Item previousItem
    onMovingChanged: {
        if (moving) {
            previousItem = currentItem
        }
    }

    delegate: Loader {
        readonly property url source: HttpRequests.getFileUrl(sessionId, model.albumId, model.fileId, "large")
        readonly property string albumId : model.albumId
        readonly property string fileId : model.fileId
        readonly property bool isImage: model.mimeType.indexOf("image/") === 0
        readonly property bool isCurrentItem: PathView.isCurrentItem
        readonly property bool error: item && item.error
        readonly property string fileName : model.fileName
        readonly property int fileRating: model.rating
        readonly property string fileType: model.joomeo_type
        readonly property int fileSize: model.size
        readonly property int fileWidth: model.width
        readonly property int fileHeight: model.height
        readonly property string fileDateShooting: model.dateShooting
        readonly property string fileLegend: model.legend
        readonly property int nbComments: model.nbComments

        width: root.width
        height: root.height
        active: true
        sourceComponent: imageComponent
        asynchronous: !isCurrentItem

        Component {
            id: imageComponent

            ImageViewer {
                onZoomedChanged: overlay.active = !zoomed
                onClicked: {
                    if (zoomed) {
                        zoomOut()
                    } else {
                        overlay.active = !overlay.active
                    }
                }

                source: HttpRequests.getFileUrl(sessionId, model.albumId, model.fileId, "large")
                active: isCurrentItem
                contentRotation: model.fileRotation
                viewMoving: root.moving
            }
        }
    }

    AlbumOverlay {
        id: overlay

        onRemove: {
            var source = overlay.source
            remorseAction(qsTr("Delete"), function() {
                // here put command to remove file
                if (source === overlay.source) pageStack.pop()
            })
        }
        onDetails: {
            pageStack.push("DetailsPage.qml",
                                   { sessionId: root.sessionId,
                                     sessionType: root.sessionType,
                                     albumId: currentItem.albumId,
                                     fileId: currentItem.fileId,
                                     fileNameValue: currentItem.fileName,
                                     ratingValue: currentItem.fileRating,
                                     typeValue: currentItem.fileType,
                                     sizeValue: currentItem.fileSize,
                                     widthValue: currentItem.fileWidth,
                                     heightValue: currentItem.fileHeight,
                                     dateShootingValue: currentItem.fileDateShooting })
        }

        source: currentItem ? currentItem.source : ""
        isImage: currentItem ? currentItem.isImage : true
        error: currentItem && currentItem.error
        deletingAllowed: false // sessionType === 0
        legend: currentItem ? currentItem.fileLegend : ""
        commentsVisible: currentItem.nbComments > 0

        anchors.fill: parent
        z: 100

        IconButton {
            property bool popPageOnClick: true

            onClicked: if (popPageOnClick) {
               pageStack.pop()
            }

            y: Theme.paddingLarge
            icon.source: "image://theme/icon-m-dismiss"
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
        }
    }
}
