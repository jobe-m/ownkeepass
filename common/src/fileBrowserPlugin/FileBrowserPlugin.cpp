/***************************************************************************
**
** Copyright (C) 2015 - 2018 Marko Koschak (marko.koschak@tisno.de)
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
#include <QTranslator>
#include "FileBrowserPlugin.h"
#include "SdCardHelper.h"

FileBrowserListModel::FileBrowserListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_dir("root"),
      m_dir_previous(""),
      m_breadcrum_path(""),
      m_showDirsOnly(false),
      m_valid_dir(false),
      m_showHiddenFiles(false),
      m_showFileFilter(false),
      m_fileFilter()
{
    m_dir.setSorting(QDir::DirsFirst);
    m_dir.setFilter(QDir::AllEntries | QDir::NoDot);
    m_fileFilter.append(QString("*"));
    m_dir.setNameFilters(m_fileFilter);
    appendRootElements();
}

void FileBrowserListModel::appendRootElements()
{
    clear();
    // Fill with root elements
    beginInsertRows(QModelIndex(), 0, 2);
    m_items.append(fileBrowserPlugin::FileBrowserItem(1,
                                                      QString("..1"),
                                                      QString("home"),
                                                      QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0],
                                                      true));
    m_items.append(fileBrowserPlugin::FileBrowserItem(2,
                                                      QString("..2"),
                                                      QString("pin"),
                                                      getSdCardPath(),
                                                      sdCardExists()));
    m_items.append(fileBrowserPlugin::FileBrowserItem(3,
                                                      QString("..3"),
                                                      QString("folder"),
                                                      QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0] + QString("/android_storage"),
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

        // Update list view but only when not on root page
        if (m_dir.path() != "root") {
            listDir();
        }
        emit showHiddenFilesChanged();
    }
}

void FileBrowserListModel::setShowFileFilter(bool value)
{
    if (m_showFileFilter != value) {
        m_showFileFilter = value;
        if (m_showFileFilter) {
            m_dir.setNameFilters(m_fileFilter);
        } else {
            // If file filter is disabled just show everything
            QStringList fileFilters;
            fileFilters.append(QString("*"));
            m_dir.setNameFilters(fileFilters);
        }

        // Update list view but only when not on root page
        if (m_dir.path() != "root") {
            listDir();
        }
        emit showFileFilterChanged();
    }
}

void FileBrowserListModel::setFileFilter(QStringList value)
{
    if (m_fileFilter != value) {
        m_fileFilter = value;
        m_dir.setNameFilters(m_fileFilter);

        // Update list view but only when not on root page
        if (m_dir.path() != "root") {
            listDir();
        }
        emit fileFilterChanged();
    }
}

void FileBrowserListModel::listDir()
{
    clear();
    if (m_dir.exists()) {
        QFileInfoList list;
        // list always all dirs, but apply filter to files below
        if (m_showDirsOnly) {
            if (m_showHiddenFiles) {
                list = m_dir.entryInfoList(QDir::AllDirs | QDir::NoDot | QDir::Hidden, QDir::DirsFirst);
            } else {
                list = m_dir.entryInfoList(QDir::AllDirs | QDir::NoDot, QDir::DirsFirst);
            }
        } else {
            if (m_showHiddenFiles) {
                list = m_dir.entryInfoList(QDir::AllDirs | QDir::Files | QDir::NoDot | QDir::Hidden, QDir::DirsFirst);
            } else {
                list = m_dir.entryInfoList(QDir::AllDirs | QDir::Files | QDir::NoDot, QDir::DirsFirst);
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
                // use previous directory to know if the user opened the android_storage from home folder or from root
                // Only when he opened it from root it should go back to root view
                (m_dir.path() == QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0] + "/android_storage" &&
                 m_dir_previous.path() == "root")) {
            m_dir_previous = m_dir;
            m_dir.setPath("root");
            appendRootElements();
        } else {
            m_dir_previous = m_dir;
            m_dir.cd("..");
            listDir();
        }
    } else {
        m_dir_previous = m_dir;
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
    return SdCardHelper::sdCardExists();
}

QString FileBrowserListModel::getSdCardPath()
{
    QString sdCardPath = SdCardHelper::getSdCardPath();
    if (sdCardPath.compare("error-multi-partition") == 0) {
        emit showErrorBanner();
    }
    return sdCardPath;
}

QStringList FileBrowserListModel::sdCardPartitions()
{
    return SdCardHelper::sdCardPartitions();
}

QStringList FileBrowserListModel::mountPoints() const
{
    return SdCardHelper::mountPoints();
}
