/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2014-2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Harbour.FileBrowser.Engine 1.0

Item {
    id: root

    property var collapsedNodePaths: []

    readonly property bool _busy: _workerHandle >= 0
    property int _workerHandle: -1
    property int _existingCount: -1

    signal click

    onCollapsedNodePathsChanged: {
        if (collapsedNodePaths.length == 0) {
            _workerHandle = -1
            _existingCount = 0
            label.text = ''
        } else {
            _existingCount = -1
            _workerHandle = Engine.requestFileSizeInfo(collapsedNodePaths)
            label.text = ''
        }
    }

    visible: _existingCount > 0 ||
             (_existingCount < 0 && collapsedNodePaths.length > 0)
    height: visible ? Math.max(
        label.height, spinner.height + 2*Theme.paddingSmall) : 0

    Connections {
        target: Engine
        onFileSizeInfoReady: {
            // @disable-check M325
            if (_workerHandle == handle) {
                _workerHandle = -1
                _existingCount = parseInt(info[4], 10) || 0

                if (_existingCount > 0) {
                    var size = (!!info[1] ? " (%1)".arg(info[1]) : "")
                    label.text = qsTr("%n collapsed item(s)", "",
                                      _existingCount) + size
                } else {
                    label.text = ''
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.secondaryHighlightColor
        opacity: mArea.pressed ? 0.4 : 0.5
    }

    BusyIndicator {
        id: spinner
        anchors.centerIn: parent
        visible: root._busy
        size: BusyIndicatorSize.ExtraSmall
        running: visible
    }

    Label {
        id: label
        width: parent.width
        padding: Theme.paddingSmall
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        color: mArea.pressed ? Theme.highlightColor : Theme.primaryColor
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: {
            click()
        }
    }
}
