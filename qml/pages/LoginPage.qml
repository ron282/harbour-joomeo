import QtQuick 2.0
import Sailfish.Silica 1.0

import "Constants.js" as Constants
import "HttpRequests.js" as HttpRequests

Page {

    id: idLoginPage
    property string sessionId : ""
    property int sessionType
    property bool connecting : false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: height
        clip:true

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        }


        PageHeader { title: "Joomeo" }

        Column {
            id: idColumn
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: Theme.paddingLarge

            TextField {
                id: inputSpace
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Space Name"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: loginName.focus = true
                text: settings.value("spaceName", "")
            }

            TextField {
                id: inputLogin
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Login"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
                text: settings.value("login", "")
            }
            TextField {
                id: inputPassword
                anchors { left: parent.left; right: parent.right }
                echoMode: TextInput.Password
                label: qsTr("Password"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: connect.focus = true
                text: settings.value("password", "")
            }
            TextSwitch {
                id: idSaveSettings
                text: qsTr("Save these data")
                checked: settings.value("saveSettings", true)
                automaticCheck: true
            }
            Button {
                id: connect
                text: qsTr("Connect")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if(idSaveSettings.checked) {
                        settings.setValue("spaceName", inputSpace.text)
                        settings.setValue("login", inputLogin.text)
                        settings.setValue("password", inputPassword.text)
                        settings.setValue("saveSettings", idSaveSettings.checked)
                    } else {
                        settings.setValue("spaceName", "")
                        settings.setValue("login", "")
                        settings.setValue("password", "")
                        settings.setValue("saveSettings", false)
                    }

                    connecting = true
                    HttpRequests.joomeoSessionInit(inputSpace.text, inputLogin.text, inputPassword.text,
                                                   function (req) {
                                                       var ret

                                                       connecting = false
                                                       ret = HttpRequests.parseResponse(req.responseXML.documentElement)
                                                       sessionId = ret['sessionid']
                                                       sessionType = ret['sessionType']

                                                       pageStack.push(Qt.resolvedUrl("FolderPage.qml"),
                                                                      { spacename: inputSpace.text,
                                                                        sessionId: sessionId,
                                                                        sessionType: sessionType,
                                                                        folderId: "" })

                                                   },
                                                   function (msg) {
                                                       connecting = false
                                                       pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"),
                                                                      {message : qsTr("Connection failed.\nCheck your spacename, login and password")})
                                                   });
                }
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("<a href=\"https://www.joomeo.com/en/register.php\">Sign Up</a>")
                onLinkActivated: Qt.openUrlExternally(link)
            }

        }
    }

    onStatusChanged: {
        if(status === PageStatus.Activating && sessionId !== "") {
            HttpRequests.joomeoSessionKill(sessionId,
                                           function resolve() { sessionId = "" },
                                           function reject() { sessionId = "" }
                                           );
        }
    }

    BusyIndicator {
        running: connecting
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}



