/*
    Generic about page (C) 2014 Kimmo Lindholm
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page
{
    property string imagelocation: "/usr/share/icons/hicolor/86x86/apps/harbour-gistpud.png"

    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "About GistPud"
            }
            Label
            {
                text: "Github Gists application"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle
            {
                visible: imagelocation.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                height: 120
                width: 120
                color: "transparent"

                Image
                {
                    visible: imagelocation.length > 0
                    source: imagelocation
                    anchors.centerIn: parent
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: gists.fetchZen()
                    }
                }
            }

            Label
            {
                text: "(C) 2015 kimmoli"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label
            {
                text: "Version: " + Qt.application.version
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Item
            {
                height: 100
                width: 1
            }
//            Label
//            {
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "To paste from commandline use:<br><b>harbour-kladi - {title} {expire}</b>"
//                textFormat: Text.RichText
//                horizontalAlignment: Text.AlignHCenter
//            }
        }
    }
}

