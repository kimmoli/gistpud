/*
    kladi, Pastebin application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "About..."
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem
            {
                text:
                {
                    if (gists.loggedIn)
                        return "Logged in as " + gists.username
                    return "Login"
                }
                onClicked: pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
        }

        Column
        {
            id: col
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge

            Button
            {
                id: b1
                anchors.horizontalCenter: parent.horizontalCenter
                text: "zen"
                onClicked:
                {
                    processing = true
                    gists.fetchZen()
                }
            }
            Button
            {
                id: b2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "gists"
                onClicked:
                {
                    processing = true
                    gists.fetchGists()
                }
            }
        }


        SilicaListView
        {
            id: listView
            anchors.top: col.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height - col.height - Theme.paddingLarge

            model: gistsList

            VerticalScrollDecorator {}

            delegate: ListItem
            {
                id: listItem
                menu: ContextMenu
                {
                    MenuItem
                    {
                        text: "Open in browser"

                        onClicked:
                        {
                            openingBrowser = true
                            Qt.openUrlExternally(html_url)
                        }
                    }
                }

                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("ShowGist.qml"), { raw_url: raw_url, filename: filename } )
                }

                Column
                {
                    id: itemCol
                    x: Theme.paddingSmall

                    Label
                    {
                        text: description + " - " + filename
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    Label
                    {
                        text: Qt.formatDateTime(new Date(created_at))
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
            }
        }
    }
}


