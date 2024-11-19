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
import Harbour.FileBrowser.Engine 1.0

import "../components"
import "../js/treemap-squarify.js" as Tm

Page {
    id: page

    property alias nodeModel: manager.nodeModel
    property var collapsedSubNodePaths: []
    property int collapsedSubNodesSize: 0
    property var subNodesWithSize: []

    onOrientationTransitionRunningChanged: {
        if (!orientationTransitionRunning) {
            if (!busyIndicator.running) {
                renderTreeMap()
            }
        }
    }

    onStatusChanged: {
        // Needed if screen is rotated in nested page
        if (status === PageStatus.Active) {
            if (!busyIndicator.running) {
                renderTreeMap()
            }
        }
    }

    SilicaFlickable {
        id: sf
        anchors.fill: parent
        contentHeight: parent.height

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
                text: qsTr("List view")
                onClicked: {
                    pageStack.animatorReplace("../pages/ListPage.qml", {
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

        TreeMapNodeCollapsed {
            id: collapsedNodes
            anchors.top: title.bottom
            x: 1
            width: parent.width - 2
            collapsedNodePaths: collapsedSubNodePaths
            collapsedNodesSize: collapsedSubNodesSize

            onClick: {
                collapsedSubNodePaths = []
                renderTreeMap()
            }
        }

        Rectangle {
            id: treeMap
            anchors.top: collapsedNodes.bottom
            width: parent.width - 1
            height: parent.height - title.height - collapsedNodes.height
            color: 'transparent'

            function clear() {
                for (var i = children.length - 1; i >= 0; i--) {
                    children[i].destroy()
                }
            }
        }

        ViewPlaceholder {
            enabled: manager.fileData.filesCount == 0 &&
                     manager.fileData.dirsCount == 0
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

    function displayDirectoryList(nodesWithSize) {
        subNodesWithSize = nodesWithSize
        renderTreeMap()
    }

    function collapseSubNode(nodePath) {
        collapsedSubNodePaths.push(nodePath)
        renderTreeMap()
    }

    function renderTreeMap() {
        treeMap.clear()

        var visibleNodesWithSize = removeCollapsed(subNodesWithSize)

        // Fall back to list view if there are many entries,
        // instead of freezing and possibly crashing the app.
        if (visibleNodesWithSize.length > 1000) {
            pageStack.animatorReplace("../pages/ListPage.qml", {
                "nodeModel": nodeModel
            })
            return
        } else if (visibleNodesWithSize.length === 0) {
            busyIndicator.running = false
            busyIndicator.visible = false
            return
        }

        var sizeArr = []
        for (var i in visibleNodesWithSize) {
            sizeArr.push(visibleNodesWithSize[i].size)
        }
        var coords = Tm.Treemap.generate(sizeArr, treeMap.width, treeMap.height)
        var nodeComponent = Qt.createComponent('../components/TreeMapNode.qml')
        for (var i in coords) {
            var coord = coords[i]
            if (nodeComponent.status === Component.Ready) {
                var nodeConfig = {
                    "nodeModel": visibleNodesWithSize[i],
                    "nodeLeft": coord[0] + 1,
                    "nodeTop": coord[1] + 1,
                    "nodeWidth": coord[2] - coord[0] - 1,
                    "nodeHeight": coord[3] - coord[1] - 1
                }
                nodeComponent.createObject(treeMap, nodeConfig)
            }
        }
        busyIndicator.running = false
        busyIndicator.visible = false
    }

    function removeCollapsed(nodesWithSize) {
        collapsedSubNodesSize = 0
        var ret = []
        for (var i = 0; i < nodesWithSize.length; i++) {
            var node = nodesWithSize[i]
            var dir = node.dir
            if (collapsedSubNodePaths.indexOf(dir) < 0) {
                ret.push(node)
            } else {
                collapsedSubNodesSize += node.size
            }
        }
        return ret
    }

    function refreshPage() {
        manager.refresh()
        renderTreeMap()
    }

    Component.onCompleted: {
        if (manager.fileData.filesCount > 1000 ||
                manager.fileData.dirsCount > 1000) {
            pageStack.animatorReplace("../pages/ListPage.qml", {
                "nodeModel": nodeModel
            })
        }
    }
}
