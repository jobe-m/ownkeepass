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
using namespace kpxPrivate;

KdbEntry::KdbEntry(QObject *parent)
    : QObject(parent)
{
    // connect signals to backend
    Q_ASSERT(connect(this, SIGNAL(loadEntryFromKdbDatabase(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_loadEntry(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(entryLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString)),
                     this, SLOT(slot_entryDataLoaded(int,QString,QString,QString,QString,QString,QString,QString,QString,QString,QString,quint32,QString))));
    Q_ASSERT(connect(this, SIGNAL(saveEntrytoKdbDatabase(int,QString,QString,QString,QString,QString)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_saveEntry(int,QString,QString,QString,QString,QString))));
    Q_ASSERT(connect(this, SIGNAL(createNewEntryInKdbDatabase(QString,QString,QString,QString,QString,int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_createNewEntry(QString,QString,QString,QString,QString,int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(entrySaved(int)),
                     this, SIGNAL(entryDataSaved(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(entryDeleted(int)),
                     this, SIGNAL(entryDeleted(int))));
    Q_ASSERT(connect(this, SIGNAL(deleteEntryFromKdbDatabase(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_deleteEntry(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(newEntryCreated(int, int)),
                     this, SIGNAL(newEntryCreated(int, int))));
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
