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
    allowedOrientations: Orientation.All

    property alias nodeModel: manager.nodeModel
    property var collapsedSubNodePaths: ([])
    property var collapsedSubNodePathsMap: ({})
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
        id: flick
        anchors.fill: parent
        contentHeight: page.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Go to...")
                onClicked: {
                    pageStack.animatorPush("../pages/PlacesPage.qml")
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
            title: nodeModel.name || qsTr("Root")
            description: manager.nodeModel.formattedSize
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
            collapsedNodePaths: []

            onClick: {
                collapsedNodePaths = []
                collapsedSubNodePaths = []
                collapsedSubNodePathsMap = {}
                renderTreeMap()
            }
        }

        Loader {
            id: mapLoader
            anchors.top: collapsedNodes.bottom
            width: parent.width - 1
            height: parent.height - title.height - collapsedNodes.height

            property var visibleNodes
            property var coordinates

            function unload() {
                sourceComponent = null
            }

            function reload() {
                sourceComponent = null
                sourceComponent = mapComponent
            }

            sourceComponent: null

            Component {
                id: mapComponent

                Item {
                    id: mapRoot
                    property var _coordinates: coordinates
                    property var _visibleNodes: visibleNodes
                    property bool _canCollapse: _visibleNodes.length > 1

                    Repeater {
                        model: mapRoot._coordinates

                        delegate: Component {
                            TreeMapNode {
                                nodeModel: _visibleNodes[index]
                                nodeLeft: modelData[0] + 1
                                nodeTop: modelData[1] + 1
                                nodeWidth: modelData[2] - modelData[0] - 1
                                nodeHeight: modelData[3] - modelData[1] - 1
                                canCollapse: _canCollapse

                                onCollapseRequested: {
                                    console.log("COLLAPSE", nodePath)
                                    collapseSubNode(nodePath)
                                }
                            }
                        }
                    }
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
        console.time('DISPLAY')
        subNodesWithSize = nodesWithSize
        renderTreeMap()
        console.timeEnd('DISPLAY')

        console.timeEnd('TOTAL')
    }

    function collapseSubNode(nodePath) {
        collapsedSubNodePaths[nodePath] = 1
        collapsedSubNodePaths.push(nodePath)
        collapsedNodes.collapsedNodePaths = collapsedSubNodePaths  // notify
        renderTreeMap()
    }

    function renderTreeMap() {
        flick.contentY = 0
        var visibleNodesWithSize = removeCollapsed(subNodesWithSize)

        // Fall back to list view if there are many entries,
        // instead of freezing and possibly crashing the app.
        if (visibleNodesWithSize.length > 1000) {
            pageStack.animatorReplace("../pages/ListPage.qml", {
                "nodeModel": nodeModel
            })
            return
        } else if (visibleNodesWithSize.length === 0) {
            mapLoader.unload()
            busyIndicator.running = false
            busyIndicator.visible = false
            return
        }

        console.time('SIZES')
        var sizeArr = []
        for (var i in visibleNodesWithSize) {
            sizeArr.push(visibleNodesWithSize[i].kilobytes)
        }
        console.timeEnd('SIZES')

        console.time('COORDS')
        var coords = Tm.Treemap.generate(sizeArr, mapLoader.width, mapLoader.height)
        console.timeEnd('COORDS')

        console.time('ITEMS')
        mapLoader.unload()
        mapLoader.visibleNodes = visibleNodesWithSize
        mapLoader.coordinates = coords
        mapLoader.reload()
        console.timeEnd('ITEMS')

        busyIndicator.running = false
        busyIndicator.visible = false
    }

    function removeCollapsed(nodesWithSize) {
        var ret = nodesWithSize.filter(function(e){
            return !collapsedSubNodePaths.hasOwnProperty(e.dir)
        })

        return ret
    }

    function refreshPage() {
        manager.refresh()
        collapsedNodes.collapsedNodePaths = collapsedSubNodePaths
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
