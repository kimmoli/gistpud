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
        clip: true

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
                        if (filesInThisGist > 1)
                        {
                            var jsonvar = {}
                            var jsonvarfiles = {}
                            jsonvarfiles[filename] = null
                            jsonvar["files"] = jsonvarfiles
                            gists.updateGist(gist_id, JSON.stringify(jsonvar))
                        }
                        else
                        {
                            gists.deleteGist(gist_id)
                        }
                    })
                }
                menu: ContextMenu
                {
                    MenuItem
                    {
                        text: "Add file to this Gist"
                        onClicked:
                        {
                            pageStack.push(Qt.resolvedUrl("GistEditor.qml"),
                                           {
                                               gist_id: gist_id,
                                               raw_url: "",
                                               description: description,
                                               addFileToGist: true
                                           } )
                        }
                    }
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
                    if (/^image/.test(type))
                    {
                        pageStack.push(Qt.resolvedUrl("ImageViewer.qml"),
                                   {
                                       raw_url: raw_url,
                                       filename: filename
                                   } )
                    }
                    else
                    {
                        pageStack.push(Qt.resolvedUrl("GistEditor.qml"),
                                   {
                                       gist_id: gist_id,
                                       raw_url: raw_url,
                                       description: description,
                                       filename: filename,
                                       language: language
                                   } )
                    }

                    pageStack.pushAttached(Qt.resolvedUrl("GistInfo.qml"), { thisGist: listView.model.get(index) } )
                }
                Rectangle
                {
                    anchors.fill: parent
                    opacity: 0.2
                    color: (gistno % 2 == 1) ? Theme.highlightColor : "transparent"
                }
                Column
                {
                    id: itemCol
                    x: Theme.paddingMedium

                    Label
                    {
                        text: description + " - " + filename
                        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    Label
                    {
                        text: Qt.formatDateTime(new Date(updated_at)) + "    <i>" + language + "</i> "
                        font.pixelSize: Theme.fontSizeExtraSmall
                        textFormat: Text.RichText
                        color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
            }
        }
    }
}


