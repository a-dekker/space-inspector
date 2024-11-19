/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2014-2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Harbour.FileBrowser.Engine 1.0

Rectangle {

    property var collapsedNodePaths: []
    property int collapsedNodesSize: 0
    signal click
    color: 'transparent'
    visible: collapsedNodesSize > 0
    height: collapsedNodesSize > 0 ? 40 : 0

    Rectangle {
        anchors.fill: parent
        color: Theme.secondaryHighlightColor
        opacity: mArea.pressed ? 1 : 0.75
    }

    Label {
        id: label
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: mArea.pressed ? Theme.highlightColor : Theme.primaryColor
        text: qsTr("%n collapsed item(s) (%1)", "",
                   collapsedSubNodePaths.length)
              .arg(Engine.formatFileSize(collapsedNodesSize))
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: {
            click()
        }
    }
}
