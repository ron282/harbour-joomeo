import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

ListItem {
    id: idFolderDelegate


    property string sessionId
    property int sessionType
    property string elementLabel
    property string elementAlbumId
    property string elementFolderId
    property alias nbFiles :  textNbFiles.text

    contentHeight: Theme.itemSizeExtraLarge // Theme.itemSizeMedium
    width: parent.width
    anchors.leftMargin: Theme.horizontalPageMargin
    anchors.rightMargin: Theme.horizontalPageMargin



    // Each Item is a row containing an Icon and a column of 2 text lines

    Image {
        id: idFolderDelegateImage
        anchors.fill:parent
        anchors.margins: 5
        smooth : true
        opacity: 0.70
        sourceSize.height: Screen.orientation === Qt.PrimaryOrientation ? Screen.height : Screen.width
        sourceSize.width: Screen.orientation === Qt.PortraitOrientation ? Screen.height : Screen.width
        fillMode: elementAlbumId == "" ? Image.Stretch : Image.PreserveAspectCrop
        verticalAlignment: Image.AlignVCenter

        BusyIndicator {
            id: idBusyIndicator
            running: false
            anchors.centerIn: parent
        }

        onStatusChanged:{
            if (status == Image.Ready) {
                idBusyIndicator.running = false
                idBusyIndicator.visible = false
            }
        }
    }

    Column {
        id: columnTexts
        Text {
            id: textAlbumName
            x: Theme.paddingLarge
            text: idFolderDelegate.elementLabel
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
        }
        Text {
             id: textNbFiles
             x: Theme.paddingLarge
             font.pixelSize: Theme.fontSizeTiny
            color: Theme.primaryColor
        }
    }

    // When an album item is displayed, a request is send to the server to get the number of files
    Component.onCompleted: {
        if(elementAlbumId != "") {
            if (idFolderDelegateImage.source == "") {
                HttpRequests.joomeoGetFirstFileUrl(sessionId, elementAlbumId,
                function (url) {
                    idFolderDelegateImage.source = url;
                    HttpRequests.joomeoGetNumberOfFiles(sessionId, elementAlbumId, function (nbfiles) {
                        if( nbfiles > 1) {
                            textNbFiles.text = qsTr("%1 photos").arg(nbfiles)
                         }
                        else {
                            textNbFiles.text = qsTr("%1 photo").arg(nbfiles)
                        }
                    },
                    function () {
                        // error
                        textNbFiles.text = qsTr("? photo")
                    })
                },
                function () {
                    // error
                    idFolderDelegateImage.source = "";
                    textNbFiles.text = qsTr("No photo")
                } )
            }
        }
        else
        {
            idFolderDelegateImage.source = "qrc:///icons/folder.png"
        }
    }

    menu:
        ContextMenu {

        hasContent: (sessionType == 0)

        MenuItem {
            text: qsTr("Rename")
            visible: (elementFolderId != "")
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("DialogPage.qml"),
                                            { "name": elementLabel,
                                              "caption":qsTr("Folder name"),
                                              "header": qsTr("Rename folder")})

                dialog.accepted.connect(function() {
                    HttpRequests.joomeoUpdateFolder(sessionId,
                                                    elementFolderId,
                                                    dialog.name,
                                                    function () {
                                                        model.elementLabel = dialog.name
                                                    },
                                                    function () {
                                                        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                       {message : qsTr("Network problem\nCheck your connection")})

                                                    })
                })
            }
        }

        MenuItem {
            text: qsTr("Delete")
            visible: (elementFolderId != "")
            onClicked: {
                remorseAction(qsTr("Rename"),
                              function() {
                                  HttpRequests.joomeoDeleteFolder(sessionId,
                                                                  elementFolderId,
                                                                  function (req) {
                                                                      HttpRequests.joomeoGetFolderChildren(sessionId, folderId,
                                                                                                           function  (req) {
                                                                                                               xmlFolderModel.xml = req.responseText
                                                                                                               xmlFolderModel.reload()
                                                                                                           },
                                                                                                           function  () {
                                                                                                               pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                                                              {message : qsTr("Network problem\nCheck your connection")})

                                                                                                           })
                                                                  },
                                                                  function () {
                                                                      pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                     {message : qsTr("Network problem\nCheck your connection")})

                                                                  })
                              })
            }
        }
        MenuItem {
            text: qsTr("Rename")
            visible: (elementAlbumId != "")
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("DialogPage.qml"),
                                            { "name": elementLabel,
                                              "caption":qsTr("Album name"),
                                              "header": qsTr("Rename Album")})
                dialog.accepted.connect(function() {
                    HttpRequests.joomeoUpdateAlbum(sessionId,
                                                   elementAlbumId,
                                                   dialog.name,
                                                   function (req) {
                                                       model.elementLabel = dialog.name
                                                       model.reload()
                                                   },
                                                   function () {
                                                       pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                      {message : qsTr("Network problem\nCheck your connection")})

                                                   }) })
            }
        }

        MenuItem {
            text: qsTr("Delete")
            visible: (elementAlbumId != "")
            onClicked: {
                remorseAction(qsTr("Delete"),
                              function() {
                                  HttpRequests.joomeoDeleteAlbum(sessionId,
                                                                 elementAlbumId,
                                                                 function (req) {
                                                                     HttpRequests.joomeoGetFolderChildren(sessionId, folderId,
                                                                                                          function (req) {
                                                                                                              xmlFolderModel.xml = req.responseText
                                                                                                              xmlFolderModel.reload()
                                                                                                          },
                                                                                                          function () {
                                                                                                          })

                                                                 },
                                                                     function () {
                                                                         pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                        {message : qsTr("Network problem\nCheck your connection")})

                                                                     }
)
                              })
            }
        }
    }
}
