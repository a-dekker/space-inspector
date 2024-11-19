

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
import Harbour.FileBrowser.Engine 1.0

import "../components"
import "../js/IoTranslator.js" as IoTranslator
import "../js/Util.js" as Util

Page {
    id: page

    property alias nodeModel: manager.nodeModel

    SilicaFlickable {
        id: sf
        anchors.fill: parent
        contentHeight: parent.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Go to...")
                onClicked: {
                    pageStack.push("../pages/PlacesPage.qml", {
                                       "nodeModel": nodeModel
                                   })
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    refreshPage()
                }
            }
            MenuItem {
                text: qsTr("Box view")
                onClicked: {
                    pageStack.replace("../pages/TreeMapPage.qml", {
                                          "nodeModel": nodeModel
                                      })
                }
            }
        }

        PageHeader {
            id: title
            title: nodeModel.name
            description: nodeModel.formattedSize
        }

        ActivityIndicator {
            id: busyIndicator
            anchors.fill: parent
        }

        SilicaListView {
            id: listView
            anchors.top: title.bottom
            contentHeight: parent.height - title.height
            width: parent.width
            height: parent.height - title.height
            clip: true

            model: subDirsModel
            delegate: subDirsDelegate

            VerticalScrollDecorator {
            }

            ListModel {
                id: subDirsModel
            }

            Component {
                id: subDirsDelegate
                ListItem {

                    id: itemDelegate
                    anchors.left: parent.left
                    width: parent.width
                    height: Theme.itemSizeSmall + contextMenu.height
                    menu: contextMenu

                    Rectangle {
                        id: itemBg
                        color: itemDelegate.pressed ? Theme.secondaryHighlightColor : "transparent"
                    }

                    Label {
                        id: dirName
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: Util.getNodeNameFromPath(model.dir)
                        width: parent.width - (Theme.paddingMedium + dirSize.width)
                        truncationMode: TruncationMode.Fade
                        color: itemDelegate.pressed
                               || !model.isDir ? Theme.highlightColor : Theme.primaryColor
                    }

                    Label {
                        id: dirSize
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: parseInt(model.size).toLocaleString(Qt.locale(),
                                                                  "f",
                                                                  0) + " B"
                        color: itemDelegate.pressed ? Theme.highlightColor : Theme.secondaryColor
                    }

                    onClicked: {
                        if (model.isDir) {
                            pageStack.push("ListPage.qml", {
                                               "nodeModel": model
                                           })
                        }
                    }

                    NodeContextMenu {
                        id: contextMenu
                        nodeModel: model
                        remorseItem: remorseItem
                        listViewMode: true
                    }

                    RemorseItem {
                        id: remorseItem
                    }
                }
            }
        }

    }

    CalculationManager {
        id: manager
        onResultReady: displayDirectoryList(info)
    }

    Connections {
        target: Engine
        onFileDeleted: {
            refreshPage()
        }
    }

    function displayDirectoryList(subNodesWithSize) {
        for (var i in subNodesWithSize) {
            var node = subNodesWithSize[i]
            subDirsModel.append({
                name: node.name,
                dir: node.dir,
                isDir: node.isDir,
                size: node.size,
                formattedSize: node.formattedSize
            })
        }

        busyIndicator.running = false
        busyIndicator.visible = false
    }

    function createNodeModel() {
        return {
            "name": "/",
            "dir": '/',
            "isDir": true,
            "size": 0,
            "formattedSize": "",
        }
    }

    function refreshPage() {
        if (pageStack.currentPage == page && !pageStack.busy) {
            pageStack.replace("../pages/ListPage.qml", {
                                  "nodeModel": pageStack.currentPage.nodeModel
                              })
        }
    }
}
