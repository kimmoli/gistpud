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
            MenuItem
            {
                text: "Refresh"
                onClicked:
                {
                    processing = true
                    gists.fetchGists()
                }
            }
            MenuItem
            {
                text: "New Gist"
                onClicked: pageStack.push(Qt.resolvedUrl("GistEditor.qml"), { newGist: true } )
            }
        }

        SilicaListView
        {
            id: listView
            anchors.fill: parent

            model: gistsList

            header: PageHeader { title: "Your Gists" }

            VerticalScrollDecorator {}

            delegate: ListItem
            {
                id: listItem
                function remove()
                {
                    remorseAction("Deleting", function()
                    {
                        processing = true
                        var jsonvar = {}
                        var jsonvarfiles = {}
                        jsonvarfiles[filename] = null
                        jsonvar["files"] = jsonvarfiles
                        gists.updateGist(gist_id, JSON.stringify(jsonvar))
                    })
                }
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
                    MenuItem
                    {
                        text: "Delete"
                        onClicked: remove()
                    }
                }

                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("GistEditor.qml"),
                                   {
                                       gist_id: gist_id,
                                       raw_url: raw_url,
                                       description: description,
                                       filename: filename
                                   } )
                    pageStack.pushAttached(Qt.resolvedUrl("GistInfo.qml"), { thisGist: listView.model.get(index) } )
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


