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

#ifndef KDBGROUP_H
#define KDBGROUP_H

#include <QObject>
#include "private/AbstractDatabaseInterface.h"

namespace kpxPublic {

class KdbGroup : public QObject, public DatabaseDefines
{
    Q_OBJECT
    Q_INTERFACES(DatabaseDefines)

public:
    Q_ENUMS(eDatabaseAccessResult)

public:
    Q_PROPERTY(int groupId READ getGroupId WRITE setGroupId STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadGroupData();
    Q_INVOKABLE void createNewGroup(QString title, int parentGroupId);
    Q_INVOKABLE void saveGroupData(QString title);
    Q_INVOKABLE void deleteGroup();
    Q_INVOKABLE void moveGroup(int newParentGroupId);

signals:
    // signals to QML
    void groupDataLoaded(int result, QString title);
    void groupDataSaved(int result);
    void newGroupCreated(int result, int newParentGroupId);
    void groupDeleted(int result);
    void groupMoved(int result);

    // signals to database client
    void loadGroupFromKdbDatabase(int groupId);
    void saveGroupToKdbDatabase(int groupId, QString title);
    void createNewGroupInKdbDatabase(QString title, quint32 iconId, int parentGroupId);
    void deleteGroupFromKdbDatabase(int groupId);
    void moveGroupInKdbDatabase(int groupId, int newGroupId);

public slots:
    // signals from database client
    void slot_groupDataLoaded(int result, int groupId, QString title);
    void slot_groupDataSaved(int result, int groupId);
    void slot_newGroupCreated(int result, int groupId);
    void slot_groupDeleted(int result, int groupId);
    void slot_groupMoved(int result, int groupId);
    void slot_disconnectFromDatabaseClient();

public:
    KdbGroup(QObject *parent = 0);
    virtual ~KdbGroup() {}

    int getGroupId() const { return m_groupId; }
    void setGroupId(const int value) { m_groupId = value; }

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    int m_groupId;
    bool m_connected;
    bool m_new_group_triggered;
};

}
#endif // KDBGROUP_H
