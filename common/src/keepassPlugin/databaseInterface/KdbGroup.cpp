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

#include "KdbGroup.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;

KdbGroup::KdbGroup(QObject *parent)
    : QObject(parent)
{
/*    // connect signals to backend
    bool ret = connect(this, SIGNAL(loadGroupFromKdbDatabase(int)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_loadGroup(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(saveGroupToKdbDatabase(int, QString)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_saveGroup(int, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(groupLoaded(QString)),
                  this, SIGNAL(groupDataLoaded(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(groupSaved(int)),
                  this, SIGNAL(groupDataSaved(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewGroupInKdbDatabase(QString,quint32,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_createNewGroup(QString,quint32,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(newGroupCreated(int, int)),
                  this, SIGNAL(newGroupCreated(int, int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(groupDeleted(int)),
                  this, SIGNAL(groupDeleted(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(deleteGroupFromKdbDatabase(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_deleteGroup(int)));
    Q_ASSERT(ret);
*/
}

void KdbGroup::loadGroupData()
{
    Q_ASSERT(m_groupId != 0);
    emit loadGroupFromKdbDatabase(m_groupId);
}

void KdbGroup::saveGroupData(QString title)
{
    Q_ASSERT(m_groupId != 0);
    emit saveGroupToKdbDatabase(m_groupId, title);
}

void KdbGroup::createNewGroup(QString title, int parentGroupId)
{
    // set iconId to 0 (quint32 iconId)
    emit createNewGroupInKdbDatabase(title, 1, parentGroupId);
}

int KdbGroup::getGroupId()
{
    return m_groupId;
}

void KdbGroup::setGroupId(int groupId)
{
    m_groupId = groupId;
}


void KdbGroup::deleteGroup()
{
    emit deleteGroupFromKdbDatabase(m_groupId);
}
