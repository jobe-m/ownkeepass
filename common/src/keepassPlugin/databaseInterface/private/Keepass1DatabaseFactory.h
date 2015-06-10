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

#ifndef KEEPASS1DATABASEFACTORY_H
#define KEEPASS1DATABASEFACTORY_H

#include <QObject>
#include "AbstractDatabaseFactory.h"

class Keepass1DatabaseFactory : public QObject, public AbstractDatabaseFactory
{
    Q_OBJECT
    Q_INTERFACES(AbstractDatabaseFactory)

public:
    explicit Keepass1DatabaseFactory(QObject *parent = 0);
    virtual ~Keepass1DatabaseFactory();

    // factory method will be implemented in the subclass for each database type
    AbstractDatabaseInterface* factoryMethod();

signals:

public slots:

};

#endif // KEEPASS1DATABASEFACTORY_H
