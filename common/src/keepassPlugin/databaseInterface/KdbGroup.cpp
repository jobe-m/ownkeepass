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

#include <QDebug>
#include "ownKeepassGlobal.h"
#include "KdbGroup.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

KdbGroup::KdbGroup(QObject *parent)
    : QObject(parent),
      m_groupId(""),
      m_connected(false),
      m_new_group_triggered(false)
{}

bool KdbGroup::connectToDatabaseClient()
{
    // check if database backend is already initialized and available
    if (DatabaseClient::getInstance()->getInterface() == NULL) {
        return false;
    }
    // if OK then connect signals to backend
    bool ret = connect(this,
                       SIGNAL(loadGroupFromKdbDatabase(QString)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_loadGroup(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(groupLoaded(int, QString, QString,int,QString)),
                  this,
                  SLOT(slot_groupDataLoaded(int,QString,QString,int,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(saveGroupToKdbDatabase(QString, QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_saveGroup(QString, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(groupSaved(int,QString)),
                  this,
                  SLOT(slot_groupDataSaved(int,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(createNewGroupInKdbDatabase(QString,quint32,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_createNewGroup(QString,quint32,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(newGroupCreated(int, QString)),
                  this,
                  SLOT(slot_newGroupCreated(int, QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(deleteGroupFromKdbDatabase(QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_deleteGroup(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(groupDeleted(int,QString)),
                  this,
                  SLOT(slot_groupDeleted(int,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(disconnectAllClients()),
                  this,
                  SLOT(slot_disconnectFromDatabaseClient()));
    Q_ASSERT(ret);

    m_connected = true;
    return true;
}

void KdbGroup::disconnectFromDatabaseClient()
{
    qDebug() << "disconnect KdbGroup";

    // disconnect all signals to backend
    // this is not needed ?
//    bool ret = disconnect(this, 0, 0, 0);
//    Q_ASSERT(ret);

    m_connected = false;
    m_groupId = "";
    m_new_group_triggered = false;
}

void KdbGroup::loadGroupData()
{
    Q_ASSERT(m_groupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit groupDataLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "", 0 , "");
    } else {
        // trigger loading from database client
        emit loadGroupFromKdbDatabase(m_groupId);
    }
}

void KdbGroup::saveGroupData(QString title)
{
    Q_ASSERT(m_groupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit groupDataSaved(DatabaseAccessResult::RE_DB_NOT_OPENED);
    } else {
        // trigger loading from database client
        emit saveGroupToKdbDatabase(m_groupId, title);
    }
}

void KdbGroup::createNewGroup(QString title, QString parentGroupId)
{
    Q_ASSERT(parentGroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit newGroupCreated(DatabaseAccessResult::RE_DB_NOT_OPENED);
    } else {
        // trigger creation of new entry in database client
        m_new_group_triggered = true;
        quint32 iconId = 1;
        emit createNewGroupInKdbDatabase(title, iconId, parentGroupId);
    }
}


void KdbGroup::deleteGroup()
{
    Q_ASSERT(m_groupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit groupDeleted(DatabaseAccessResult::RE_DB_NOT_OPENED);
    } else {
        // trigger deletion of entry in database client
        emit deleteGroupFromKdbDatabase(m_groupId);
    }
}

void KdbGroup::moveGroup(QString newParentGroupId)
{
    Q_ASSERT(m_groupId != "");
    Q_ASSERT(newParentGroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit groupMoved(DatabaseAccessResult::RE_DB_NOT_OPENED);
    } else {
        // trigger moving of entry in database client
        emit moveGroupInKdbDatabase(m_groupId, newParentGroupId);
    }
}

void KdbGroup::slot_groupDataLoaded(int result, QString groupId, QString title, int iconId, QString customIconUuid)
{
    // forward signal to QML only if the signal is for us
    if (groupId.compare(m_groupId) == 0) {
        emit groupDataLoaded(result, title, iconId, customIconUuid);
    }
}

void KdbGroup::slot_groupDataSaved(int result, QString groupId)
{
    // forward signal to QML only if the signal is for us
    if (groupId.compare(m_groupId) == 0) {
        emit groupDataSaved(result);
    }
}

void KdbGroup::slot_newGroupCreated(int result, QString groupId)
{
    if (m_new_group_triggered) {
        if (result == DatabaseAccessResult::RE_OK) {
            m_groupId = groupId;
        }
        m_new_group_triggered = false;
        // forward signal to QML
        emit newGroupCreated(result);
    }
}

void KdbGroup::slot_groupDeleted(int result, QString groupId)
{
    // forward signal to QML only if the signal is for us
    if (groupId.compare(m_groupId) == 0) {
        emit groupDeleted(result);
        m_groupId = "";
    }
}

void KdbGroup::slot_groupMoved(int result, QString groupId)
{
    // forward signal to QML only if the signal is for us
    if (groupId.compare(m_groupId) == 0) {
        emit groupMoved(result);
    }
}

void KdbGroup::slot_disconnectFromDatabaseClient()
{
    // database client has requested to disconnect so do accordingly if we have connected at all
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}
