/***************************************************************************
**
** Copyright (C) 2013 - 2018 Marko Koschak (marko.koschak@tisno.de)
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
#include "SdCardHelper.h"

OwnKeepassHelper::OwnKeepassHelper(QObject *parent)
    : QObject(parent)
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
    return SdCardHelper::sdCardExists();
}

QString OwnKeepassHelper::getHomePath()
{
    return QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
}

QString OwnKeepassHelper::getSdCardPath()
{
    QString sdCardPath = SdCardHelper::getSdCardPath();
    if (sdCardPath.compare("error-multi-partition") == 0) {
        emit showErrorBanner();
    }
    return sdCardPath;}

QString OwnKeepassHelper::getAndroidStoragePath()
{
    return getHomePath() + "/android_storage";
}

QStringList OwnKeepassHelper::mountPoints() const
{
    return SdCardHelper::mountPoints();
}

QStringList OwnKeepassHelper::sdCardPartitions()
{
    return SdCardHelper::sdCardPartitions();
}

// Get physical path for file location
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

