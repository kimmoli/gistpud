import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    id: gistPreviewer

    property string filename: ""
    property var preview
    property var previewComp
    property bool errorOccured

    Component.onCompleted: changePreview()

    Label
    {
        id: errorLabel
        visible: errorOccured
        width: parent.width - 2*Theme.paddingLarge
        anchors.centerIn: parent
        textFormat: Text.RichText
        wrapMode: Text.WrapAnywhere
    }

    function changePreview()
    {
        if (preview)
            preview.destroy()

        previewComp = Qt.createComponent(filename, Component.Asynchronous)
        if (previewComp.status != Component.Loading)
            finishCreation();
        else
            previewComp.statusChanged.connect(finishCreation);
    }

    function finishCreation()
    {
        if (previewComp.status == Component.Ready)
        {
            preview = previewComp.createObject(gistPreviewer);
            if (preview == null)
            {
                console.log("createObject returned null")
                messagebox.showError("Error creating preview")
            }
        }
        else if (previewComp.status == Component.Error)
        {
            errorLabel.text = "Error:<br>" + previewComp.errorString()
            errorOccured = true
            console.log(previewComp.errorString())
        }
    }

}
