

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
import harbour.space.inspector.shell 1.0
import "../js/IoTranslator.js" as IoTranslator

import "../components"

Page {
    id: page

    property string fsPath: ""
    property var fileSystemInfo

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            fsPath = engine.homeFolder()
            fileSysShellUser.execute()
            fsPath = "/"
            fileSysShellRoot.execute()
            fsPath = engine.androidSdcardPath()
            fileSysShellAndroid.execute()
            fsPath = engine.sdcardPath()
            fileSysShellSdCard.execute()
        }
    }

    Shell {
        id: fileSysShellUser
        command: IoTranslator.FileSysInfo.getCommand(fsPath)
        onExecuted: {
            fileSystemInfo = IoTranslator.FileSysInfo.parseResult(response)
            homeDf = fileSystemInfo ? qsTr('%1/%2 (%3)').arg(
                                          fileSystemInfo.Used).arg(
                                          fileSystemInfo.Size).arg(
                                          fileSystemInfo['Use%']) : ""
        }
    }
    Shell {
        id: fileSysShellRoot
        command: IoTranslator.FileSysInfo.getCommand(fsPath)
        onExecuted: {
            fileSystemInfo = IoTranslator.FileSysInfo.parseResult(response)
            rootDf = fileSystemInfo ? qsTr('%1/%2 (%3)').arg(
                                          fileSystemInfo.Used).arg(
                                          fileSystemInfo.Size).arg(
                                          fileSystemInfo['Use%']) : ""
        }
    }

    Shell {
        id: fileSysShellAndroid
        command: IoTranslator.FileSysInfo.getCommand(fsPath)
        onExecuted: {
            fileSystemInfo = IoTranslator.FileSysInfo.parseResult(response)
            androidDf = fileSystemInfo ? qsTr('%1/%2 (%3)').arg(
                                             fileSystemInfo.Used).arg(
                                             fileSystemInfo.Size).arg(
                                             fileSystemInfo['Use%']) : ""
        }
    }
    Shell {
        id: fileSysShellSdCard
        command: IoTranslator.FileSysInfo.getCommand(fsPath)
        onExecuted: {
            fileSystemInfo = IoTranslator.FileSysInfo.parseResult(response)
            sdcardDf = fileSystemInfo ? qsTr('%1/%2 (%3)').arg(
                                            fileSystemInfo.Used).arg(
                                            fileSystemInfo.Size).arg(
                                            fileSystemInfo['Use%']) : ""
        }
    }

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
                    df: rootDf
                }
                PlaceButton {
                    path: engine.homeFolder()
                    text: qsTr("User directory")
                    img: 'image://theme/icon-m-home'
                    df: homeDf
                }
                PlaceButton {
                    path: engine.sdcardPath()
                    text: qsTr("SD card")
                    img: 'image://theme/icon-m-sd-card'
                    df: sdcardDf
                }
                PlaceButton {
                    path: engine.androidSdcardPath()
                    text: qsTr("Android storage")
                    img: 'image://theme/icon-m-file-apk'
                    df: androidDf
                }
            }
        }
    }
}
