import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage

    allowedOrientations: window.allowedOrientations

    SilicaFlickable {
        id: aboutPageFlickable

        anchors.fill: parent
        contentHeight: aboutColumn.height

        Column {

            id: aboutColumn
            anchors {
                left: parent.left;
                right: parent.right;
                leftMargin: Theme.horizontalPageMargin;
                rightMargin: Theme.horizontalPageMargin
            }
            height: childrenRect.height
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About Joomeo")
            }

            Label {
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left;
                    right: parent.right;
                }

                text: qsTr("This application is a browser for pictures stored in Joomeo cloud service.\nThis is not an official application.")
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version %1").arg(Qt.application.version)
            }
            Label  {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Author %1").arg("Ron282")
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("<a href=\"http://www.joomeo.com/en/privacypolicy.php\">Privacy Policy of Joomeo</a>")
                onLinkActivated: Qt.openUrlExternally(link)
            }
         }
    }

    VerticalScrollDecorator { flickable: aboutPageFlickable }
}
