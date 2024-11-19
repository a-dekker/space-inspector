/*
 * This file is part of Space Inspector.
 * SPDX-FileCopyrightText: 2019-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Harbour.FileBrowser.FileData 1.0
import "../components/file-browser"

Page {
    id: root
    allowedOrientations: Orientation.All

    property alias path: fileData.file

    FileData {
        id: fileData

        property string typeDescription:
            "%1\n(%2)".arg(mimeTypeComment).arg(mimeType)
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu {
            enabled: fileData.isDir
            visible: enabled

            MenuItem {
                text: qsTr("Open file manager")
                onClicked: Qt.openUrlExternally(fileData.absoluteFilePath)
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 0

            PageHeader {
                title: fileData.name || qsTr("Root")
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                // Display metadata with priority < 5
                Repeater {
                    model: fileData.metaData

                    // first char is priority (0-9), labels and values are delimited with fileData.STRING_SEP
                    DetailItem {
                        visible: modelData.charAt(0) < '5'
                        label: modelData.substring(1, modelData.indexOf(fileData.STRING_SEP))
                        value: String(modelData.substring(
                                      modelData.indexOf(fileData.STRING_SEP)+1)).trim()
                    }
                }

                DetailItem {
                    label: qsTr("Location")
                    value: fileData.absoluteFilePath
                }
                DetailItem {
                    label: qsTr("Type")
                    value: fileData.isSymLink
                        ? (fileData.isSymLinkBroken
                           ? qsTr("Unknown (link target not found)")
                           : qsTr("Link to %1").arg(fileData.typeDescription))
                        : fileData.typeDescription
                }
                SizeDetailItem {
                    files: [root.path]
                }
                DetailItem {
                    label: qsTr("Permissions")
                    value: fileData.permissions
                }
                DetailItem {
                    label: qsTr("Owner")
                    value: fileData.owner
                    visible: !!value
                }
                DetailItem {
                    label: qsTr("Group")
                    value: fileData.group
                    visible: !!value
                }
                DetailItem {
                    label: qsTr("Created")
                    value: fileData.createdLong
                    visible: !!value
                }
                DetailItem {
                    label: qsTr("Last modified")
                    value: fileData.modifiedLong
                    visible: !!value
                }

                // Display metadata with priority >= 5
                Repeater {
                    model: fileData.metaData

                    // first char is priority (0-9), labels and values are delimited with fileData.STRING_SEP
                    DetailItem {
                        visible: modelData.charAt(0) >= '5'
                        label: modelData.substring(1, modelData.indexOf(fileData.STRING_SEP))
                        value: String(modelData.substring(
                                      modelData.indexOf(fileData.STRING_SEP)+1)).trim()
                    }
                }
            }
        }
    }
}
