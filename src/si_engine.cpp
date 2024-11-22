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
    QString path {};
    bool isDir {false};
    qint64 bytes {0};
};

SpaceInspectorEngine::SpaceInspectorEngine(QObject *parent) :
    Engine(parent) {}

SpaceInspectorEngine::~SpaceInspectorEngine() {}

QString SpaceInspectorEngine::formatFileSize(qint64 kilobytes) {
    return filesizeToString(kilobytes * 1024);
}

int SpaceInspectorEngine::requestFolderSizeInfo(const QString& folder)
{
    // This function calculates sizes of all folder contents and a
    // summary of the folder itself.

    return runDiskSpaceWorker([&](int handle, QVariant resultVariant){
        const auto& result = resultVariant.value<QPair<FolderSizeStatusInfo, QVariantList>>();
        emit folderSizeInfoReady(handle, result.first, result.second);
    }, [folder]() -> QVariant {
        QFileInfo folderInfo(folder);

        if (folder.isEmpty() || !folderInfo.isDir()) {
            return QVariant::fromValue(
                QPair<FolderSizeStatusInfo, QVariantList>{{}, {}});
        }

        int files = 0;
        int dirs = 0;
        qint64 bytes = folderInfo.size();

        auto processSubdir = [](const QFileInfo& subdir, qint64& fileBytes) -> void {
            QDirIterator it(subdir.absoluteFilePath(),
                // QDir::AllEntries | -- excluded: devices
                // QDir::System | -- excluded: broken symlinks
                QDir::Dirs |
                QDir::Files |
                QDir::NoSymLinks | // they don't take space
                QDir::NoDotAndDotDot |
                QDir::Hidden,
                // list entries recursively
                QDirIterator::Subdirectories);

            while (!it.next().isEmpty()) {
                fileBytes += it.fileInfo().size();
            }
        };

        // Absolutely all entries are included in the base
        // listing so they show up in the file list. Special
        // files are excluded when processing folder contents.
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

        qint64 fileBytes = 0;
        while(!it.next().isEmpty()) {
            const auto& info = it.fileInfo();
            fileBytes = info.size();

            if (info.isDir() && !info.isSymLink()) {
                ++dirs;
                processSubdir(info, fileBytes);
            } else {
                ++files;
            }

            bytes += fileBytes;
            items.append({
                info.fileName(),
                info.absoluteFilePath(),
                info.isDir(),
                fileBytes
            });
        }

        std::sort(items.begin(), items.begin()+items.count(),
                  [](const SizeInfoData& a, const SizeInfoData& b) -> bool {
            return a.bytes > b.bytes;
        });

        FolderSizeStatusInfo status(
            true,
            folderInfo.fileName(),
            folderInfo.absoluteFilePath(),
            dirs,
            files,
            filesizeToString(bytes)
        );

        QVariantList info;
        info.reserve(entriesCount);

        for (const auto& i : items) {
            info.append(QVariant::fromValue<SizeInfo>(SizeInfo{
                i.name,
                i.path,
                i.isDir,
                i.bytes,
                filesizeToString(i.bytes)
            }));
        }

        return QVariant::fromValue(
            QPair<FolderSizeStatusInfo, QVariantList>{
                status, info
        });
    });
}
