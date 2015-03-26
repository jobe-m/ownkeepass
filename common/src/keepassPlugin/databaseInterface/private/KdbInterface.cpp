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

#include "KdbInterface.h"
//#include "KdbInterfaceWorker.h"
#include "KdbxInterfaceWorker.h"

using namespace kpxPrivate;

// Global static pointer used to ensure a single instance of the class
// It is used by KdbDatabase, KdbListModel, KdbGroup and KdbEntry classes to access data of the Keepass database
KdbInterface* KdbInterface::m_Instance = new KdbInterface;

KdbInterface::KdbInterface(QObject *parent)
    : QObject(parent),
      m_workerThread()
{
    // Here a interface worker will be instantiated which operates on a Keepass version 1 database
    // To enable other database formats just load here another worker
    // TODO for KeepassX2
//    m_worker = new keepassClassic::KdbInterfaceWorker;
    m_worker = new keepass2Format::KdbxInterfaceWorker;
    // m_worker as hidden QObject has got no parent because it must be moved to another thread

    // DatabaseInterface object m_worker is also a QObject, so in order to use functions from it cast it before
    dynamic_cast<QObject*>(m_worker)->moveToThread(&m_workerThread);
    m_workerThread.start();
}

KdbInterface::~KdbInterface()
{
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }
    delete m_worker;
    m_worker = NULL;
}

KdbInterface* KdbInterface::getInstance()
{
    Q_ASSERT(m_Instance);
    return m_Instance;
}
