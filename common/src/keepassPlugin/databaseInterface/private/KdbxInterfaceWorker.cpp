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

#include <QDebug>

#include "KdbxInterfaceWorker.h"

#include "crypto/Crypto.h"

using namespace keepass2Format;
using namespace kpxPublic;

KdbxInterfaceWorker::KdbxInterfaceWorker(QObject *parent)
    : QObject(parent),
      m_kdbxDatabase(NULL),
      m_setting_showUserNamePasswordsInListView(false)
{
    initKdbDatabase();
}

KdbxInterfaceWorker::~KdbxInterfaceWorker()
{
    delete m_kdbxDatabase;
}

void KdbxInterfaceWorker::initKdbDatabase()
{
    if (!Crypto::init()) {
        // Fatal error while testing the cryptographic functions
// TODO add error handling
    }

}

void KdbxInterfaceWorker::slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly)
{
}

void KdbxInterfaceWorker::slot_closeDatabase()
{
}

void KdbxInterfaceWorker::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
}

void KdbxInterfaceWorker::slot_changePassKey(QString password, QString keyFile)
{
}

void KdbxInterfaceWorker::slot_loadMasterGroups()
{
}

void KdbxInterfaceWorker::slot_loadGroupsAndEntries(int groupId)
{
}

void KdbxInterfaceWorker::slot_loadEntry(int entryId)
{
}

void KdbxInterfaceWorker::slot_loadGroup(int groupId)
{
}

void KdbxInterfaceWorker::slot_saveGroup(int groupId, QString title)
{
}

void KdbxInterfaceWorker::slot_unregisterListModel(int modelId)
{
}

void KdbxInterfaceWorker::slot_createNewGroup(QString title, quint32 iconId, int parentGroupId)
{
}

void KdbxInterfaceWorker::slot_saveEntry(int entryId,
                                        QString title,
                                        QString url,
                                        QString username,
                                        QString password,
                                        QString comment)
{
}

void KdbxInterfaceWorker::slot_createNewEntry(QString title,
                                             QString url,
                                             QString username,
                                             QString password,
                                             QString comment,
                                             int parentGroupId)
{
}

void KdbxInterfaceWorker::slot_deleteGroup(int groupId)
{
}

void KdbxInterfaceWorker::slot_deleteEntry(int entryId)
{
}

void KdbxInterfaceWorker::slot_searchEntries(QString searchString, int rootGroupId)
{
}

void KdbxInterfaceWorker::slot_setting_showUserNamePasswordsInListView(bool value)
{
    m_setting_showUserNamePasswordsInListView = value;
}

void KdbxInterfaceWorker::slot_changeKeyTransfRounds(int value)
{
}

void KdbxInterfaceWorker::slot_changeCryptAlgorithm(int value)
{
}
