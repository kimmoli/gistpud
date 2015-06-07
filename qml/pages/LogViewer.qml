import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: logViewerPage

    property string filename

    Component.onCompleted:
        messageHandler.enable = true

    Component.onDestruction:
        messageHandler.enable = false

    SilicaListView
    {
        id: view
        model: messageHandler
        anchors.fill: parent

        header: PageHeader
        {
            title: "Log"
        }

        delegate: Label
        {
            width: parent.width
            height: implicitHeight + Theme.paddingSmall

            text:
            {
                var s = new RegExp("file://" + filename)
                return message.replace(s, "(preview)")
            }
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
        }

    VerticalScrollDecorator { flickable: view }
    }
}
