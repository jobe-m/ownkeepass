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

class KdbGroup : public QObject
{
    Q_OBJECT
    Q_ENUMS(eDatabaseAccessResultWrapper)

public:
    enum eDatabaseAccessResultWrapper {
        RE_OK = AbstractDatabaseInterface::RE_OK,                                                           // no error
        RE_DB_LOAD_ERROR = AbstractDatabaseInterface::RE_DB_LOAD_ERROR,                                     // error loading data from database
        RE_DB_SAVE_ERROR = AbstractDatabaseInterface::RE_DB_SAVE_ERROR,                                     // error saving data into database
        RE_DB_NOT_OPENED = AbstractDatabaseInterface::RE_DB_NOT_OPENED,                                     // database is not opened
        RE_DB_OPEN = AbstractDatabaseInterface::RE_DB_OPEN,                                                 // other database is currently open, close it first
        RE_DB_ALREADY_CLOSED = AbstractDatabaseInterface::RE_DB_ALREADY_CLOSED,                             // database already closed, no harm
        RE_DB_CLOSE_FAILED = AbstractDatabaseInterface::RE_DB_CLOSE_FAILED,                                 // database closing failed
        RE_DB_FILE_ERROR = AbstractDatabaseInterface::RE_DB_FILE_ERROR,                                     // file path error for new database
        RE_DB_SETKEY_ERROR = AbstractDatabaseInterface::RE_DB_SETKEY_ERROR,                                 // error setting key (consisting of password and/or keyfile
        RE_DB_SETPW_ERROR = AbstractDatabaseInterface::RE_DB_SETPW_ERROR,                                   // error setting password for database
        RE_DB_SETKEYFILE_ERROR = AbstractDatabaseInterface::RE_DB_SETKEYFILE_ERROR,                         // error setting key file for database
        RE_DB_CREATE_BACKUPGROUP_ERROR = AbstractDatabaseInterface::RE_DB_CREATE_BACKUPGROUP_ERROR,         // error creating backup group
        RE_PRECHECK_DB_PATH_ERROR = AbstractDatabaseInterface::RE_PRECHECK_DB_PATH_ERROR,                   // database file does not exists on precheck
        RE_PRECHECK_KEY_FILE_PATH_ERROR = AbstractDatabaseInterface::RE_PRECHECK_KEY_FILE_PATH_ERROR,       // key file does not exists on precheck
        RE_PRECHECK_DB_PATH_CREATION_ERROR = AbstractDatabaseInterface::RE_PRECHECK_DB_PATH_CREATION_ERROR, // path to database file could not be created

        RE_LAST = AbstractDatabaseInterface::RE_LAST
    };

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
