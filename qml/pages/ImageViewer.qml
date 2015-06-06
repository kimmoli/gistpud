import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: imageViewerPage

    property string raw_url
    property string filename

    PageHeader
    {
        id: ph
        title: filename
    }
    Image
    {
        id: img
        source: raw_url
        anchors.centerIn: parent
        width: Math.min(sourceSize.width, parent.width - Theme.paddingMedium)
        height: Math.min(sourceSize.height, parent.height - Theme.paddingMedium)
        fillMode: Image.PreserveAspectFit
    }
    Label
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: ph.bottom
        anchors.topMargin: Theme.paddingMedium
        text: img.sourceSize.width + "x" + img.sourceSize.height
    }
}
