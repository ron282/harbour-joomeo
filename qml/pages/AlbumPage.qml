// Display files (currently only photos) of an albumId

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import QtQuick.XmlListModel 2.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

Page {
    id: idAlbumPage

    property string sessionId
    property int sessionType
    property string albumId
    property string albumLabel
    property bool uploading: false

    function jumpToIndex(index) {
        if (index < idGridPhotos.columnCount)
            idGridPhotos.positionViewAtBeginning()
        else
            idGridPhotos.positionViewAtIndex(index, GridView.Visible)
        idGridPhotos.currentIndex = index
    }

    // Grid with photos. Displayed in columns in portrait mode

    SilicaGridView {
        id: idGridPhotos

        //clip: true
        anchors.fill: parent

        VerticalScrollDecorator {
            flickable: idGridPhotos
        }

        PullDownMenu {   
            MenuItem {
                text: qsTr("My albums")
                visible: sessionType == 1
                onClicked: {
                    pageStack.pop(pageStack.find(function(p) { return p.objectName === "mainFolderPage" }));
                }
            }
            MenuItem {
                visible: sessionType === 0
                text: qsTr("Upload file")
                onClicked: {
                    // This is the only to display a file picker compatible with
                    // Harbour requirements
                    var imagePicker = pageStack.push(imagePickerPage);

                    imagePicker.selectedContentChanged.connect(function() {
                        uploading = true

                        imageUploader.uploadImage(HttpRequests.getUploadUrl(sessionId), imagePicker.selectedContent)
                    });
                }
            }
            MenuItem {
                visible: false // Not yet implemented
                text: qsTr("Play Slideshow")
                onClicked: {
                    idGridPhotos.currentIndex = 0
                    pageStack.push(idZoomedPageContainer, {slideShow : true })
                }
            }
        }

        header:  PageHeader {
            id: header
            title: idAlbumPage.albumLabel

            HarbourBadge {
                anchors {
                    left: header.extraContent.left
                    verticalCenter: header.extraContent.verticalCenter
                }
                maxWidth: header.extraContent.width
                text: xmlFilesModel.count ? xmlFilesModel.count : ""
            }
        }

        model: AlbumListModel {
            id: xmlFilesModel
        }

        ViewPlaceholder {
            id: idPlaceholder
            enabled: idGridPhotos.count == 0
            text: xmlFilesModel.status == XmlListModel.Ready ? qsTr("Empty") : qsTr("Retrieving data...")
        }

        readonly property real pageHeight: Math.ceil(idAlbumPage.height + pageStack.panelSize)

        readonly property Item contextMenu: currentItem ? currentItem._menuItem : null
        readonly property bool contextMenuActive: contextMenu && contextMenu.active

        // Figure out which delegates need to be moved down to make room
        // for the context menu when it's open.
        readonly property int minOffsetIndex: contextMenu ? currentIndex - (currentIndex % columns) + columns : 0
        readonly property int yOffset: contextMenu ? contextMenu.height : 0

        readonly property int rows: Math.floor(pageHeight / minimumCellHeight)
        readonly property int columns: 3

        readonly property int horizontalMargin: idAlbumPage.largeScreen ? 6 * Theme.paddingLarge : Theme.paddingLarge
        readonly property int initialCellWidth: (idAlbumPage.width - 2*horizontalMargin) / columns

        // The multipliers below for Large screens are magic. They look good on Jolla tablet.
        readonly property real minimumCellWidth: idAlbumPage.largeScreen ? Theme.itemSizeExtraLarge * 1.6 : Theme.itemSizeExtraLarge
        // phone reference row height: 960 / 6
        readonly property real minimumCellHeight: idAlbumPage.largeScreen ? Theme.itemSizeExtraLarge * 1.6 : Theme.pixelRatio * 160

        cellHeight: Screen.width/columns
        cellWidth: Screen.width/columns

        width: cellWidth * columns
        currentIndex: -1
        anchors.horizontalCenter: parent.horizontalCenter
        displaced: Transition { NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad; duration: 200 } }
        cacheBuffer: cellHeight * 2

        onVisibleChanged: {
            if (!visible && contextMenuActive) {
                contextMenu.hide()
            }
        }

        delegate: ListItem {
            id: container

            property real offsetY: 0

            width: idGridPhotos.cellWidth
            contentHeight: idGridPhotos.cellHeight

            _showPress: false

            menu: ContextMenu {
                property Item view
                property Item delegate

                // FavoriteGrid doesn't fill the entire page thus set width to Grid's parent
                width: _flickable !== null ? _flickable.parent.width : (parent ? parent.width : 0)

                MenuItem {
                    text: qsTr("Save in gallery")
                    visible: model.allowDownload === 1
                    onClicked: {
                        fileDownloader.downloadFile(HttpRequests.getFileUrl(sessionId, model.albumId, model.fileId, "original"), fileId+".jpg")
                    }
                }

                MenuItem {
                    text: qsTr("Delete")
                    visible: sessionType === 0
                    onClicked: {
                        remorseAction(qsTr("Delete album"),
                                      function() {
                                          HttpRequests.joomeoDeleteFile(sessionId,
                                                                        model.albumId,
                                                                        model.fileId,
                                                                        function resolve(req) {
                                                                            /*
                                                                            HttpRequests.joomeoGetFilesList(sessionId, albumId,
                                                                                                            function resolve (req){
                                                                                                                xmlFilesModel.xml = req.responseText
                                                                                                                xmlFilesModel.reload()
                                                                                                            },
                                                                                                            function reject() {
                                                                                                                pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                                                                               {message : qsTr("Network problem\nCheck your connection")})

                                                                                                            });*/
                                                                         xmlFilesModel.reload()

                                                                        },
                                                                        function reject() {
                                                                        xmlFilesModel.reload()
                                                                        //    pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {message : qsTr("Network problem\nCheck your connection")})
                                                                        })
                                      })
                    }
                }
            }

            down: albumDelegateId.down
            showMenuOnPressAndHold: false
            // Do not capture mouse events here. This ListItem only handles
            // menu creation and destruction.
            enabled: false

            AlbumDelegate {
                id: albumDelegateId
                sessionId: idAlbumPage.sessionId
                fileId: model.fileId
                rating: model.rating
                nbComments: model.nbComments

                width: idGridPhotos.cellWidth
                height: idGridPhotos.cellHeight
                y: index >= idGridPhotos.minOffsetIndex ? idGridPhotos.yOffset : 0.0

                onClicked: {
                    // Show Photo view here
                    idGridPhotos.currentIndex = index

                    pageStack.push(Qt.resolvedUrl("AlbumFullscreenPage.qml"), {
                                       currentIndex: index,
                                       model: xmlFilesModel,
                                       sessionId: idAlbumPage.sessionId,
                                       sessionType: sessionType
                                   })
                }

                onShowContextMenuChanged: {
                    if (showContextMenu && sessionType === 0) {
                        // Set currentIndex for grid to make minOffsetIndex calculation to work.
                        idGridPhotos.currentIndex = model.index

                        container.openMenu(
                                    {
                                        "view": idGridPhotos,
                                        "delegate": container
                                    })
                    }
                }


            }

            GridView.onAdd: AddAnimation { target: albumDelegateId }
            GridView.onRemove: animateRemoval()
        }
    }

    onStatusChanged: {
        if (xmlFilesModel.xml == "") {
                HttpRequests.joomeoGetFilesList(sessionId,
                                                albumId,
                                                function resolve (req){
                                                    xmlFilesModel.xml = req.responseText
                                                },
                                                function reject() {
                                                    pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {message : qsTr("Network problem\nCheck your connection")})
                                                })

        }
    }

    BusyIndicator {
        running: uploading
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    Connections { // to receive "imageUploaded" signal from the C++ code
        target: imageUploader

        onImageUploaded: {
            if(errorCode == 0) {

                HttpRequests.joomeoSaveUploadedFile(sessionId, albumId, uploadId, fileName,
                                                    function resolve(req) {
                                                        HttpRequests.joomeoGetFilesList(sessionId, albumId,
                                                                                        function resolve (req){
                                                                                            xmlFilesModel.xml = req.responseText
                                                                                            xmlFilesModel.reload()
                                                                                        },
                                                                                        function reject() {
                                                                                            pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {message : qsTr("Network problem\nCheck your connection")})
                                                                                        })

                                                        uploading = false
                                                        xmlFilesModel.reload()
                                                    },
                                                    function reject() {
                                                        uploading = false
                                                        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {message : qsTr("Network problem\nCheck your connection")})

                                                    })
            }
        }
    }


    Component {
        id: imagePickerPage
        ImagePickerPage {
            onSelectedContentPropertiesChanged: {
                selectedImage.source = selectedContentProperties.filePath
            }
        }
    }

    Connections { // to receive "DownloadFileFinished" signal from the C++ code
        target: fileDownloader

        onFileDownloaded: {
            console.log("download file finished")
        }
    }
}







