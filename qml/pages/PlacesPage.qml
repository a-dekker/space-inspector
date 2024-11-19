/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Opal.Delegates 1.0
import Harbour.FileBrowser.Engine 1.0
import Harbour.FileBrowser.Bookmarks 1.0
import Harbour.SpaceInspector.Constants 1.0

import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    ConfigurationValue {
        id: viewConfig
        key: "/apps/harbour-captains-log/defaultView"
        defaultValue: ViewMode.Box

        property string viewPage: value === ViewMode.List ?
            Qt.resolvedUrl("ListPage.qml") : Qt.resolvedUrl("TreeMapPage.qml")
    }

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
                text: qsTr("About")
                onClicked: pageStack.animatorPush(
                    Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(
                    Qt.resolvedUrl("SettingsPage.qml"))
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

            padding.left: Theme.horizontalPageMargin
                          - Theme.paddingMedium
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

            onClicked: {
                console.time('PUSHED')
                pageStack.animatorPush(
                    viewConfig.viewPage, {
                    "nodeModel": {
                        "name": name,
                        "dir": path,
                        "isDir": true,
                        "size": 0,
                        "formattedSize": "",
                    }
                })
                console.timeEnd('PUSHED')
            }
        }
    }
}
