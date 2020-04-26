import QtQuick 2.6
import Sailfish.Silica 1.0

import QtQuick.XmlListModel 2.0


import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

Page {
    id: albumSharingPage

    property alias sessionId : sharingDelegate.sessionId
    property alias albumId : sharingDelegate.albumId
    property alias accessList: sharingDelegate.accessList
    property string albumName

    SilicaListView {
        id: listContacts
        anchors.fill: parent
        clip:true

        VerticalScrollDecorator { flickable: listContacts }

        PullDownMenu {
            MenuItem {
                text: qsTr("Unselect all")
                onClicked: {
                   sharingDelegate.unselectAll()
                }
            }
        }
        header: Column {
            width: parent.width
            PageHeader {
                title: qsTr("Sharing of %1").arg(albumName)
            }
            SectionHeader {
                text: "Permissions"
            }
            Column {
                width: parent.width
                IconTextSwitch {
                    text: qsTr("View")
                    description: qsTr("Always enabled for selected contacts")
                    checked: true
                    icon.source: "image://theme/icon-m-share"
                    onClicked: checked = true
                }
                IconTextSwitch {
                    id: uploadButton
                    text: qsTr("Upload")
                    description: qsTr("Upload content in this album")
                    icon.source: "image://theme/icon-m-cloud-upload"
                    checked: sharingDelegate.allowUpload
                    automaticCheck: false
                    onClicked: sharingDelegate.setUpload(!checked)
                }
                SectionHeader {
                    text: qsTr("Authorized Contacts")
                }
            }
        }
        model: SharingDelegate {
            id: sharingDelegate

        }
    }
}



