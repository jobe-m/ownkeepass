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
#include "Keepass2DatabaseInterface.h"
#include "../KdbListModel.h"
#include "../KdbGroup.h"
#include "crypto/Crypto.h"

using namespace kpxPrivate;
using namespace kpxPublic;


Keepass2DatabaseInterface::Keepass2DatabaseInterface(QObject *parent)
    : QObject(parent),
      m_Database(NULL),
      m_setting_showUserNamePasswordsInListView(false),
      m_setting_sortAlphabeticallyInListView(true),
      m_rootGroupId(0)
{
    initDatabase();
}

Keepass2DatabaseInterface::~Keepass2DatabaseInterface()
{
    qDebug("Destructor Keepass2DatabaseInterface");
    delete m_Database;
}

void Keepass2DatabaseInterface::initDatabase()
{
    // init crypto algorithms
    if (!Crypto::init()) {
        // Fatal error while testing the cryptographic functions
// TODO add error handling
    }

}

void Keepass2DatabaseInterface::slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly)
{
}

void Keepass2DatabaseInterface::slot_closeDatabase()
{
}

void Keepass2DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
}

void Keepass2DatabaseInterface::slot_changePassKey(QString password, QString keyFile)
{
}

void Keepass2DatabaseInterface::slot_loadMasterGroups(bool registerListModel)
{
}

void Keepass2DatabaseInterface::slot_loadGroupsAndEntries(int groupId)
{
}

void Keepass2DatabaseInterface::slot_loadEntry(int entryId)
{
}

void Keepass2DatabaseInterface::slot_loadGroup(int groupId)
{
}

void Keepass2DatabaseInterface::slot_saveGroup(int groupId, QString title)
{
}

void Keepass2DatabaseInterface::slot_unregisterListModel(int modelId)
{
    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(modelId);
    m_entries_modelId.remove(modelId);
}

void Keepass2DatabaseInterface::slot_createNewGroup(QString title, quint32 iconId, int parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_saveEntry(int entryId,
                                        QString title,
                                        QString url,
                                        QString username,
                                        QString password,
                                        QString comment)
{
    Q_ASSERT(m_Database);
    Q_ASSERT(entryId);
}

void Keepass2DatabaseInterface::slot_createNewEntry(QString title,
                                             QString url,
                                             QString username,
                                             QString password,
                                             QString comment,
                                             int parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_deleteGroup(int groupId)
{
}

//void Keepass2DatabaseInterface::updateGrandParentGroupInListModel(IGroupHandle* parentGroup)
//{
//}

void Keepass2DatabaseInterface::slot_deleteEntry(int entryId)
{
}

void Keepass2DatabaseInterface::slot_moveEntry(int entryId, int newGroupId)
{
}

void Keepass2DatabaseInterface::slot_searchEntries(QString searchString, int rootGroupId)
{
}

//inline QString Keepass2DatabaseInterface::getUserAndPassword(IEntryHandle* entry)
//{
//}

void Keepass2DatabaseInterface::slot_changeKeyTransfRounds(int value)
{
}

void Keepass2DatabaseInterface::slot_changeCryptAlgorithm(int value)
{
}
