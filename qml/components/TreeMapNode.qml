

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
import "../js/Util.js" as Util

Rectangle {

    id: treeMapNode
    property var nodeModel
    property double nodeLeft
    property double nodeTop
    property double nodeWidth
    property double nodeHeight
    // we want a full width context menu for a fixed size rectangle, need some tricks for this
    width: contextMenu.active ? contextMenu.width : nodeWidth
    height: nodeHeight + contextMenu.height
    x: contextMenu.active ? 0 : nodeLeft
    y: nodeTop

    color: 'transparent'

    Rectangle {
        x: contextMenu.active ? nodeLeft : 0
        width: nodeWidth
        height: nodeHeight
        color: Theme.secondaryHighlightColor
        opacity: mArea.pressed ? 0.6 : 0.3
        Component.onCompleted: {
            if (!nodeModel.isDir) {
                color = Qt.hsla(Util.getNormalizedHash(Util.getFileExtension(
                                                           nodeModel.dir)), 1,
                                0.5, 0.75)
            }
        }
    }

    Label {
        id: label
        x: contextMenu.active ? nodeLeft : 0
        y: 0
        width: nodeWidth
        height: nodeHeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: mArea.pressed
               || (nodeModel
                   && nodeModel.isDir) ? Theme.primaryColor : Theme.highlightColor
        text: Util.getNodeNameFromPath(
                  nodeModel.dir) + '\n' + Util.getHumanReadableSize(
                  nodeModel.size)
        // try to optimize text display for smaller rectangles...
        onPaintedWidthChanged: {
            if (paintedWidth > parent.width)
                font.pixelSize = Math.floor(
                            font.pixelSize * parent.width / paintedWidth)
            if (paintedHeight > parent.height)
                text = Util.getNodeNameFromPath(nodeModel.dir)
        }
        // ... if too small, rather display no text
        visible: parent.width > 30 && parent.height > 30
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: {
            if (nodeModel.isDir) {
                pageStack.push("../pages/TreeMapPage.qml", {
                                   "nodeModel": nodeModel
                               })
            }
        }
        onPressAndHold: {
            treeMapNode.z = 1000 // ensure context menu is on top
            contextMenu.open(treeMapNode)
        }
    }

    // less transparent background for contextmenu, for better readability (displayed on top of other tree nodes)
    Rectangle {
        color: 'black'
        opacity: 0.8
        x: contextMenu.x
        y: contextMenu.y
        width: contextMenu.width
        height: contextMenu.height
    }

    NodeContextMenu {
        id: contextMenu
        nodeModel: treeMapNode.nodeModel
        onClosed: {
            treeMapNode.z = 1
        }
        onCollapseClicked: PropertyAnimation {
            target: treeMapNode
            property: "opacity"
            from: 0.4
            to: 0
            duration: 250
            easing.type: Easing.OutCurve
            onRunningChanged: {
                if (!running)
                    collapseSubNode(nodeModel.dir)
            }
        }
    }

    opacity: 0.6
    Component.onCompleted: PropertyAnimation {
        running: true
        target: treeMapNode
        property: "opacity"
        from: 0.6
        to: 1.0
        duration: 500
        easing.type: Easing.OutCurve
    }
}
