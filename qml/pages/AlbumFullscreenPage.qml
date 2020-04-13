import QtQuick 2.0
import Sailfish.Silica 1.0

FullscreenContentPage {
    id: root

    property alias model: imageView.model
    property alias currentIndex: imageView.currentIndex
    property alias viewerOnlyMode: imageView.viewerOnlyMode
    property alias sessionId: imageView.sessionId
    property alias sessionType: imageView.sessionType

    signal requestIndex(int index)

    objectName: "fullscreenPage"
    allowedOrientations: Orientation.All

    onCurrentIndexChanged: {
        if (status !== PageStatus.Active) {
            return
        }
        if (model === undefined || currentIndex >= model.count) {
            // This can happen if all of the images are deleted
            var firstPage = pageStack.previousPage(root)
            while (pageStack.previousPage(firstPage)) {
                firstPage = pageStack.previousPage(firstPage)
            }
            pageStack.pop(firstPage)
            return
        }
        requestIndex(currentIndex)
        pageStack.previousPage(root).jumpToIndex(currentIndex)
    }

    // Element for handling the actual flicking and image buffering
    FlickableImageView {
        id: imageView

        anchors.fill: parent
        objectName: "flickableView"
    }
    VerticalPageBackHint {}
}
