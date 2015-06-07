import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: showGistPage

    property string raw_url: ""
    property string filename: ""
    property string description: ""
    property string language: ""
    property string gist_id: ""
    property bool newGist: false
    property bool addFileToGist: false
    property bool changed: false

    /* Prevent accidental page-navigation when editing */
    backNavigation: !area.focus
    canNavigateForward: !area.focus

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
        else if (addFileToGist)
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
                enabled: !newGist && !addFileToGist
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
                text: "Load from file"
                visible: newGist || addFileToGist
                enabled: visible

                onClicked:
                {
                    var ofp = pageStack.push(Qt.resolvedUrl("OpenFile.qml"))
                    ofp.fileselected.connect(function()
                    {
                        var s = ofp.openFilename.split("/")
                        filename = s[s.length-1]
                        if (/\.qml$/i.test(filename))
                        {
                            language = "QML"
                            gists.highLightTarget = area._editor
                        }
                        else
                        {
                            language = ""
                            gists.highLightTarget = null
                        }
                        area.text = gists.loadFile(ofp.openFilename)
                    })
                }
            }
            MenuItem
            {
                text: (newGist||addFileToGist) ? "Upload to github" : "Update on github"
                enabled: ((!newGist && !addFileToGist) || changed) && area.text.length > 0
                onClicked:
                {
                    var gd = pageStack.push(Qt.resolvedUrl("AskGistDetails.qml"),
                                            {
                                                newGist: newGist || addFileToGist,
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
                            if (addFileToGist)
                                jsonvarfiles[gd.filename] = { "content": area.text }
                            else
                                jsonvarfiles[filename] = { "filename": gd.filename, "content": area.text }
                            jsonvar["description"] = gd.description
                            jsonvar["files"] = jsonvarfiles
                            gists.updateGist(gist_id, JSON.stringify(jsonvar))
                        }
                        pageStack.pop(getBottomPageId())
                    })
                }
            }
            MenuItem
            {
                text: "Preview"
                enabled: language === "QML"
                visible: enabled
                onClicked:
                {
                    var dlg
                    var qmlCode = ""
                    var pattern = /QtQuick 2/;
                    if (!pattern.test(area.text))
                        qmlCode += "import QtQuick 2.0\n"
                    pattern = /Sailfish\.Silica/;
                    if (!pattern.test(area.text))
                        qmlCode += "import Sailfish.Silica 1.0\n"
                    qmlCode += area.text

                    var tempFilename = gists.saveTemp(qmlCode)

                    var patternP = /\bPage\b/
                    var patternD = /\bDialog\b/
                    if (patternP.test(area.text))
                    {
                        pageStack.push(Qt.resolvedUrl(tempFilename))
                    }
                    else if (patternD.test(area.text))
                    {
                        dlg = pageStack.push(Qt.resolvedUrl(tempFilename))
                        dlg.accepted.connect(function()
                        {
                            messagebox.showMessage("Accepted")
                        })
                        dlg.rejected.connect(function()
                        {
                            messagebox.showMessage("Rejected")
                        })
                    }
                    else
                    {
                        pageStack.push(Qt.resolvedUrl("GistPreview.qml"), { filename: tempFilename })
                    }
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

                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeTiny
                font.family: "Monospace"

                selectionMode: TextEdit.SelectCharacters
                readOnly: true
                background: null
                onTextChanged: if (!readOnly) changed = true
                onReadOnlyChanged: cursorPosition = 0

                Component.onCompleted:
                {
                    if (language == "QML")
                        gists.highLightTarget = area._editor
                }
            }
        }

    }
}
