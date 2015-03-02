/***************************************************************************
**
** Copyright (C) 2013 - 2014 Marko Koschak (marko.koschak@tisno.de)
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
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>

#include "OwnKeepassHelper.h"

OwnKeepassHelper::OwnKeepassHelper(QObject *parent)
    : QObject(parent),
      m_dir("/media/sdcard")
{}

bool OwnKeepassHelper::fileExists(const QString filePath) const
{
    if (filePath == "") return false;
    // Check if file exists
    if (QFile::exists(filePath)) return true;
    // File does not exist
    else return false;
}

bool OwnKeepassHelper::createFilePathIfNotExist(const QString filePath) const
{
    if (filePath == "") return false;
    // Check if file path exists
    if (QDir(QFileInfo(filePath).path()).exists()) return true;
    // Check if file path could be created
    else if (QDir(QFileInfo(filePath).path()).mkpath(QFileInfo(filePath).path())) return true;
    // File path could not be created
    else return false;
}

bool OwnKeepassHelper::sdCardExists()
{
    QStringList sdCards(sdCardPartitions());
    // multi-partition SD cards (count > 1) are not supported
    return (sdCards.count() == 1);
}

QString OwnKeepassHelper::getHomePath()
{
    return QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
}

QString OwnKeepassHelper::getSdCardPath()
{
    QStringList sdCards(sdCardPartitions());
    if (sdCards.isEmpty()) {
        return QString();
    }
    if (sdCards.count() > 1) {
        // tell user that multi-partition SD cards are not supported
        emit showErrorBanner();
        return QString();
    }

    // return always first partition, multi-partition SD cards are not supported
    QString sdCard(m_dir.absoluteFilePath(sdCards.first()));
    return sdCard;
}

QString OwnKeepassHelper::getAndroidStoragePath()
{
    return "/data/sdcard";
}

QStringList OwnKeepassHelper::mountPoints() const
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

QStringList OwnKeepassHelper::sdCardPartitions()
{
    if (!m_dir.exists()){
        return QStringList();
    }
    m_dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);
    QStringList sdCardPartitions = m_dir.entryList();
    if (sdCardPartitions.isEmpty()) {
        return QStringList();
    }

    // remove all directories which are not mount points
    QStringList mounts = mountPoints();
    QMutableStringListIterator i(sdCardPartitions);
    while (i.hasNext()) {
        QString dirname = i.next();
        QString abspath = m_dir.absoluteFilePath(dirname);
        if (!mounts.contains(abspath)) {
            i.remove();
        }
    }

    return sdCardPartitions;
}

// Get phisical path for file location
QString OwnKeepassHelper::getLocationRootPath(const int value)
{
    switch (value) {
    case 1:
        return getHomePath();
    case 2:
        return getSdCardPath();
    case 3:
        return getAndroidStoragePath();
    default:
        return "";
    }
}

