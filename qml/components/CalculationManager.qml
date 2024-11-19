/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.6
import Harbour.FileBrowser.Engine 1.0

Item {
    id: root

    property var nodeModel: ({
        "name": "/",
        "dir": '/',
        "isDir": true,
        "size": 0,
        "formattedSize": "",
    })

    property int _sizeInfoHandle: -1

    signal resultReady(var info)

    Connections {
        target: Engine
        onFolderSizeInfoReady: {
            // @disable-check M325
            if (handle != _sizeInfoHandle) {
                return
            }


            nodeModel.name = status.name
            nodeModel.path = status.path
            nodeModel.formattedSize = status.size
            nodeModel = nodeModel

            console.log("size calculated:", status)
            resultReady(info)
        }
    }

    function refresh() {
        _sizeInfoHandle = Engine.requestFolderSizeInfo(nodeModel.dir)
    }

    Component.onCompleted: {
        refresh()
    }
}
