import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: showPastePage

    property string raw_url: ""
    property string filename: ""

    Component.onCompleted:
    {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function()
        {
            if (doc.readyState == XMLHttpRequest.DONE)
            {
                area.text = doc.responseText;
            }
        }
        doc.open("get", raw_url);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent

        contentHeight: area.height
        VerticalScrollDecorator { flickable: flick }

        PullDownMenu
        {
            MenuItem
            {
                text: "Save to file"
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
                onClicked: Clipboard.text = area.text
            }
        }

        PageHeader
        {
            id: dh
            title: filename
        }

        TextArea
        {
            id: area
            width: showPastePage.width
            height: showPastePage.height - dh.height

            anchors.top: dh.bottom

            selectionMode: TextEdit.SelectCharacters
            readOnly: true
            background: null

            text: "wait for it..."
        }
    }
}
