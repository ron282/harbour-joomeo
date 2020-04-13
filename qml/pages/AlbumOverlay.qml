import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: overlay

    property bool active: true
    property bool viewerOnlyMode

    property alias toolbar: toolbar
    property alias additionalActions: additionalActionsLoader.sourceComponent
    property alias detailsButton: detailsButton
    property alias deletingAllowed: deleteButton.visible
    readonly property bool allowed: isImage
    property alias topFade: topFade
    property alias fadeOpacity: topFade.fadeOpacity
    property alias legend: legendItem.text

    property url source
    property string itemId
    property bool isImage : true
    property bool error

    property Item _remorsePopup
    property Component additionalShareComponent

    function remorseAction(text, action) {
        if (!_remorsePopup) {
            _remorsePopup = remorsePopupComponent.createObject(overlay)
        }
        if (!_remorsePopup.active) {
            _remorsePopup.execute(text, action)
        }
    }

    signal remove
    signal details

    onSourceChanged: if (_remorsePopup && _remorsePopup.active) _remorsePopup.trigger()

    enabled: active && allowed && source != "" && !(_remorsePopup && _remorsePopup.active)
    Behavior on opacity { FadeAnimator {}}
    opacity: enabled ? 1.0 : 0.0

    FadeGradient {
        id: topFade

        width: parent.width
        height: detailsButton.height + 2 * detailsButton.y
        topDown: true
    }

    FadeGradient {
        id: bottomFade

        fadeOpacity: topFade.fadeOpacity
        width: parent.width
        height: toolbar.height + 2* toolbar.anchors.bottomMargin
        anchors.bottom: parent.bottom
    }

    Label {
        id: legendItem
        truncationMode: TruncationMode.Elide
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: toolbar.verticalCenter
            right: toolbar.left
        }
    }

    Row {
        id: toolbar
        layoutDirection: Qt.RightToLeft

        anchors  {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }

        spacing: Theme.paddingLarge

        Loader {
            id: additionalActionsLoader
            anchors.verticalCenter: parent.verticalCenter
        }

        IconButton {
            id: detailsButton
            icon.source: "image://theme/icon-m-about"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: overlay.details()
         }

        IconButton {
             id: deleteButton
             icon.source: "image://theme/icon-m-delete"
             anchors.verticalCenter: parent.verticalCenter
             onClicked: overlay.remove()
         }
     }

    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }
}
