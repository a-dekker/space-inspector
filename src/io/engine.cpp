/*
    From Kari's excellent File Browser, which has been released into the public domain.
    See https://github.com/karip/harbour-file-browser
*/

#include "engine.h"
#include <QDateTime>
#include <QTextStream>
#include <QSettings>
#include <QStandardPaths>
#include <unistd.h>
#include "globals.h"
#include "fileworker.h"
#include "statfileinfo.h"

Engine::Engine(QObject *parent) :
    QObject(parent),
    m_clipboardContainsCopy(false),
    m_progress(0)
{
    m_fileWorker = new FileWorker;

    // update progress property when worker progresses
    connect(m_fileWorker, SIGNAL(progressChanged(int, QString)),
            this, SLOT(setProgress(int, QString)));

    // pass worker end signals to QML
    connect(m_fileWorker, SIGNAL(done()), this, SIGNAL(workerDone()));
    connect(m_fileWorker, SIGNAL(errorOccurred(QString, QString)),
            this, SIGNAL(workerErrorOccurred(QString, QString)));
    connect(m_fileWorker, SIGNAL(fileDeleted(QString)), this, SIGNAL(fileDeleted(QString)));
}

Engine::~Engine()
{
    m_fileWorker->cancel(); // ask the background thread to exit its loop
    // is this the way to force stop the worker thread?
    m_fileWorker->wait();   // wait until thread stops
    m_fileWorker->deleteLater();    // delete it
}

void Engine::deleteFiles(QStringList filenames)
{
    setProgress(0, "");
    m_fileWorker->startDeleteFiles(filenames);
}

void Engine::cutFiles(QStringList filenames)
{
    m_clipboardFiles = filenames;
    m_clipboardContainsCopy = false;
    emit clipboardCountChanged();
    emit clipboardContainsCopyChanged();
}

void Engine::copyFiles(QStringList filenames)
{
    // don't copy special files (chr/blk/fifo/sock)
    QMutableStringListIterator i(filenames);
    while (i.hasNext()) {
        QString filename = i.next();
        StatFileInfo info(filename);
        if (info.isSystem())
            i.remove();
    }

    m_clipboardFiles = filenames;
    m_clipboardContainsCopy = true;
    emit clipboardCountChanged();
    emit clipboardContainsCopyChanged();
}

QStringList Engine::listExistingFiles(QString destDirectory)
{
    if (m_clipboardFiles.isEmpty()) {
        return QStringList();
    }
    QDir dest(destDirectory);
    if (!dest.exists()) {
        return QStringList();
    }

    QStringList existingFiles;
    foreach (QString filename, m_clipboardFiles) {
        QFileInfo fileInfo(filename);
        QString newname = dest.absoluteFilePath(fileInfo.fileName());

        // source and dest filenames are the same? let pasteFiles() create a numbered copy for it.
        if (filename == newname) {
            continue;
        }

        // dest is under source? (directory) let pasteFiles() return an error.
        if (newname.startsWith(filename)) {
            return QStringList();
        }
        if (QFile::exists(newname)) {
            existingFiles.append(fileInfo.fileName());
        }
    }
    return existingFiles;
}


void Engine::cancel()
{
    m_fileWorker->cancel();
}

QString Engine::homeFolder() const
{
    return QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
}

static QStringList subdirs(const QString &dirname)
{
    QDir dir(dirname);
    if (!dir.exists())
        return QStringList();
    dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);
    QStringList list = dir.entryList();
    QStringList abslist;
    foreach (QString relpath, list) {
        abslist.append(dir.absoluteFilePath(relpath));
    }
    return abslist;
}

QString Engine::sdcardPath() const
{
    // from SailfishOS 2.2.0 onwards, "/media/sdcard" is
    // a symbolic link instead of a folder. In that case, follow the link
    // to the actual folder.
    QString sdcardFolder = "/media/sdcard";
    QFileInfo fileinfo(sdcardFolder);
    if (fileinfo.isSymLink()) {
        sdcardFolder = fileinfo.symLinkTarget();
    }

    // get sdcard dir candidates for "/media/sdcard" (or its symlink target)
    QStringList sdcards = subdirs(sdcardFolder);

    // some users may have a symlink from "/media/sdcard/nemo" (not from "/media/sdcard"), which means
    // no sdcards are found, so also get candidates directly from "/run/media/nemo" for those users
    if (sdcardFolder != "/run/media/nemo")
        sdcards.append(subdirs("/run/media/nemo"));

    if (sdcards.isEmpty())
        return QString();

    // remove all directories which are not mount points
    QStringList mps = mountPoints();
    QMutableStringListIterator i(sdcards);
    while (i.hasNext()) {
        QString dirname = i.next();
        // is it a mount point?
        if (!mps.contains(dirname))
            i.remove();
    }

    // none found, return empty string
    if (sdcards.isEmpty())
        return QString();

    // if only one directory, then return it
    if (sdcards.count() == 1)
        return sdcards.first();

    // if multiple directories, then return the sdcard parent folder
    // this works for SFOS<2.2 and SFOS>=2.2, because "/media/sdcard" should exist in both
    // as a folder or symlink
    return "/media/sdcard";
}

QString Engine::androidSdcardPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/android_storage";
}

bool Engine::exists(QString filename)
{
    if (filename.isEmpty())
        return false;

    return QFile::exists(filename);
}

QStringList Engine::diskSpace(QString path)
{
    if (path.isEmpty())
        return QStringList();

    // return no disk space for sdcard parent directory
    if (path == "/media/sdcard")
        return QStringList();

    // run df for the given path to get disk space
    QString blockSize = "--block-size=1024";
    QString result = execute("/bin/df", QStringList() << blockSize << path, false);
    if (result.isEmpty())
        return QStringList();

    // split result to lines
    QStringList lines = result.split(QRegExp("[\n\r]"));
    if (lines.count() < 2)
        return QStringList();

    // get first line and its columns
    QString line = lines.at(1);
    QStringList columns = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
    if (columns.count() < 5)
        return QStringList();

    QString totalString = columns.at(1);
    QString usedString = columns.at(2);
    QString percentageString = columns.at(4);
    qint64 total = totalString.toLongLong() * 1024LL;
    qint64 used = usedString.toLongLong() * 1024LL;

    return QStringList() << percentageString << filesizeToString(used)+"/"+filesizeToString(total);
}

void Engine::setProgress(int progress, QString filename)
{
    m_progress = progress;
    m_progressFilename = filename;
    emit progressChanged();
    emit progressFilenameChanged();
}

QStringList Engine::mountPoints() const
{
    // read /proc/mounts and return all mount points for the filesystem
    QFile file("/proc/mounts");
    if (!file.open(QFile::ReadOnly | QFile::Text))
        return QStringList();

    QTextStream in(&file);
    QString result = in.readAll();

    // split result to lines
    QStringList lines = result.split(QRegExp("[\n\r]"));

    // get columns
    QStringList dirs;
    foreach (QString line, lines) {
        QStringList columns = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
        if (columns.count() < 6) // sanity check
            continue;

        QString dir = columns.at(1);
        dirs.append(dir);
    }

    return dirs;
}

