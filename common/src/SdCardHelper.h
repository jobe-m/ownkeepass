/***************************************************************************
**
** Copyright (C) 2018 Marko Koschak (marko.koschak@tisno.de)
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

#ifndef SDCARDHELPER_H
#define SDCARDHELPER_H

#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>

#define SDCARD_ROOT_PATH "/run/media/nemo"

class SdCardHelper
{
private:
    SdCardHelper() {}
    virtual ~SdCardHelper() {}

public:
    static bool sdCardExists()
    {
        QStringList sdCards(sdCardPartitions());
        // multi-partition SD cards (count > 1) are not supported
        return (sdCards.count() == 1);
    }

    static QString getSdCardPath()
    {
        QStringList sdCards(sdCardPartitions());
        if (sdCards.isEmpty()) {
            return QString();
        }
        if (sdCards.count() > 1) {
            // tell user that multi-partition SD cards are not supported
            return QString("error-multi-partition");
        }

        // return always first partition, multi-partition SD cards are not supported
        QDir mountDir(SDCARD_ROOT_PATH);
        QString sdCard(mountDir.absoluteFilePath(sdCards.first()));
        return sdCard;
    }

    static QStringList mountPoints()
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

    static QStringList sdCardPartitions()
    {
        QDir mountDir(SDCARD_ROOT_PATH);
        if (!mountDir.exists()){
            return QStringList();
        }
        mountDir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);
        QStringList sdCardPartitions = mountDir.entryList();
        if (sdCardPartitions.isEmpty()) {
            return QStringList();
        }

        // remove all directories which are not mount points
        QStringList mounts = mountPoints();
        QMutableStringListIterator i(sdCardPartitions);
        while (i.hasNext()) {
            QString dirname = i.next();
            QString abspath = mountDir.absoluteFilePath(dirname);
            if (!mounts.contains(abspath)) {
                i.remove();
            }
        }

        return sdCardPartitions;
    }
};


#endif // SDCARDHELPER_H
