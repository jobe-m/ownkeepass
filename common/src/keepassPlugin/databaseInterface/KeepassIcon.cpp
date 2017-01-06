/***************************************************************************
**
** Copyright (C) 2016 Marko Koschak (marko.koschak@tisno.de)
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

#include "KeepassIcon.h"
#include "private/DatabaseClient.h"
#include "private/AbstractDatabaseInterface.h"

#include <QDir>
#include <QStandardPaths>
#include <QDebug>

using namespace kpxPublic;

QImage KeepassIcon::requestImage(const QString &uuid, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    QImage icon;
    // Check first char and determine if the icon is a stardart keepass icon (e.g. icf12) otherwise the icon is a custom one
    if (uuid.startsWith("i")) {
        icon = QImage(":/entryicons/" + uuid + ".png", "PNG");
    } else {
        icon = (dynamic_cast<AbstractDatabaseInterface*>(kpxPrivate::DatabaseClient::getInstance()->getInterface()))->getCustomIcon(uuid);
    }
    if (size) {
        *size = QSize(icon.width(), icon.height()); // (128, 128);
    }
    return icon;
}
