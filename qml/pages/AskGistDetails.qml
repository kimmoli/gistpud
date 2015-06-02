import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: askGistDetailsDialog

    canAccept: tiDescription.text.length > 0 && tiFilename.text.length > 0

    property string filename : ""
    property string description : ""
    property bool newGist: true

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            description = tiDescription.text
            filename = tiFilename.text
        }
    }

    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: dialogHeader.height + col.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        DialogHeader
        {
            id: dialogHeader
            acceptText: newGist ? "New Gist" : "Update Gist"
        }

        Column
        {
            id: col
            width: parent.width - Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: dialogHeader.bottom

            SectionHeader
            {
                text: qsTr("Description")
            }

            TextField
            {
                id: tiDescription
                text: description
                width: parent.width
                focus: true
                placeholderText: qsTr("Enter description")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    tiFilename.focus = true
                }
            }

            SectionHeader
            {
                text: qsTr("Filename")
            }

            TextField
            {
                id: tiFilename
                text: filename
                width: parent.width
                placeholderText: qsTr("Enter filename")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    tiDescription.focus = true
                }
            }
        }
    }
}
