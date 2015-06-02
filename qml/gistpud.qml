/*
    gistpud, github gists application
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import harbour.gistpud.Gists 1.0
import "components"

ApplicationWindow
{
    id: gistpud

    onApplicationActiveChanged: openingBrowser = false

    initialPage: Qt.resolvedUrl("pages/FrontPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property bool processing: false
    property bool openingBrowser: false

    property var github

    Gists
    {
        id: gists

        Component.onCompleted:
        {
            processing = true
            gists.fetchGists()
        }

        onError:
        {
            processing = false
            messagebox.showError(gists.getError())
        }

        onGistsChanged:
        {
            gistsList.clear()

            var gistsJson = JSON.parse(gists.getGists())

            for (var i in gistsJson)
            {
                var description = gistsJson[i].description
                var html_url = gistsJson[i].html_url
                var created_at = gistsJson[i].created_at
                var updated_at = gistsJson[i].updated_at
                var files = gistsJson[i].files
                for (var f in files)
                {
                    gistsList.append( { description: description,
                                        html_url: html_url,
                                        created_at: created_at,
                                        updated_at: updated_at,
                                        filename: files[f].filename,
                                        language: files[f].language,
                                        size: files[f].size,
                                        raw_url: files[f].raw_url } )
                }
            }
            processing = false
        }

        onZenChanged:
        {
            messagebox.showMessage(gists.zen)
            processing = false
        }
    }

    Messagebox
    {
        id: messagebox
    }

    BusyIndicator
    {
        id: isBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: processing || openingBrowser
    }

    ListModel
    {
        id: gistsList
    }
}


