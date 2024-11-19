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
import Nemo.Notifications 1.0
import Harbour.FileBrowser.Bookmarks 1.0
import Harbour.FileBrowser.Engine 1.0
import "pages"

ApplicationWindow {
    id: main

    property string appName: "Space Inspector"

    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: defaultAllowedOrientations

    cover: Qt.resolvedUrl("pages/CoverPage.qml")
    initialPage: Component {
        PlacesPage {}

    Notification {
        id: workerErrorNotification
        appIcon: "image://theme/icon-lock-warning"
        previewSummary: qsTr("An error occurred")
        appName: main.appName

        summary: previewSummary
        previewBody: ""
        body: ""
    }

    Connections {
        target: Engine
        onWorkerErrorOccurred: {
            console.warn("FileWorker error: ", message, filename)
            workerErrorNotification.body = message + "\n" + filename
            workerErrorNotification.publish()
        }
    }

    Component.onCompleted: {
        BookmarksModel.sortFilter([BookmarkGroup.Device])
    }
}
