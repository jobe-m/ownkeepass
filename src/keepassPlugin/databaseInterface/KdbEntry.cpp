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
#include "private/KdbInterface.h"

using namespace kpxPublic;

// reference to global interface of Keepass database
extern kpxPrivate::KdbInterface* databaseInterface;

KdbEntry::KdbEntry(QObject *parent)
    : QObject(parent)
{
    // connect signals to backend
    Q_ASSERT(databaseInterface);
    bool ret = connect(this, SIGNAL(loadEntryFromKdbDatabase(int)),
                       databaseInterface->worker(), SLOT(slot_loadEntry(int)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(entryLoaded(QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)),
                  this, SIGNAL(entryDataLoaded(QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(saveEntrytoKdbDatabase(int,QString,QString,QString,QString,QString)),
                  databaseInterface->worker(), SLOT(slot_saveEntry(int,QString,QString,QString,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewEntryInKdbDatabase(QString,QString,QString,QString,QString,int)),
                  databaseInterface->worker(), SLOT(slot_createNewEntry(QString,QString,QString,QString,QString,int)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(entrySaved(int)),
                  this, SIGNAL(entryDataSaved(int)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(entryDeleted(int)),
                  this, SIGNAL(entryDeleted(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(deleteEntryFromKdbDatabase(int)),
                  databaseInterface->worker(), SLOT(slot_deleteEntry(int)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(newEntryCreated(int, int)),
                  this, SIGNAL(newEntryCreated(int, int)));
    Q_ASSERT(ret);
}

void KdbEntry::loadEntryData()
{
    Q_ASSERT(m_entryId != 0);
    emit loadEntryFromKdbDatabase(m_entryId);
}

void KdbEntry::saveEntryData(QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment)
{
    Q_ASSERT(m_entryId != 0);
    emit saveEntrytoKdbDatabase(m_entryId, title, url, username, password, comment);
}

void KdbEntry::createNewEntry(QString title,
                              QString url,
                              QString username,
                              QString password,
                              QString comment,
                              int parentgroupId)
{
    emit createNewEntryInKdbDatabase(title, url, username, password, comment, parentgroupId);
}

int KdbEntry::getEntryId() const
{
    return m_entryId;
}

void KdbEntry::setEntryId(int entryId)
{
    m_entryId = entryId;
}

void KdbEntry::deleteEntry()
{
    emit deleteEntryFromKdbDatabase(m_entryId);
}
