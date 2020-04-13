import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

Page {
    id: folderPage

    property string spacename
    property int sessionType
    property string sessionId
    property string contactId
    property string folderId
    property string folderName
    property bool uploading: true

    objectName: sessionType == 0 && folderId == "" ? "mainFolderPage" : "folderPage"

    // Object to map Xml Response from Joomeo into listview items
    // Only two fields per item are kept to display the list view: label and albumid

    XmlListModel {
        id: xmlFolderModel

        query: "/methodResponse/params/param/value/array/data/value/struct"

        XmlRole { name: "elementFolderId"; query: "member[name='folderid']/value/string/string()";  }
        XmlRole { name: "elementAlbumId"; query: "member[name='albumid']/value/string/string()"; }
        XmlRole { name: "elementLabel"; query: "member[name='label']/value/string/string()" }
    }

    SilicaListView {
        id: listView

        model: xmlFolderModel
        clip: true
        anchors.fill: parent

        property Item contextMenu

        header: PageHeader {
            title: folderId == "" ? qsTr("%1's albums").arg(spacename) : folderName
        }

        VerticalScrollDecorator {
            flickable: listView
        }

        PullDownMenu {
            MenuItem {
                visible:  sessionType === 0
                text: qsTr("Add album")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("DialogPage.qml"),
                                                {"name": "",
                                                 "caption":qsTr("Album name"),
                                                 "header": qsTr("Add Album")})

                    dialog.accepted.connect(function() {
                        HttpRequests.joomeoAddAlbum(sessionId, dialog.name, folderId,
                                                    function (req) {
                                                        // Added
                                                        HttpRequests.joomeoGetFolderChildren(sessionId, folderId,
                                                                                             function (req) {
                                                                                                 xmlFolderModel.xml = req.responseText
                                                                                                 xmlFolderModel.reload()
                                                                                             },
                                                                                             function () {
                                                                                                 pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                                                {message : qsTr("Network problem\nCheck your connection")})

                                                                                             })
                                                    }, function () {
                                                        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                       {message : qsTr("Network problem\nCheck your connection")})

                                                    }) })
                }
            }
            MenuItem {
                visible:  sessionType === 0
                text: qsTr("Add folder")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("DialogPage.qml"),
                                                {"name": "",
                                                 "caption":qsTr("Folder name"),
                                                 "header":qsTr("Add Folder")})
                    dialog.accepted.connect(function() {
                        HttpRequests.joomeoAddFolder(sessionId, dialog.name, folderId, function (req) {
                            // Added
                            HttpRequests.joomeoGetFolderChildren(sessionId, folderId,
                                                                 function (req) {
                                                                     xmlFolderModel.xml = req.responseText
                                                                     xmlFolderModel.reload()
                                                                 },
                                                                 function () {
                                                                     pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                    {message : qsTr("Network problem\nCheck your connection")})
                                                                 })
                        }, function reject() {
                            pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                           {message : qsTr("Network problem\nCheck your connection")})

                        }) })
                }
            }
            MenuItem {
                text: qsTr("Network")
                visible: (folderId == "") && (sessionType === 0)
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("NetworkPage.qml"),
                                   { sessionId: sessionId });
                }
            }
            MenuItem {
                text: qsTr("My albums")
                visible: sessionType == 1
                onClicked: {
                    pageStack.pop(pageStack.find(function(p) { return p.objectName == "mainFolderPage" }));
                }
            }
        }

        delegate: FolderDelegate {
            sessionId : folderPage.sessionId
            sessionType: folderPage.sessionType

            // Link Xml data format to listview element properties
            elementLabel: model.elementLabel
            elementAlbumId : model.elementAlbumId
            elementFolderId : model.elementFolderId

            // Display Files Page when an album is clicked

            onClicked: {
                if(elementAlbumId == "")
                {
                    pageStack.push(Qt.resolvedUrl("FolderPage.qml"),
                                   { spacename: spacename,
                                     sessionId: sessionId,
                                     folderId: elementFolderId,
                                     folderName: elementLabel,
                                     sessionType: sessionType});
                }
                else
                {
                    pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),
                                   { sessionId: sessionId,
                                     albumId: elementAlbumId,
                                     albumLabel: elementLabel,
                                     sessionType: sessionType});
                }
            }
        }

        BusyIndicator {
            running: uploading
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
        }
    }

    // Network error dialog
    ErrorDialog {
        id: networkErrorDialog
        message : qsTr("Network problem.\n Check your connection.")
    } // Dialog

    onStatusChanged: {
        if(xmlFolderModel.xml == "") {
            uploading = true

            HttpRequests.joomeoGetFolderChildren(sessionId, folderId,
                                                 function (req) {
                                                     xmlFolderModel.xml = req.responseText
                                                     uploading = false
                                                 },
                                                 function () {
                                                     // Error
                                                     uploading = false
                                                 });
        }
     }
}
