/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.Bookmarks 1.0

import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    SilicaListView {
        id: view
        anchors.fill: parent

        model: BookmarksModel

        header: PageHeader {
            id: head
            title: qsTr("Places")
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        VerticalScrollDecorator { flickable: view }

        PullDownMenu {
            MenuItem {
                text: qsTr("Info")
                onClicked: pageStack.animatorPush(
                    Qt.resolvedUrl("../pages/InfoPage.qml"))
            }
        }

        delegate: TwoLineDelegate {
            id: delegate
            text: name

            textLabel {
                font.pixelSize: Theme.fontSizeMedium
                palette {
                    primaryColor: Theme.primaryColor
                    highlightColor: Theme.highlightColor
                }
            }

            StorageSizeBar {
                id: sizeBar
                parent: delegate.centeredContainer
                width: parent.width
                path: model.path
            }

            leftItem: DelegateIconItem {
                source: "image://theme/" + thumbnail
            }

            menu: Component {
                ContextMenu {
                    StorageSizeMenuLabel {
                        diskSpaceInfo: sizeBar.diskSpaceInfo
                    }

                    MenuLabel {
                        text: path
                    }
                }
            }

            onClicked: pageStack.animatorReplaceAbove(null,
                Qt.resolvedUrl("../pages/TreeMapPage.qml"), {
                "nodeModel": {
                    "name": name,
                    "dir": path,
                    "isDir": true,
                    "size": 0,
                    "formattedSize": "",
                }
            })
        }
    }
}
