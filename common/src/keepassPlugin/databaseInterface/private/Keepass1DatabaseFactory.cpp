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

#include "Keepass1DatabaseFactory.h"
#include "Keepass1DatabaseInterface.h"

Keepass1DatabaseFactory::Keepass1DatabaseFactory(QObject *parent) :
    QObject(parent), AbstractDatabaseFactory()
{}

Keepass1DatabaseFactory::~Keepass1DatabaseFactory()
{}

AbstractDatabaseInterface* Keepass1DatabaseFactory::factoryMethod()
{
    // Yes, this factory has the only meaning to return a specific database object.
    return new kpxPrivate::Keepass1DatabaseInterface();
}
