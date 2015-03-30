/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include <QTextStream>
#include <QStandardPaths>
#include "FileBrowserPlugin.h"


FileBrowserListModel::FileBrowserListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_dir("root"),
      m_breadcrum_path(""),
      m_showDirsOnly(false),
      m_valid_dir(false),
      m_showHiddenFiles(false)
{
    m_dir.setSorting(QDir::DirsFirst);
    m_dir.setFilter(QDir::AllEntries | QDir::NoDot);
    appendRootElements();
}

void FileBrowserListModel::appendRootElements()
{
    clear();
    // Fill with root elements
    beginInsertRows(QModelIndex(), 0, 2);
    m_items.append(fileBrowserPlugin::FileBrowserItem(1,
                                                      QString("Home"),
                                                      QString("home"),
                                                      QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0],
                                                      true));
    m_items.append(fileBrowserPlugin::FileBrowserItem(2,
                                                      QString("SD Card"),
                                                      QString("pin"),
                                                      getSdCardPath(),
                                                      sdCardExists()));
    m_items.append(fileBrowserPlugin::FileBrowserItem(3,
                                                      QString("Android Storage"),
                                                      QString("folder"),
                                                      QString("/data/sdcard"),
                                                      true));
    endInsertRows();
    m_breadcrum_path = "";
    emit breadcrumPathChanged();
    m_valid_dir = false;
    emit validDirChanged();
}

void FileBrowserListModel::loadFilePath(QString path)
{
    QFileInfo info(path);
    if (info.exists()) {
        if (info.isDir()) {
            m_dir.setPath(path);
        } else {
            m_dir = info.dir();
        }
        listDir();
    }
}

void FileBrowserListModel::setShowHiddenFiles(bool value)
{
    if (m_showHiddenFiles != value) {
        m_showHiddenFiles = value;

        // Do not update list view on root page
        if (m_dir.path() != "root") {
            listDir();
        }
        emit showHiddenFilesChanged();
    }
}

void FileBrowserListModel::listDir()
{
    clear();
    if (m_dir.exists()) {
        QFileInfoList list;
        if (m_showDirsOnly) {
            if (m_showHiddenFiles) {
                list = m_dir.entryInfoList(QDir::Dirs | QDir::NoDot | QDir::Hidden, QDir::DirsFirst);
            } else {
                list = m_dir.entryInfoList(QDir::Dirs | QDir::NoDot, QDir::DirsFirst);
            }
        } else {
            if (m_showHiddenFiles) {
                list = m_dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDot | QDir::Hidden, QDir::DirsFirst);
            } else {
                list = m_dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDot, QDir::DirsFirst);
            }
        }
        foreach (const QFileInfo &info, list) {
            QString icon;
            if (info.isDir()) {
                if (info.fileName() == "..") {
                    icon = "back";
                } else {
                    icon = "folder";
                }
            } else {
                icon = "other";
            }
            fileBrowserPlugin::FileBrowserItem item(0, info.fileName(), icon, info.filePath(), true);
            beginInsertRows(QModelIndex(), 0, 0);
            m_items.append(item);
            endInsertRows();
        }
        m_breadcrum_path = m_dir.path();
        emit breadcrumPathChanged();
        m_valid_dir = true;
        emit validDirChanged();
    }
}

void FileBrowserListModel::cd(QString path)
{
    if (path == "..") {
        if (m_dir.path() == QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0] ||
                m_dir.path() == getSdCardPath() ||
                m_dir.path() == "/data/sdcard") {
            m_dir.setPath("root");
            appendRootElements();
        } else {
            m_dir.cd("..");
            listDir();
        }
    } else {
        if (m_dir.path() == "root") {
            m_dir.setPath(path);
        } else {
            m_dir.cd(path);
        }
        listDir();
    }
}

int FileBrowserListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_items.count();
}

QVariant FileBrowserListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_items.count())
        return QVariant();

    return m_items[index.row()].get(role);
}

void FileBrowserListModel::clear()
{
    beginResetModel();
    m_items.clear();
    endResetModel();
}

bool FileBrowserListModel::sdCardExists()
{
    QStringList sdCards(sdCardPartitions());
    // multi-partition SD cards (count > 1) are not supported
    return (sdCards.count() == 1);
}

QString FileBrowserListModel::getSdCardPath()
{
    QStringList sdCards(sdCardPartitions());
    if (sdCards.isEmpty()) {
        return QString("error");
    }
    if (sdCards.count() > 1) {
        // tell user that multi-partition SD cards are not supported
        emit showErrorBanner();
        return QString("error");
    }

    // return always first partition, multi-partition SD cards are not supported
    QDir dir("/media/sdcard");
    QString sdCard(dir.absoluteFilePath(sdCards.first()));
    return sdCard;
}

QStringList FileBrowserListModel::sdCardPartitions()
{
    QDir dir("/media/sdcard");
    if (!dir.exists()){
        return QStringList();
    }
    dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);
    QStringList sdCardPartitions = dir.entryList();
    if (sdCardPartitions.isEmpty()) {
        return QStringList();
    }

    // remove all directories which are not mount points
    QStringList mounts = mountPoints();
    QMutableStringListIterator i(sdCardPartitions);
    while (i.hasNext()) {
        QString dirname = i.next();
        QString abspath = dir.absoluteFilePath(dirname);
        if (!mounts.contains(abspath)) {
            i.remove();
        }
    }

    return sdCardPartitions;
}

QStringList FileBrowserListModel::mountPoints() const
{
    // read /proc/mounts and return all mount points for the filesystem
    QFile file("/proc/mounts");
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        return QStringList();
    }
    QTextStream in(&file);
    QString result = in.readAll();

    // split result to lines
    QStringList lines = result.split(QRegExp("[\n\r]"));

    // get columns
    QStringList dirs;
    foreach (QString line, lines) {
        QStringList columns = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
        if (columns.count() < 6) { // skip broken mount points
            continue;
        }

        QString dir = columns.at(1);
        dirs.append(dir);
    }

    return dirs;
}
