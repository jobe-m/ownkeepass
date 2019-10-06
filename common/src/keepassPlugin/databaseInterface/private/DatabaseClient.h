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

#ifndef KDBINTERFACE_H
#define KDBINTERFACE_H

#include <QObject>
#include <QThread>
#include "AbstractDatabaseInterface.h"


namespace kpxPrivate {

class DatabaseClient : public QObject
{
    Q_OBJECT

public:
    virtual ~DatabaseClient();

    // get Singleton
    static DatabaseClient* getInstance();

    // init interface for specific database type
    int initDatabaseInterface();

    // close interface so that it can be initalized again
    void closeDatabaseInterface();

    // access to internal database interface needed to connect to its slots
    QObject* getInterface() {
        if (m_initialized) {
            return dynamic_cast<QObject*>(m_interface);
        } else {
            Q_ASSERT(false);
            return NULL;
        }
    }

private:
    // prevent object creation, it will be created as singleton object
    DatabaseClient(QObject* parent = 0);
    Q_DISABLE_COPY(DatabaseClient)

    AbstractDatabaseInterface* m_interface;

    QThread m_workerThread;
    static DatabaseClient* m_Instance;

    // indicator for an initialized and ready to use database interface
    bool m_initialized;
};

}
#endif // KDBINTERFACE_H
