import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: pasteInfoPage

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: pasteInfoPage.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: currentPasteTitle
            }
            DetailItem
            {
                label: "Created"
                value: currentPasteDate
            }
            DetailItem
            {
                label: "Expires"
                value: currentPasteExpire
            }
            DetailItem
            {
                label: "Privacy"
                value:
                {
                    if (currentPastePrivacy == 0)
                        return "Public"
                    if (currentPastePrivacy == 1)
                        return "Unlisted"
                    if (currentPastePrivacy == 2)
                        return "Private"
                }
            }
            DetailItem
            {
                label: "Format"
                value: currentPasteFormat
            }
            DetailItem
            {
                label: "Size"
                value: currentPasteSize + " B"
            }
        }
    }
}
