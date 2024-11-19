/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: Copyright (C) 2014 - 2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.FileData 1.0

ContextMenu {
    id: contextMenu

    property var nodeModel
    property bool listViewMode: false
    property bool canCollapse: true

    signal collapseClicked

    FileData {
        id: fileData
        file: nodeModel.dir
    }

    MenuLabel {
        text: "%1 (%2)".arg(nodeModel.name).arg(nodeModel.formattedSize)
    }

    MenuItem {
        text: qsTr("Collapse")
        visible: !listViewMode && canCollapse
        onClicked: {
            collapseClicked()
        }
    }

    MenuItem {
        visible: !fileData.isDir && fileData.isSafeToOpen
        text: qsTr("Open")
        onClicked: {
            console.log("trying to open:", fileData.absoluteFilePath)
            Qt.openUrlExternally(fileData.absoluteFilePath)
        }
    }

    MenuItem {
        text: qsTr("Delete")
        onClicked: {
            var dialog = pageStack.push("../pages/DeleteDialog.qml", {
                "nodeModel": nodeModel
            })
            dialog.accepted.connect(function(){
                console.log("deleting:", nodeModel.dir)
                Engine.deleteFiles(nodeModel.dir)
            })
        }
    }
}
