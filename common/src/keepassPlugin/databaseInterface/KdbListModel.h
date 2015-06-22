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

#ifndef KDBLISTMODEL_H
#define KDBLISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include "private/AbstractDatabaseInterface.h"


namespace kpxPublic {

static const int baseRole = Qt::UserRole + 1;

class KdbItem
{
public:
    KdbItem(QString name, QString subtitle, int id, int itemType, int itemLevel)
        : m_name(name),
          m_subtitle(subtitle),
          m_id(id),
          m_itemType(itemType),
          m_itemLevel(itemLevel)
    {}
    virtual ~KdbItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    QString m_name;
    QString m_subtitle;
    int m_id;
    int m_itemType;
    int m_itemLevel;
};

enum eDatabaseItemType {
    UNKNOWN = 0,
    GROUP,
    ENTRY,
};

class KdbListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(eDatabaseAccessResultWrapper)
    Q_ENUMS(eDatabaseItemTypeWrapper)

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

    enum eDatabaseItemTypeWrapper {
        UNKNOWN = AbstractDatabaseInterface::UNKNOWN,
        GROUP = AbstractDatabaseInterface::GROUP,
        ENTRY = AbstractDatabaseInterface::ENTRY
    };


    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY isEmptyChanged)
    Q_PROPERTY(int searchRootGroupId READ getSearchRootGroupId WRITE setSearchRootGroupId STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadMasterGroupsFromDatabase();
    Q_INVOKABLE void loadGroupListFromDatabase();
    Q_INVOKABLE void loadGroupsAndEntriesFromDatabase(int groupId);
    Q_INVOKABLE void searchEntriesInKdbDatabase(QString searchString);
    Q_INVOKABLE void clearListModel();

public:
    KdbListModel(QObject *parent = 0);
    virtual ~KdbListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    void clear();
    bool isEmpty();
    int getSearchRootGroupId() const { return m_searchRootGroupId; }
    void setSearchRootGroupId(int groupId) { m_searchRootGroupId = groupId; }

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return KdbItem::createRoles(); }

signals:
    // signals to database client
    void loadMasterGroups(bool registerListModel);
    void loadGroupsAndEntries(int groupId);
    void unregisterFromDatabaseClient(int modelId);
    void searchEntries(QString searchString, int rootGroupId);

    // signals to QML
    void groupsAndEntriesLoaded(int result);
    void masterGroupsLoaded(int result);
    void searchEntriesCompleted(int result);
    void modelDataChanged();

    // signals for properties
    void isEmptyChanged();

public slots:
    // signal from database client
    void slot_appendItemToListModel(QString title, QString subtitle, int itemId, int itemType, int itemLevel, int modelId);
    void slot_addItemToListModelSorted(QString title, QString subtitle, int itemId, int itemType, int itemLevel, int modelId);
    void slot_updateItemInListModel(QString title, QString subTitle, int itemId, int modelId);
    void slot_updateItemInListModelSorted(QString title, QString subTitle, int itemId, int modelId);
    void slot_deleteItem(int itemId);
    void slot_disconnectFromDatabaseClient();

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    QList<KdbItem> m_items;
    // identifier for this list model
    int m_modelId;
    // number of groups and items in the list view
    int m_numGroups;
    int m_numEntries;
    // indicator if this list model has registered at the global keepass database object
    bool m_registered;
    // identifier of the group from which a search for entries should be performed
    int m_searchRootGroupId;
    // identifies if this object is conntected to a loaded keepass database
    bool m_connected;
};

// inline implementations
inline QVariant KdbItem::get(const int role) const
{
    switch (role) {
    case baseRole:
        return m_name;
    case baseRole + 1:
        return m_subtitle;
    case baseRole + 2:
        return m_id;
    case baseRole + 3:
        return m_itemType;
    case baseRole + 4:
        return m_itemLevel;
    }
    return QVariant();
}

inline QHash<int, QByteArray> KdbItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "name";
    roles[baseRole + 1] = "subtitle";
    roles[baseRole + 2] = "id";
    roles[baseRole + 3] = "itemType";
    roles[baseRole + 4] = "itemLevel";
    return roles;
}

}

#endif // KDBLISTMODEL_H
