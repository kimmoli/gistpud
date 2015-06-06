import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: gistInfoPage

    property var thisGist

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: gistInfoPage.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                title: thisGist.filename
            }

            DetailItem
            {
                label: "Part of Gist"
                value: thisGist.description
            }

            DetailItem
            {
                label: "Created"
                value: Qt.formatDateTime(new Date(thisGist.created_at))
            }
            DetailItem
            {
                label: "Updated"
                value: Qt.formatDateTime(new Date(thisGist.updated_at))
            }
            DetailItem
            {
                label: "Language"
                value: thisGist.language
            }
            DetailItem
            {
                label: "Size"
                value: thisGist.size + " B"
            }
            DetailItem
            {
                label: "Type"
                value: thisGist.type
            }
        }
    }
}
