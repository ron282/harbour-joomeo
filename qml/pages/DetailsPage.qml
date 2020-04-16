import QtQuick 2.6
import Sailfish.Silica 1.0

import QtQuick.XmlListModel 2.0


import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

Page {
    id: detailsPage

    property string sessionId
    property int sessionType
    property string albumId
    property string fileId
    property string fileNameValue
    property int ratingValue
    property int  typeValue
    property int sizeValue
    property int  widthValue
    property int  heightValue
    property string dateShootingValue

    allowedOrientations: Orientation.All

    XmlListModel {
        id: xmlCommentModel
        query: "/methodResponse/params/param/value/array/data/value/struct"

        XmlRole { name: "commentId"; query: "member[name='commentid']/value/string/string()"; isKey:true }
        XmlRole { name: "commentName"; query: "member[name='name']/value/string/string()" }
        XmlRole { name: "commentText"; query: "member[name='comment']/value/string/string()" }
        XmlRole { name: "commentDate"; query: "member[name='dateCreated']/value/double/string()" }
    }

    SilicaListView {
        id: listDetails
        anchors.fill: parent
        clip:true

        VerticalScrollDecorator { flickable: listDetails }

        header: Column {
            anchors { left: parent.left; right: parent.right }
            bottomPadding: Theme.paddingLarge

            PageHeader {
                title: qsTr("Details")
            }
            DetailItem {
                id: fileNameItem
                label: qsTr("File name")
                value: detailsPage.fileNameValue
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: ratingItem
                label: qsTr("Rating")
                value: detailsPage.ratingValue
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: typeItem
                label: qsTr("File type")
                value: detailsPage.typeValue
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: sizeItem
                label: qsTr("File size")
                value: qsTr("%1 bytes").arg(sizeValue.toLocaleString(undefined, 'f', 0))
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: widthItem
                label: qsTr("Resolution")
                value: qsTr("%1 x %2").arg(widthValue).arg(heightValue)
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: dateShootingItem
                label: qsTr("Date taken")
                value: Qt.formatDateTime(new Date(parseFloat(dateShootingValue)), qsTr("dd MMM yyyy hh:mm:ss"))
                visible: dateShootingValue.length > 0
                alignment: Qt.AlignLeft
            }
            Text {
                font.pixelSize: Theme.fontSizeExtraLarge
                text: " "
            }
            Text {
                anchors { right: parent.right;  rightMargin: Theme.horizontalPageMargin }
                color: Theme.highlightColor
                font {
                    pixelSize: Theme.fontSizeLarge
                    family: Theme.fontFamilyHeading
                }
                text: qsTr("Comments")
            }
            Text {
                anchors { left: parent.left; right: parent.right;  leftMargin:Theme.horizontalPageMargin }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                visible: listDetails.count == 0
                text: xmlCommentModel.status === XmlListModel.Ready ? qsTr("No new comment") : qsTr("Retrieving comments...")
            }
        }

        model: xmlCommentModel

        delegate: ListItem {
            contentHeight: itemColumn.height // Theme.itemSizeLarge
            anchors { left: parent.left; right: parent.right;  leftMargin:Theme.horizontalPageMargin;  rightMargin: Theme.horizontalPageMargin }
            Column {
                id: itemColumn
                anchors { left: parent.left; right: parent.right }
                Label {
                    id: firstLine
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    text: decodeURIComponent(commentText)
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
                Label {
                    id: secondLine
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                    text: decodeURIComponent(commentName)
                    width: parent.width
                }
            }

            menu: ContextMenu {
                enabled: detailsPage.sessionType === 0
                             MenuItem {
                                 text: "Remove"
                                 onClicked: {
                                     HttpRequests.joomeoDeleteComment(detailsPage.sessionId, commentId,
                                                                      function() {
                                                                          HttpRequests.joomeoGetCommentList(detailsPage.sessionId, detailsPage.albumId, detailsPage.fileId,
                                                                                                            function (req){
                                                                                                                xmlCommentModel.xml = req.responseText
                                                                                                            },
                                                                                                            function () {
                                                                                                                // error
                                                                                                            })

                                                                      },
                                                                      function () {})

                                 }
                             }
                         }
        }

        footer: TextField {
            id: newComment
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            anchors { left: parent.left; right: parent.right; topMargin:Theme.paddingLarge }
            label: qsTr("New comment"); placeholderText: label
            EnterKey.enabled: true
            EnterKey.onClicked: {
                HttpRequests.joomeoAddComment(detailsPage.sessionId, detailsPage.albumId, detailsPage.fileId, newComment.text,
                                              function() {
                                                  HttpRequests.joomeoGetCommentList(detailsPage.sessionId, detailsPage.albumId, detailsPage.fileId,
                                                                                    function (req){
                                                                                        xmlCommentModel.xml = req.responseText
                                                                                        newComment.text = ""
                                                                                    },
                                                                                    function () {
                                                                                        // error
                                                                                    })
                                              },
                                              function() {
                                                  // Error
                                              })

            }
        }
    }

    onStatusChanged: {
        if (xmlCommentModel.xml == "") {
            HttpRequests.joomeoGetCommentList(sessionId, albumId, fileId,
                                              function (req){
                                                  xmlCommentModel.xml = req.responseText
                                              },
                                              function () {
                                                  // error
                                              })

        }
    }
}


