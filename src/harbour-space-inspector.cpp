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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickView>
#include <QScopedPointer>
#include <QtQml>
#include <QtQuick/QQuickPaintedItem>

#include "io/engine.h"
#include "io/statfileinfo.h"
#include "io/filedata.h"
#include "io/bookmarks.h"
#include "io/enumcontainer.h"
#include "shell.h"

int main(int argc, char *argv[]) {
    qRegisterMetaType<StatFileInfo>("StatFileInfo");
    qRegisterMetaType<QList<StatFileInfo>>("QList<StatFileInfo>");
    qRegisterMetaType<LocationAlternative>("LocationAlternative");
    qRegisterMetaType<QList<LocationAlternative>>("QList<LocationAlternative>");

    qmlRegisterType<FileData>("Harbour.FileBrowser.FileData", 1, 0, "FileData");
    REGISTER_ENUMS(Bookmarks, "Harbour.FileBrowser.Bookmarks", 1, 0)
    qmlRegisterUncreatableType<BookmarkGroup>("Harbour.FileBrowser.Bookmarks", 1, 0, "BookmarkGroup", "This is only a container for an enumeration.");
    qmlRegisterType<BookmarkWatcher>("Harbour.FileBrowser.Bookmarks", 1, 0, "Bookmark");
    qmlRegisterSingletonType<Engine>("Harbour.FileBrowser.Engine", 1, 0, "Engine", &Engine::qmlInstance);
    qmlRegisterSingletonType<BookmarksModel>("Harbour.FileBrowser.Bookmarks", 1, 0, "BookmarksModel",
        [](QQmlEngine* engine, QJSEngine* scriptEngine) -> QObject* {
            Q_UNUSED(engine);
            Q_UNUSED(scriptEngine);
            return new Engine;
     });

    qmlRegisterType<Shell>("harbour.space.inspector.shell", 1, 0, "Shell");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-space-inspector"); // needed for Sailjail
    app->setApplicationName("harbour-space-inspector");

    QScopedPointer<QQuickView> view(SailfishApp::createView());



    view->setSource(SailfishApp::pathToMainQml());
    view->show();

    return app->exec();
}
