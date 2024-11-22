/*
 * This file is part of Space Inspector.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SI_ENGINE_H
#define SI_ENGINE_H

#include "io/engine.h"
#include "io/property_macros.h"

class SizeInfo {
    Q_GADGET
    RO_PROPERTY_GADGET(QString, name, "");
    RO_PROPERTY_GADGET(QString, dir, ""); // TODO rename to "path"
    RO_PROPERTY_GADGET(bool, isDir, false);
    RO_PROPERTY_GADGET(qint64, kilobytes, 0);
    RO_PROPERTY_GADGET(QString, formattedSize, "");

public:
    SizeInfo() = default;
    SizeInfo(QString name, QString path, bool isDir, qint64 bytes, QString formatted)
        : m_name(name), m_dir(path), m_isDir(isDir), m_kilobytes(bytes/1024), m_formattedSize(formatted) {}
    ~SizeInfo() = default;
};

class FolderSizeStatusInfo {
    Q_GADGET
    RO_PROPERTY_GADGET(bool, ok, false);
    RO_PROPERTY_GADGET(QString, name, "");
    RO_PROPERTY_GADGET(QString, path, "");
    RO_PROPERTY_GADGET(qint64, folders, 0);
    RO_PROPERTY_GADGET(qint64, files, 0);
    RO_PROPERTY_GADGET(QString, formattedSize, "-");  // human readable size

public:
    FolderSizeStatusInfo() = default;
    FolderSizeStatusInfo(bool ok, QString name, QString path, qint64 files, qint64 folders, QString formattedSize)
        : m_ok(ok), m_name(name), m_path(path), m_folders(folders), m_files(files), m_formattedSize(formattedSize) {}
    ~FolderSizeStatusInfo() = default;
};

/**
 * @brief Engine to handle file operations, settings and other generic functionality.
 */
class SpaceInspectorEngine : public Engine
{
    Q_OBJECT

public:
    explicit SpaceInspectorEngine(QObject *parent = nullptr);
    virtual ~SpaceInspectorEngine();

    /**
     * @brief Format bytes as human-readable file size.
     *
     * @note The size is passed in KiB because QML does not
     * properly support 64bit integers. Sizes in bytes
     * quickly overflow.
     *
     * @param kilobytes Size in kilobytes (actually kibibytes, KiB)
     * @return e.g. "61.3 GiB"
     */
    Q_INVOKABLE QString formatFileSize(qint64 kilobytes);

    /**
     * @brief Asynchronously calculate sizes of folder contents.
     *
     * The function immediately returns a handle. Wait for the
     * fileSizeInfoReady(handle, info) signal to get the actual information.
     *
     * @note The handle is only valid until the signal is sent.
     *
     * @param folder Path of the folder to process
     * @return signal handle
     */
    Q_INVOKABLE int requestFolderSizeInfo(const QString& folder);

    static QObject* qmlInstanceSI(QQmlEngine* engine, QJSEngine* scriptEngine) {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);
        return new SpaceInspectorEngine;
    }

signals:
    /**
     * @brief Result of a requestFolderSizeInfo(folder) call.
     *
     * @param status General info about the processed folder
     * @param info List of @c SizeInfo items for each entry of the folder
     */
    void folderSizeInfoReady(int handle, const FolderSizeStatusInfo& status, const QVariantList& info);
};

#endif // SI_ENGINE_H
