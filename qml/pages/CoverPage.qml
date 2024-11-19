/*
    Space Inspector - a filesystem structure visualization for SailfishOS

    SPDX-FileCopyrightText: Copyright (C) 2014 - 2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani

    SPDX-License-Identifier: GPL-3.0-or-later

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import Opal.Delegates 1.0
import Harbour.FileBrowser.Bookmarks 1.0
import "../components"
import "../components/file-browser"

CoverBackground {
    id: root

    SilicaListView {
        id: view
        spacing: Theme.paddingMedium
        anchors {
            fill: parent
            margins: 1.5*Theme.paddingMedium
        }

        // hide the last item if it is not fully visible
        displayMarginEnd: -(
            Theme.fontSizeSmall + Theme.paddingMedium
        )

        model: BookmarksModel

        delegate: OneLineDelegate {
            id: delegate
            text: name
            minContentHeight: 0
            opacity: 1 - (index * 0.05)

            bodyColumn.spacing: Theme.paddingMedium
            padding.all: 0

            textLabel {
                font.pixelSize: Theme.fontSizeSmall
                palette {
                    primaryColor: Theme.primaryColor
                    highlightColor: Theme.highlightColor
                }
            }

            /*rightItemAlignment: Qt.AlignVCenter
            rightItem: DelegateInfoItem {
                minWidth: 0
                alignment: Qt.AlignRight
                text: "%1%".arg(sizeBar.diskSpaceInfo[1])
                textLabel.font.pixelSize: Theme.fontSizeMedium
            }*/

            StorageSizeBar {
                id: sizeBar
                parent: delegate.bodyColumn
                showLabel: false
                width: parent.width
                path: model.path
            }
        }
    }

    Image {
        rotation: 180
        source: 'qrc:/img//cover.png'
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height - height - Theme.paddingSmall
        width: parent.width - 2 * Theme.paddingSmall
        height: sourceSize.height * width / sourceSize.width
        opacity: Theme.opacityFaint
    }
}
