/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
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

#ifndef PROPERTYINTERFACE_H
#define PROPERTYINTERFACE_H

#include <QObject>
#include "KdbInterfaceWorker.h"

namespace kpxPrivate {

// Interface for integer property passing to backend database
class IntPropertyInterface : public QObject
{
    Q_OBJECT

public:
    IntPropertyInterface(KdbInterfaceWorker* dbWorker, QObject* parent = 0)
        : QObject(parent),
          m_dbWorker(dbWorker) {}

signals:
    void sendSignal(int value);

public slots:
    virtual void slot(int value) = 0;

protected:
    KdbInterfaceWorker* m_dbWorker;
};
}

#endif // PROPERTYINTERFACE_H
