

/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    Copyright (C) 2014 - 2018 Jens Klingen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.2
import Sailfish.Silica 1.0

import "../components"

Page {
    id: page

    SilicaFlickable {
        id: sf
        anchors.fill: parent
        contentHeight: childRect.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Info")
                onClicked: pageStack.push(Qt.resolvedUrl(
                                              "../pages/InfoPage.qml"))
            }
        }
        Rectangle {
            id: childRect
            width: parent.width
            height: childrenRect.height
            color: 'transparent'

            PageHeader {
                id: title
                title: qsTr('Go to...')
            }

            Column {
                anchors.top: title.bottom
                width: parent.width

                PlaceButton {
                    path: '/'
                    text: qsTr("Root directory")
                    img: 'image://theme/icon-m-device'
                }
                PlaceButton {
                    path: engine.homeFolder()
                    text: qsTr("User directory")
                    img: 'image://theme/icon-m-home'
                }
                PlaceButton {
                    path: engine.sdcardPath()
                    text: qsTr("SD card")
                    img: 'image://theme/icon-m-sd-card'
                }
                PlaceButton {
                    path: engine.androidSdcardPath()
                    text: qsTr("Android storage")
                    img: 'image://theme/icon-m-file-apk'
                }
            }
        }
    }
}
