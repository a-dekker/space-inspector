/*
 * This file is part of Space Inspector.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QDirIterator>

#include "io/globals.h"
#include "si_engine.h"

struct SizeInfoData {
    QString name {};
    bool isDir {false};
    qint64 bytes {0};
};

SpaceInspectorEngine::SpaceInspectorEngine(QObject *parent) :
    Engine(parent) {}

SpaceInspectorEngine::~SpaceInspectorEngine() {}

QString SpaceInspectorEngine::formatFileSize(qint64 bytes) {
    return filesizeToString(bytes);
}

int SpaceInspectorEngine::requestFolderSizeInfo(const QString& folder)
{
    // This function calculates sizes of all folder contents and a
    // summary of the folder itself.
    //
    // Due to limitations in Engine's disk space worker implementation,
    // we have to pass results around as QStringList objects. The
    // final conversion is done in the main thread which is suboptimal.

    return runDiskSpaceWorker([&](int handle, QStringList result){
        // This code is run on the main thread.
        // It converts the calculated sizes into structured objects
        // that can be passed to QML.

        FolderSizeStatusInfo status(
            result[0].isEmpty() ? false : true,
            QFileInfo(result[0]).fileName(),
            QFileInfo(result[0]).absoluteFilePath(),
            result[1].toLongLong(),
            result[2].toLongLong(),
            result[3]
        );

        QVariantList info;
        info.reserve(result.length() / 4);

        for (auto i = 4; i < result.length(); i += 4) {
            info.append(QVariant::fromValue<SizeInfo>({
                result[i+0].split('/').last(),
                result[i+0],
                result[i+1] == QStringLiteral("folder"),
                result[i+2].toLongLong(),
                result[i+3],
            }));
        }

        emit folderSizeInfoReady(handle, status, info);
    }, [folder]() -> QStringList {
        // This code is run in the worker thread.
        // We calculate sizes and return results as a string list.

        /**
         * Info fields:
         *   1. processed folder: not empty on success, empty on failure
         *   2. how many folders were counted? (e.g. "451")
         *   3. how many files were counted? (e.g. "1984")
         *   4. combined human readable disk usage, e.g. "5.0 GiB",
         *      falls back to "-"
         *
         *   5...: groups of four lines for each folder entry:
         *     a. name without path, e.g. "Documents"
         *     b. type, either "file" or "folder"
         *     c. disk usage in bytes
         *          - must be converted back to int for further processing
         *          - falls back to 0 if incalculable
         *          - guaranteed to be >= 0
         *     d. human readable disk usage, e.g. "2.1 GiB", falls back to "-"
         *
         * The result list always has 4*n fields.
         * All fields are empty if the data could not be determined.
         */

        if (folder.isEmpty() || !QFileInfo(folder).isDir()) {
            return {{}, {}, {}, {}};
        }

        int files = 0;
        int dirs = 0;
        qint64 bytes = 0;

        auto processSubdir = [&bytes](const QString& subdir) -> SizeInfoData {
            qint64 subdirBytes = 0;
            QDirIterator it(subdir,
                QDir::AllEntries |
                QDir::System |
                QDir::NoDotAndDotDot |
                QDir::Hidden,
                // list entries recursively
                QDirIterator::Subdirectories);

            while (!it.next().isEmpty()) {
                const auto& info = it.fileInfo();
                subdirBytes += info.size();
            }

            bytes += subdirBytes;
            return {QFileInfo(subdir).absoluteFilePath(), true, subdirBytes};
        };

        auto entriesCount = QDir(folder,
            QLatin1String(""),
            QDir::NoSort,
            QDir::AllEntries |
            QDir::System | /* System is not included in AllEntries */
            QDir::NoDotAndDotDot |
            QDir::Hidden).count();

        // Calculation results are first collected using a
        // very light weight structure for performance reasons.
        QList<SizeInfoData> items;
        items.reserve(entriesCount);

        QDirIterator it(folder,
            QDir::AllEntries |
            QDir::System |
            QDir::NoDotAndDotDot |
            QDir::Hidden,
            // list only immediate entries
            QDirIterator::NoIteratorFlags);

        while(!it.next().isEmpty()) {
            const auto& info = it.fileInfo();
            bytes += info.size();

            if (info.isDir()) {
                ++dirs;
                items.append(processSubdir(info.absoluteFilePath()));
            } else {
                ++files;
                items.append({info.absoluteFilePath(), false, info.size()});
            }
        }

        std::sort(items.begin(), items.begin()+items.count(),
                  [](const SizeInfoData& a, const SizeInfoData& b) -> bool {
            return a.bytes > b.bytes;
        });

        QStringList result {
            folder,
            QStringLiteral("0"),
            QStringLiteral("0"),
            QStringLiteral("-"),
        };
        result.reserve((entriesCount + 1) * 4);

        for (const auto& i : items) {
            result.append({
                i.name,
                i.isDir ? QStringLiteral("folder") :
                          QStringLiteral("file"),
                QString::number(i.bytes),
                filesizeToString(i.bytes),
            });
        }

        result[1] = QString::number(dirs);
        result[2] = QString::number(files);
        result[3] = filesizeToString(bytes);
        return result;
    });
}
