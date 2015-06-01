import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{

    id: editPasteDialog

    property string pasteTitle: ""
    property string code: ""
    property string format: userFormat
    property string expire: userExpire
    property string privacy: userPrivacy

    Component.onCompleted:
    {
        switch (expire)
        {
            case "N": expireCombo.currentIndex = 0; break;
            case "10M": expireCombo.currentIndex = 1; break;
            case "1H": expireCombo.currentIndex = 2; break;
            case "1D": expireCombo.currentIndex = 3; break;
            case "1W": expireCombo.currentIndex = 4; break;
            case "2W": expireCombo.currentIndex = 5; break;
            case "1M": expireCombo.currentIndex = 6; break;
            default: expireCombo.currentIndex = 6; break;
        }

        privacyCombo.currentIndex = Number(privacy)
    }

    canAccept: area.text.length > 0
    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            code = area.text
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: area.height
        VerticalScrollDecorator {}

        PullDownMenu
        {
            id: pdm
            ComboBox
            {
                id: expireCombo
                width: parent.width
                label: "Expires "

                menu: ContextMenu
                {
                    MenuItem { text: "Never";      onClicked: expire = "N"; }
                    MenuItem { text: "10 Minutes"; onClicked: expire = "10M"; }
                    MenuItem { text: "1 Hour";     onClicked: expire = "1H"; }
                    MenuItem { text: "1 Day";      onClicked: expire = "1D"; }
                    MenuItem { text: "1 Week";     onClicked: expire = "1W"; }
                    MenuItem { text: "2 Weeks";    onClicked: expire = "2W"; }
                    MenuItem { text: "1 Month";    onClicked: expire = "1M"; }
                }
            }
            ComboBox
            {
                id: privacyCombo
                width: parent.width
                label: "Privacy "

                menu: ContextMenu
                {
                    MenuItem { text: "Public";   onClicked: privacy = "0"; }
                    MenuItem { text: "Unlisted"; onClicked: privacy = "1"; }
                }
            }
            TextField
            {
                id: ptitle
                width: parent.width
                label: "Paste title"
                placeholderText: "Paste title"
                onTextChanged: pasteTitle = text
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked:
                {
                    pasteTitle = text
                    pdm.hide()
                }
            }
        }

        DialogHeader
        {
            id: dh
            acceptText: pasteTitle.length > 0 ? pasteTitle : "New paste"
        }

        TextArea
        {
            id: area
            width: editPasteDialog.width
            height: editPasteDialog.height - dh.height

            anchors.top: dh.bottom

            selectionMode: TextEdit.SelectCharacters
            focus: true
            background: null
        }
    }
}
