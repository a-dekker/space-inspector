/*
 * This file is part of Space Inspector.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.FileData 1.0

Item {
    id: root

    property alias grid: gridItem.grid
    property FileData fileData
    property string path

    property bool _busy: !!fileData && fileData.isDir ? true : false
    property int _workerHandle: Engine.requestFileSizeInfo([path])

    property string _placeholder: fileData.isDir ?
        [qsTr("folders", "generic form for unknown number of items"),
         qsTr("files", "generic form for unknown number of items"),
         ""].join("\n") : ""
    property string _value: ""

    InfoGridItem {
        id: gridItem
        grid: grid
        label: qsTr("Size", "as in “file size” but very short")
        value: !!fileData && !fileData.isDir ?
                   fileData.size :
                   (busy ? _placeholder : _value)
        busy: _busy
    }

    Connections {
        target: Engine
        onFileSizeInfoReady: {
            // @disable-check M325
            if (_workerHandle == handle) {
                _workerHandle = -1
                target = null

                var value = ''

                var dirsCnt = parseInt(info[2], 10)
                if (dirsCnt > 0) {
                    value += '\n' + qsTr("%n folder(s)", "", dirsCnt)
                }

                var filesCnt = parseInt(info[3], 10)
                if (filesCnt > 0) {
                    value += '\n' + qsTr("%n file(s)", "", filesCnt)
                }

                value += '\n' + (info[1] === '' ? "-" : info[1])
                _value = value.trim()
                _busy = false
            }
        }
    }
}
