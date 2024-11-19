/*
    Space Inspector - a filesystem structure visualization for SailfishOS

    SPDX-FileCopyrightText: Copyright (C) 2014 - 2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani

    SPDX-License-Identifier: GPL-3.0-or-later

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
import Opal.Delegates 1.0
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.FileData 1.0
import "../components"

Page {
    id: page

    property alias nodeModel: manager.nodeModel

    FileData {
        id: fileData
        file: nodeModel.dir
    }

    ActivityIndicator {
        id: busyIndicator
        anchors.fill: parent
    }

    SilicaListView {
        id: listView
        anchors.fill: parent

        header: PageHeader {
            title: nodeModel.name
            description: nodeModel.formattedSize
        }

        model: ListModel { id: subDirsModel }
        VerticalScrollDecorator { flickable: listView }

        PullDownMenu {
            MenuItem {
                text: qsTr("Go to...")
                onClicked: {
                    pageStack.animatorPush("../pages/PlacesPage.qml", {
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
                    pageStack.animatorReplace("../pages/TreeMapPage.qml", {
                        "nodeModel": nodeModel
                    })
                }
            }
        }

        delegate: OneLineDelegate {
            text: model.name
            opacity: model.isDir ? 1.0 : 0.75

            menu: NodeContextMenu {
                nodeModel: model
                listViewMode: true
            }

            leftItem: DelegateIconItem {
                source: "image://theme/icon-m-file-" +
                        (model.isDir ? "folder" : "document")
            }

            rightItem: DelegateInfoItem {
                alignment: Qt.AlignRight
                text: model.formattedSize
                textLabel.font.pixelSize: Theme.fontSizeMedium
            }

            onClicked: {
                if (model.isDir) {
                    pageStack.animatorPush("ListPage.qml", {
                        "nodeModel": model
                    })
                } else {
                    openMenu()
                }
            }
        }

        ViewPlaceholder {
            enabled: fileData.filesCount == 0 && fileData.dirsCount == 0
            text: qsTr("Empty", "as in “this folder is empty”")
            hintText: qsTr("This folder is empty.")
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
            pageStack.animatorReplace("../pages/ListPage.qml", {
                "nodeModel": pageStack.currentPage.nodeModel
            })
        }
    }
}
