import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Component.onCompleted:
        {
            uname.text = gists.username
        }

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "Login"
            }
            TextField
            {
                id: uname
                width: parent.width
                focus: true
                label: "Username"
                inputMethodHints: Qt.ImhNoAutoUppercase
                placeholderText: qsTr("Enter username")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    upass.focus = true
                }
            }
            TextField
            {
                id: upass
                width: parent.width
                focus: true
                label: "Password"
                placeholderText: qsTr("Enter password or token")
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    uname.focus = true
                }
            }

            Row
            {
                anchors.horizontalCenter: parent.horizontalCenter
                Button
                {
                    text: "Login basic"
                    enabled: upass.text.length > 0 && uname.text.length > 0
                    onClicked:
                    {
                        gists.loginBasic(uname.text, upass.text)
                        gists.initUser()
                        gists.fetchGists()
                        pageStack.navigateBack()
                    }
                }

                Button
                {
                    text: "Login token"
                    enabled: upass.text.length > 0 && uname.text.length > 0
                    onClicked:
                    {
                        gists.loginToken(uname.text, upass.text)
                        gists.initUser()
                        gists.fetchGists()
                        pageStack.navigateBack()
                    }
                }
            }
        }
    }
}
