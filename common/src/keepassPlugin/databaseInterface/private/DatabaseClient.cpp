/***************************************************************************
**
** Copyright (C) 2015-2019 Marko Koschak (marko.koschak@tisno.de)
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

#include "DatabaseClient.h"
#include "Keepass2DatabaseInterface.h"
#include "ownKeepassGlobal.h"

using namespace kpxPrivate;
using namespace ownKeepassPublic;

// Global static pointer used to ensure a single instance of the class
// It is used by KdbDatabase, KdbListModel, KdbGroup and KdbEntry classes to access data of the Keepass database
DatabaseClient* DatabaseClient::m_Instance = new DatabaseClient;

DatabaseClient::DatabaseClient(QObject *parent)
    : QObject(parent),
      m_workerThread()
{
    m_interface = new Keepass2DatabaseInterface();

    // DatabaseInterface object m_worker is also a QObject, so in order to use functions from it cast it before
    dynamic_cast<QObject*>(m_interface)->moveToThread(&m_workerThread);
    m_workerThread.start();
}

DatabaseClient::~DatabaseClient()
{
    // first terminate background thread
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }
    // then delete interface and factory objects
    if (m_interface) {
        delete m_interface;
    }
}

DatabaseClient* DatabaseClient::getInstance()
{
    Q_ASSERT(m_Instance);
    return m_Instance;
}
