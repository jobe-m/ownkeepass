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

#include "QDebug"
#include "ownKeepassGlobal.h"
#include "KdbEntry.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

KdbEntry::KdbEntry(QObject *parent)
    : QObject(parent),
      m_entryId(""),
      m_connected(false),
      m_new_entry_triggered(false)
{}

bool KdbEntry::connectToDatabaseClient()
{
    // check if database backend is already initialized and available
    if (DatabaseClient::getInstance()->getInterface() == NULL) {
        return false;
    }
    // if OK then connect signals to backend
    bool ret = connect(this,
                       SIGNAL(loadEntryFromKdbDatabase(QString)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_loadEntry(QString)));
    Q_UNUSED(ret);
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryLoaded(int,QString,QString,QList<QString>,QList<QString>,QString)),
                  this,
                  SLOT(slot_entryDataLoaded(int,QString,QString,QList<QString>,QList<QString>,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(saveEntryToKdbDatabase(QString,QList<QString>,QList<QString>,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_saveEntry(QString,QList<QString>,QList<QString>,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entrySaved(int,QString,QString)),
                  this,
                  SLOT(slot_entryDataSaved(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(createNewEntryInKdbDatabase(QList<QString>,QList<QString>,QString,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_createNewEntry(QList<QString>,QList<QString>,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(newEntryCreated(int,QString,QString)),
                  this,
                  SLOT(slot_newEntryCreated(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(deleteEntryFromKdbDatabase(QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_deleteEntry(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryDeleted(int,QString,QString)),
                  this,
                  SLOT(slot_entryDeleted(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(moveEntryInKdbDatabase(QString,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_moveEntry(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryMoved(int,QString,QString)),
                  this,
                  SLOT(slot_entryMoved(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(disconnectAllClients()),
                  this,
                  SLOT(slot_disconnectFromDatabaseClient()));
    Q_ASSERT(ret);

    m_connected = true;
    return true;
}

void KdbEntry::disconnectFromDatabaseClient()
{

    // disconnect all signals to backend
    // this is not needed ?
//    bool ret = disconnect(this, 0, 0, 0);
//    Q_ASSERT(ret);

    m_connected = false;
    m_entryId = "";
    m_new_entry_triggered = false;
}

KdbEntry::~KdbEntry()
{}

void KdbEntry::loadEntryData()
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        QList<QString> emptyList;
        emit entryDataLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "", emptyList, emptyList, "");
    } else {
        // trigger loading from database client
        emit loadEntryFromKdbDatabase(m_entryId);
    }
}

void KdbEntry::saveEntryData(QList<QString> keys,
                             QList<QString> values,
                             QString iconUuid)
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryDataSaved(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger saving to database client
        emit saveEntryToKdbDatabase(m_entryId, keys, values, iconUuid);
    }
}

void KdbEntry::createNewEntry(QList<QString> keys,
                              QList<QString> values,
                              QString parentgroupId,
                              QString iconUuid)
{
    Q_ASSERT(parentgroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit newEntryCreated(DatabaseAccessResult::RE_DB_NOT_OPENED, "", 0);
    } else {
        // trigger creation of new entry in database client
        m_new_entry_triggered = true;
        emit createNewEntryInKdbDatabase(keys, values, parentgroupId, iconUuid);
    }
}

void KdbEntry::deleteEntry()
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryDeleted(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger deletion of entry in database client
        emit deleteEntryFromKdbDatabase(m_entryId);
    }
}

void KdbEntry::moveEntry(QString newGroupId)
{
    Q_ASSERT(m_entryId != "");
    Q_ASSERT(newGroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryMoved(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger moving of entry in database client
        emit moveEntryInKdbDatabase(m_entryId, newGroupId);
    }
}

void KdbEntry::slot_entryDataLoaded(int result,
                                    QString errorMsg,
                                    QString entryId,
                                    QList<QString> keys,
                                    QList<QString> values,
                                    QString iconUuid)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryDataLoaded(result, errorMsg, keys, values, iconUuid);
    }
}

void KdbEntry::slot_entryDataSaved(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryDataSaved(result, errorMsg);
    }
}

void KdbEntry::slot_newEntryCreated(int result, QString errorMsg, QString entryId)
{
    if (m_new_entry_triggered) {
        if (result == DatabaseAccessResult::RE_OK) {
            m_entryId = entryId;
        }
        m_new_entry_triggered = false;
        // forward signal to QML
        emit newEntryCreated(result, errorMsg, entryId);
    }
}

void KdbEntry::slot_entryDeleted(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryDeleted(result, errorMsg);
        m_entryId = "";
    }
}

void KdbEntry::slot_entryMoved(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryMoved(result, errorMsg);
    }
}

void KdbEntry::slot_disconnectFromDatabaseClient()
{
    // database client has requested to disconnect so do accordingly if we have connected at all
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}
