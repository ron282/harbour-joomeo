import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: detailsPage
    property alias fileNameValue : fileNameItem.value
    property alias ratingValue : ratingItem.value
    property alias typeValue : typeItem.value
    property alias sizeValue : sizeItem.value
    property alias widthValue : widthItem.value
    property alias heightValue : heightItem.value
    property string dateShootingValue

    allowedOrientations: Orientation.All

    // SilicaListView

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: parent.width
            bottomPadding: Theme.paddingLarge

            PageHeader {
                title: qsTr("Details")
            }
            DetailItem {
                id: fileNameItem
                label: qsTr("File name")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: ratingItem
                label: qsTr("Rating")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: typeItem
                label: qsTr("Type")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: sizeItem
                label: qsTr("Size")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: widthItem
                label: qsTr("Width")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: heightItem
                label: qsTr("Height")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: dateShootingItem
                label: qsTr("Date shooting")
                value: Qt.formatDateTime(new Date(parseFloat(dateShootingValue)), qsTr("dd MMM yyyy hh:mm:ss"))
                visible: dateShootingValue.length > 0
                alignment: Qt.AlignLeft
            }
        }
    }
    VerticalScrollDecorator { }
}

