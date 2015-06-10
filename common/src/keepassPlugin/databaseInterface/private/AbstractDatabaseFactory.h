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

#ifndef ABSTRACTDATABASEFACTORY_H
#define ABSTRACTDATABASEFACTORY_H

#include "AbstractDatabaseInterface.h"

// This abstract class is used to specify a factory method which creates a database instance.
// Due to separating code bases of each database implementation (Keepass 1 and Keepass 2)
// the actual instance of the specific database object is done in the contrete
// implementation of the different database factories.

// Interface for accessing a database
class AbstractDatabaseFactory
{
public:
    virtual ~AbstractDatabaseFactory(){}

    // factory method will be implemented in the subclass for each database type
    virtual AbstractDatabaseInterface* factoryMethod() = 0;
};

Q_DECLARE_INTERFACE(AbstractDatabaseFactory, "harbour.ownkeepass.AbstractDatabaseFactory")

#endif // ABSTRACTDATABASEFACTORY_H
