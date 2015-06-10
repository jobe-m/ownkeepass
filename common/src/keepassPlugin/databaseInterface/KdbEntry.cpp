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

#include "KdbEntry.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;

KdbEntry::KdbEntry(QObject *parent)
    : QObject(parent),
      m_entryId(0),
      m_connected(false),
      m_new_entry_triggered(false)
{}

void KdbEntry::connectToDatabaseClient()
{
    // connect signals to backend
    bool ret = connect(this, SIGNAL(loadEntryFromKdbDatabase(int)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_loadEntry(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)),
                  this, SLOT(slot_entryDataLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(saveEntryToKdbDatabase(int,QString,QString,QString,QString,QString)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_saveEntry(int,QString,QString,QString,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewEntryInKdbDatabase(QString,QString,QString,QString,QString,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_createNewEntry(QString,QString,QString,QString,QString,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entrySaved(int)),
                  this, SIGNAL(entryDataSaved(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryDeleted(int)),
                  this, SIGNAL(entryDeleted(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(deleteEntryFromKdbDatabase(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_deleteEntry(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(newEntryCreated(int, int)),
                  this, SLOT(slot_newEntryCreated(int, int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(moveEntryInKdbDatabase(int,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_moveEntry(int,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryMoved(int)),
                  this, SIGNAL(entryMoved(int)));
    Q_ASSERT(ret);

    m_connected = true;
}

void KdbEntry::disconnectFromDatabaseClient()
{
    // disconnect signals to backend
    bool ret = disconnect(this, SIGNAL(loadEntryFromKdbDatabase(int)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_loadEntry(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)),
                  this, SLOT(slot_entryDataLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(saveEntryToKdbDatabase(int,QString,QString,QString,QString,QString)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_saveEntry(int,QString,QString,QString,QString,QString)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(createNewEntryInKdbDatabase(QString,QString,QString,QString,QString,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_createNewEntry(QString,QString,QString,QString,QString,int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entrySaved(int)),
                  this, SIGNAL(entryDataSaved(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryDeleted(int)),
                  this, SIGNAL(entryDeleted(int)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(deleteEntryFromKdbDatabase(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_deleteEntry(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(newEntryCreated(int, int)),
                  this, SLOT(slot_newEntryCreated(int, int)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(moveEntryInKdbDatabase(int,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_moveEntry(int,int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(entryMoved(int)),
                  this, SIGNAL(entryMoved(int)));
    Q_ASSERT(ret);

    m_connected = false;
}

void KdbEntry::loadEntryData()
{
    Q_ASSERT(m_entryId != 0);
    if (!m_connected) {
        connectToDatabaseClient();
    }
    emit loadEntryFromKdbDatabase(m_entryId);
}

void KdbEntry::saveEntryData(QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment)
{
    Q_ASSERT(m_entryId != 0);
    if (!m_connected) {
        connectToDatabaseClient();
    }
    emit saveEntryToKdbDatabase(m_entryId, title, url, username, password, comment);
}

void KdbEntry::createNewEntry(QString title,
                              QString url,
                              QString username,
                              QString password,
                              QString comment,
                              int parentgroupId)
{
    Q_ASSERT(parentgroupId != 0);
    if (!m_connected) {
        connectToDatabaseClient();
    }
    m_new_entry_triggered = true;
    emit createNewEntryInKdbDatabase(title, url, username, password, comment, parentgroupId);
}

void KdbEntry::deleteEntry()
{
    Q_ASSERT(m_entryId != 0);
    if (!m_connected) {
        connectToDatabaseClient();
    }
    emit deleteEntryFromKdbDatabase(m_entryId);
}

void KdbEntry::moveEntry(int newGroupId)
{
    Q_ASSERT(m_entryId != 0);
    Q_ASSERT(newGroupId != 0);
    if (!m_connected) {
        connectToDatabaseClient();
    }
    emit moveEntryInKdbDatabase(m_entryId, newGroupId);
}

void KdbEntry::slot_entryDataLoaded(int entryId,
                                    QString title,
                                    QString url,
                                    QString username,
                                    QString password,
                                    QString comment,
                                    QString binaryDesc,
                                    QString creation,
                                    QString lastMod,
                                    QString lastAccess,
                                    QString expire,
                                    quint32 binarySize,
                                    QString friendlySize)
{
    // forward signal to QML only if the signal is for us
    if (entryId == m_entryId) {
        emit entryDataLoaded(title, url, username, password, comment,
                             binaryDesc, creation, lastMod, lastAccess,
                             expire, binarySize, friendlySize);
    }
}

void KdbEntry::slot_newEntryCreated(int result, int newEntryId)
{
    if (m_new_entry_triggered) {
        if (result == RE_OK) {
            m_entryId = newEntryId;
        }
        m_new_entry_triggered = false;
        // forward signal to QML
        emit newEntryCreated(result, newEntryId);
    }
}

void KdbEntry::slot_disconnectFromDatabaseClient()
{
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}
