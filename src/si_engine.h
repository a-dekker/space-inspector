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
    RO_PROPERTY_GADGET(qint64, size, 0); // TODO rename to "bytes"
    RO_PROPERTY_GADGET(QString, formattedSize, ""); // TODO rename to "size"

public:
    SizeInfo() = default;
    SizeInfo(QString name, QString path, bool isDir, qint64 bytes, QString formatted)
        : m_name(name), m_dir(path), m_isDir(isDir), m_size(bytes), m_formattedSize(formatted) {}
    ~SizeInfo() = default;
};

class FolderSizeStatusInfo {
    Q_GADGET
    RO_PROPERTY_GADGET(bool, ok, false);
    RO_PROPERTY_GADGET(QString, name, "");
    RO_PROPERTY_GADGET(QString, path, "");
    RO_PROPERTY_GADGET(qint64, folders, 0);
    RO_PROPERTY_GADGET(qint64, files, 0);
    RO_PROPERTY_GADGET(QString, size, "-");  // human readable size

public:
    FolderSizeStatusInfo() = default;
    FolderSizeStatusInfo(bool ok, QString name, QString path, qint64 files, qint64 folders, QString size)
        : m_ok(ok), m_name(name), m_path(path), m_folders(folders), m_files(files), m_size(size) {}
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
     * @param bytes
     * @return e.g. "61.3 GiB"
     */
    Q_INVOKABLE QString formatFileSize(qint64 bytes);

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
