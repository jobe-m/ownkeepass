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

#include "database/Kdb3Database.h"

namespace kpxPublic {

static const int baseRole = Qt::UserRole + 1;

class KdbItem
{
public:
    KdbItem(QString name, QString subtitle, int id, int itemType)
        : m_name(name),
          m_subtitle(subtitle),
          m_id(id),
          m_itemType(itemType)
    {}
    virtual ~KdbItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    QString m_name;
    QString m_subtitle;
    int m_id;
    int m_itemType;
};

class KdbListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_ENUMS(eItemType)
    enum eItemType {
        UNKNOWN = 0,
        GROUP = 1,
        ENTRY = 2
    };

    Q_ENUMS(eResult)
    enum eResult {
        RE_OK = 0,                  // no error
        RE_LOAD_ERROR,              // error loading ...

        RE_LAST
    };

    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY modelDataChanged)
    Q_PROPERTY(int searchRootGroupId READ getSearchRootGroupId WRITE setSearchRootGroupId STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadMasterGroupsFromDatabase();
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
    // signals to KdbInterface global object
    void loadMasterGroups();
    void loadGroupsAndEntries(int groupId);
    void unregisterFromKdbInterface(int modelId);
    void searchEntries(QString searchString, int rootGroupId);

    // signals to QML
    void groupsAndEntriesLoaded(int result);
    void masterGroupsLoaded(int result);
    void searchEntriesCompleted(int result);

    // signal for property
    void modelDataChanged();

public slots:
    // signal from KdbInterfaceWorker
    void slot_addItemToListModel(QString title, QString subtitle, int id, int itemType, int modelId);
    void slot_updateItemInListModel(QString title, QString subTitle, int groupId, int modelId);
    void slot_deleteItem(int itemId);

private:
    QList<KdbItem> m_items;
    int m_modelId;
    // indicator if this list model has registered at the global keepass database object
    bool m_registered;
    // identifier of the group from which a search for entries should be performed
    int m_searchRootGroupId;
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
    return roles;
}

}

#endif // KDBLISTMODEL_H
