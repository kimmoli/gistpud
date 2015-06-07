import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.gistpud.FileModel 1.0

Page
{
    id: openFilePage

    property string openFilename
    signal fileselected

    Component.onCompleted:
    {
        fileModel.path = lastLocation
    }

    FileModel
    {
        id: fileModel
        onPathChanged:
        {
            if (path != lastLocation)
                lastLocation = path
        }
    }

    SilicaListView
    {
        id: view
        model: fileModel
        anchors.fill: parent
        header: PageHeader
        {
            title: fileModel.path.length > 1 ? fileModel.path + "/" : fileModel.path
        }

        delegate: ListItem
        {
            id: delegate
            width: parent.width
            enabled: !(isDir && fileModel.path == "/" && name == "..")
            height: enabled ? Theme.itemSizeSmall : 0

            Column
            {
                id: fileCol
                x: Theme.paddingMedium

                Label
                {
                    text: (name + ((isDir && name != "..") ? "/" : ""))
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label
                {
                    visible: name != ".."
                    text: time + " <i>" + (isDir ? "dir" : size) + "</i>"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    textFormat: Text.RichText
                    color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                }
            }

            onClicked:
            {
                if (isDir)
                {
                    fileModel.cd(name)
                }
                else
                {
                    openFilename = path
                    fileselected()
                    pageStack.navigateBack()
                }
            }
        }
        VerticalScrollDecorator { flickable: view }
    }
}
