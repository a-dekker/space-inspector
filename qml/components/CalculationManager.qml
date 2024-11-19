/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.6
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.FileData 1.0

Item {
    id: root

    readonly property alias fileData: fileData
    property var nodeModel: ({
        "name": "/",
        "dir": '/',
        "isDir": true,
        "size": 0,
        "formattedSize": "",
    })

    property int _sizeInfoHandle: -1

    signal resultReady(var info)

    FileData {
        id: fileData
        file: nodeModel.dir
    }

    Connections {
        target: Engine
        onFolderSizeInfoReady: {
            // @disable-check M325
            if (handle != _sizeInfoHandle) {
                console.log("ignoring unknown handle", handle)
                return
            }


            nodeModel.name = status.name
            nodeModel.path = status.path
            nodeModel.formattedSize = status.formattedSize
            nodeModel = nodeModel

            console.log("size calculated:", status)
            console.timeEnd('INFO REQUESTED')

            console.time('INFO NOTIFIED')
            console.timeEnd('name')
            resultReady(info)
            console.timeEnd('INFO NOTIFIED')
        }
    }

    function refresh() {
        console.time('INFO REQUESTED')
        _sizeInfoHandle = Engine.requestFolderSizeInfo(nodeModel.dir)
    }

    Component.onCompleted: {
        console.time('TOTAL')
        console.time('INITIAL REFRESH')
        refresh()
        console.timeEnd('INITIAL REFRESH')
    }
}
