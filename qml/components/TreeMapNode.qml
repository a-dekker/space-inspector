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
import "../components"
import "../js/Util.js" as Util

Item {
    id: treeMapNode

    property var nodeModel
    property double nodeLeft
    property double nodeTop
    property double nodeWidth
    property double nodeHeight

    property bool _menuActive: !!_menuItem
    property Item _menuItem: null

    signal collapseRequested(var nodePath)

    function openMenu() {
        if (!_menuItem) {
            _initMenuItem()
        }
        _menuItem.open(treeMapNode)
    }

    function closeMenu() {
        if (!!_menuItem) {
            _menuItem.close()
        }
    }

    function _initMenuItem() {
        if (!!_menuItem) {
            return
        }

        var result = menu.createObject(treeMapNode)
        result.closed.connect(function() { _menuItem.destroy() })
        _menuItem = result
    }

    width: nodeWidth
    height: nodeHeight
    x: nodeLeft
    y: nodeTop
    z: 1

    Component {
        id: menu

        NodeContextMenu {
            id: _menuBody
            nodeModel: treeMapNode.nodeModel
            onCollapseClicked: {
                treeMapNode.collapseRequested(nodeModel.dir)
            }

            Rectangle {
                parent: _menuBody
                color: Theme.colorScheme === Theme.LightOnDark ?
                           'black' : 'white'
                opacity: 0.8
                anchors.fill: parent
                z: -1000
            }
        }
    }

    Rectangle {
        id: background
        x: 0
        width: nodeWidth
        height: nodeHeight
        color: !nodeModel || nodeModel.isDir ?
                   Theme.secondaryHighlightColor :
                   Util.colorForFile(nodeModel.name)
        opacity: mArea.pressed || _menuActive ? 0.2 : 0.3
    }

    Label {
        id: label
        x: 0
        y: 0
        width: nodeWidth
        height: nodeHeight
        padding: Theme.paddingSmall
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: (!nodeModel || !nodeModel.isDir) ||
               mArea.pressed || _menuActive ?
                   Theme.highlightColor :
                   Theme.primaryColor

        // \x9C separates options in multi-length strings
        text: !!nodeModel ?
                  [nodeModel.name + '\n' + nodeModel.formattedSize,
                   nodeModel.formattedSize].join("\x9C") :
                  ''
        elide: Text.ElideRight
        fontSizeMode: Text.Fit
        wrapMode: Text.Wrap
        minimumPixelSize: Theme.fontSizeTiny * 0.75
        visible: parent.width > 30 && parent.height > 30 &&
                 paintedWidth < width &&
                 paintedHeight < height
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: {
            if (nodeModel.isDir) {
                pageStack.animatorPush("../pages/TreeMapPage.qml", {
                    "nodeModel": nodeModel
                })
            } else {
                openMenu()
            }
        }
        onPressAndHold: {
            openMenu()
        }
    }

    states: State {
        // Some tricks are needed to allow having a full-width
        // context menu on a fixed-width rectangle.
        when: _menuActive

        PropertyChanges {
            target: treeMapNode
            width: _menuItem.width
            height: nodeHeight + _menuItem.height
            x: 0
            z: 1000  // ensure context menu is on top
        }
        PropertyChanges {
            target: background
            x: nodeLeft
        }
        PropertyChanges {
            target: label
            x: nodeLeft
        }
    }
}
