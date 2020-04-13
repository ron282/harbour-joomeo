// Display each item of the list of ContactsPage
// Each Item is contained in a Rectangle. Inside the Rectangle there is a Row containing
// an Icon and a Column with 2 texts : the contact name and last visit date
// The Icon is a static image because there is no function in the api to get the picture
// of the contact
// If the user clicks on an item, the message is forwarded to the instance of idNetworkDelegate
// in order to be managed by the delegate item of the albumsPage.
//
// To improve:
// - Highlight item when clicked
// - reduce code for sizing objects

import QtQuick 2.0
import Sailfish.Silica 1.0
// import Sailfish.Silica.theme 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

BackgroundItem {
    id: idNetworkDelegate

    signal clicked;

    property string contactId
    property string contactName
    property string lastVisit

    // Each Item is a row containing an Icon and a column of 2 text lines

    width: Screen.width
    height: Theme.itemSizeMedium

    Row {
        spacing: 10
        anchors.topMargin: Theme.paddingLarge

        Row {
            spacing: Theme.paddingSmall

            Image {
                smooth: true
                source :"qrc:///icons/contact.png"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
            }

            Column {
                Text {
                    id: textContactName
                    text: idNetworkDelegate.contactName
                    font.pixelSize: Theme.fontSizeMedium
                    color: "white"
                }
                Text {
                    id: textLastVisit
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    text: qsTr("Last visit:")+Qt.formatDateTime(new Date(parseFloat(idNetworkDelegate.lastVisit)), qsTr("dd MMM yyyy hh:mm:ss"))
                }
            }
        }

    }

    MouseArea {
        id: idNetworkDelegateMouseArea
        anchors.fill: parent
        onClicked:
            idNetworkDelegate.clicked();
    }
}
