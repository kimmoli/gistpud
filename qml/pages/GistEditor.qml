import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: showGistPage

    property string raw_url: ""
    property string filename: ""
    property string description: ""
    property string gist_id: ""
    property bool newGist: false
    property bool changed: false

    function loadRaw()
    {
        processing = true
        area.text = "Loading..."

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function()
        {
            if (doc.readyState == XMLHttpRequest.DONE)
            {
                area.text = doc.responseText;
                processing = false
            }
        }
        doc.open("get", raw_url);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }

    Component.onCompleted:
    {
        if (newGist)
        {
            area.readOnly = false
            area.focus = true
            filename = "New file"
        }
        else
        {
            loadRaw()
        }
    }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent
        contentHeight: col.height

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: area.readOnly ? "Edit" : "Revert changes"
                enabled: !newGist
                onClicked:
                {
                    if (area.readOnly)
                    {
                        area.readOnly = false
                        area.focus = true
                    }
                    else
                    {
                        area.readOnly = true
                        area.focus = false
                        if (changed) /* Reload only if changed */
                            loadRaw()
                        changed = false
                    }
                }
            }
            MenuItem
            {
                text: "Save to file"
                enabled: area.text.length > 0
                onClicked:
                {
                    var afnd = pageStack.push(Qt.resolvedUrl("AskFilename.qml"), { filename: filename })
                    afnd.accepted.connect(function()
                    {
                        if (gists.save(afnd.filename, area.text))
                            messagebox.showMessage("Saved " + afnd.filename)
                        else
                            messagebox.showError("Failed to save")
                    })
                }
            }
            MenuItem
            {
                text: "Copy to clipboard"
                enabled: area.text.length > 0
                onClicked: Clipboard.text = area.text
            }
            MenuItem
            {
                text: newGist ? "Upload to github" : "Update on github"
                enabled: (!newGist || changed) && area.text.length > 0
                onClicked:
                {
                    var gd = pageStack.push(Qt.resolvedUrl("AskGistDetails.qml"),
                                            {
                                                newGist: newGist,
                                                description: description,
                                                filename: filename
                                            })

                    gd.accepted.connect(function()
                    {
                        processing = true
                        var jsonvar = {}
                        var jsonvarfiles = {}
                        if (newGist)
                        {
                            jsonvarfiles[gd.filename] = { "content": area.text }
                            jsonvar["description"] = gd.description
                            jsonvar["public"] = true
                            jsonvar["files"] = jsonvarfiles
                            gists.postGist(JSON.stringify(jsonvar))
                        }
                        else
                        {
                            jsonvarfiles[filename] = { "filename": gd.filename, "content": area.text }
                            jsonvar["description"] = gd.description
                            jsonvar["files"] = jsonvarfiles
                            gists.updateGist(gist_id, JSON.stringify(jsonvar))
                        }
                        pageStack.pop(getBottomPageId())
                    })
                }
            }
        }

        Column
        {
            id: col
            width: showGistPage.width
            Label
            {
                id: dh
                text: filename + (changed ? "*" : "")
                width: parent.width - 2*Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
                height: Theme.itemSizeLarge
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeLarge
                font.family: Theme.fontFamilyHeading
                font.bold: changed
            }

            TextArea
            {
                id: area
                width: showGistPage.width
                height: Math.max(showGistPage.height - dh.height, implicitHeight)

                selectionMode: TextEdit.SelectCharacters
                readOnly: true
                background: null
                onTextChanged: if (!readOnly) changed = true
            }
        }
    }
}
