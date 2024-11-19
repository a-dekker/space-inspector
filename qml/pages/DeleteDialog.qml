/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2014-2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Harbour.FileBrowser.FileData 1.0
import Harbour.FileBrowser.Engine 1.0
import QtQuick.Layouts 1.1
import "../components"

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property var nodeModel

    onAccepted: {
        console.log("deleting:", nodeModel.dir)
        Engine.deleteFiles([nodeModel.dir])
    }

    FileData {
        id: fileData
        file: nodeModel.dir

        onExistsChanged: {
            if (!exists) {
                reject()
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: 2*Theme.paddingLarge

            DialogHeader {
                id: dialogHeader
                title: qsTr("Confirm deletion")
                acceptText: fileData.isDir ? qsTr("Delete folder") : qsTr("Delete file")
            }

            Label {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                text: fileData.isDir ?
                          qsTr("Are you sure that you want " +
                               "to delete this folder " +
                               "and all its contents?") :
                          qsTr("Are you sure that you want " +
                               "to delete this element?")
            }

            GridLayout {
                id: grid
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                columns: 2
                columnSpacing: Theme.paddingMedium
                rowSpacing: Theme.paddingMedium

                // note: GridLayout items are added upside down,
                // from bottom to top.

                SizeDetailItem {
                    grid: grid
                    fileData: fileData
                    path: fileData.absoluteFilePath
                }
                InfoGridItem {
                    grid: grid
                    label: qsTr("Type", "as in “file type” but very short")
                    value: fileData.isDir ? qsTr("Folder") : qsTr("File")
                }
                InfoGridItem {
                    grid: grid
                    label: qsTr("Path", "as in “file path but very short")
                    value: fileData.absolutePath
                }
                InfoGridItem {
                    grid: grid
                    label: qsTr("Name", "as in “file name” but very short")
                    value: fileData.name
                }
            }

            Rectangle {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin

                height: warningLabel.height + 2*x
                color: Theme.highlightDimmerColor
                radius: 30

                Label {
                    id: warningLabel
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 2*x
                    x: Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                    text: qsTr("Warning: deleting files might break things, " +
                               "or even leave your phone in an unusable state.")
                }
            }
        }
    }
}
