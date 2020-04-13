// Page which displays the list of other accessible Joomeo accounts

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
// import Sailfish.Silica.theme 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests


Page {
    id: networkPage

    property bool testMode: false
    property bool pageBusy: true
    property string sessionId

    // Object to map Xml Response from a getNetworkRequest into listview items
    // Only three fields per item are kept to display the list view:
    // Id and Name of the contact and date/time of the last connection

    XmlListModel {
        id: xmlContactsModel
        query: "/methodResponse/params/param/value/array/data/value/struct"

        XmlRole { name: "contactId"; query: "member[name='contactid']/value/string/string()" }
        XmlRole { name: "contactName"; query: "member[name='username']/value/string/string()" }
        XmlRole { name: "lastVisit"; query: "member[name='lastvisit']/value/double/string()" }
    }

    SilicaListView {
        id: listView
        model: xmlContactsModel
        clip: true
        focus: true
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Network")
        }

        VerticalScrollDecorator {
            flickable: listView
        }

        ViewPlaceholder {
            id: idPlaceholder
            enabled: listView.count == 0
            text: xmlContactsModel.status == XmlListModel.Ready ? qsTr("Empty. Use Joomeo web site to connect to your contacts") : qsTr("Retrieving data...")
        }

        delegate: NetworkDelegate {

            // Link Xml data format to listview element properties
            contactId: model.contactId
            contactName : model.contactName
            lastVisit: model.lastVisit

            // What to do when a name is clicked
            onClicked: {
                HttpRequests.joomeoInitContact(sessionId, contactId, function (req) {
                    var ret
                    ret = HttpRequests.parseResponse(req.responseXML.documentElement)

                    pageStack.push(Qt.resolvedUrl("FolderPage.qml"),
                                   { sessionId : ret['sessionid'],
                                     spacename : ret['spacename'],
                                     sessionType : ret ['sessionType']});
                }, function() {

                })
            }
        }
    } // ListView

    // When the page is shown, a network request is sent to get
    // the list of contacts

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if(xmlContactsModel.xml == "") {
                HttpRequests.joomeoGetNetwork(sessionId,
                function(req) {
                    xmlContactsModel.xml = req.responseText
                },
                function() {
                    idPlaceholder.text = qsTr("Network error. Check your connection")
                }
                );
            }
        }
    }
}
