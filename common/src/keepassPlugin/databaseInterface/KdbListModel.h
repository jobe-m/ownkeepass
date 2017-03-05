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
#include "private/AbstractDatabaseInterface.h"
#include "ownKeepassGlobal.h"

using namespace ownKeepassPublic; // for using baseRole

namespace kpxPublic {

class KdbItem
{
public:
    KdbItem(QString name, QString iconUuid, QString subtitle, QString id, int itemType, int itemLevel)
        : m_name(name),
          m_iconUuid(iconUuid),
          m_subtitle(subtitle),
          m_id(id),
          m_itemType(itemType),
          m_itemLevel(itemLevel)
    {}
    virtual ~KdbItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    QString m_name;
    QString m_iconUuid;
    QString m_subtitle;
    QString m_id;
    int m_itemType;
    int m_itemLevel;
};

class KdbListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY isEmptyChanged)
    Q_PROPERTY(QString searchRootGroupId READ getSearchRootGroupId WRITE setSearchRootGroupId STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadMasterGroupsFromDatabase();
    Q_INVOKABLE void loadGroupListFromDatabase();
    Q_INVOKABLE void loadGroupsAndEntriesFromDatabase(QString groupId);
    Q_INVOKABLE void searchEntriesInKdbDatabase(QString searchString);
    Q_INVOKABLE void clearListModel();

public:
    KdbListModel(QObject *parent = 0);
    virtual ~KdbListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    void clear();
    bool isEmpty();
    QString getSearchRootGroupId() const { return m_searchRootGroupId; }
    void setSearchRootGroupId(const QString groupId) { m_searchRootGroupId = groupId; }

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return KdbItem::createRoles(); }

signals:
    // signals to database client
    void loadMasterGroups(bool registerListModel);
    void loadGroupsAndEntries(QString groupId);
    void unregisterFromDatabaseClient(QString modelId);
    void searchEntries(QString searchString, QString rootGroupId);

    // signals to QML
    void groupsAndEntriesLoaded(int result,
                                QString errorMsg);
    void masterGroupsLoaded(int result,
                            QString errorMsg);
    void searchEntriesCompleted(int result,
                                QString errorMsg);
    void modelDataChanged();

    // signals for properties
    void isEmptyChanged();

public slots:
    // signal from database client
    void slot_appendItemToListModel(QString title,
                                    QString iconUuid,
                                    QString subtitle,
                                    QString itemId,
                                    int itemType,
                                    int itemLevel,
                                    QString modelId);
    void slot_addItemToListModelSorted(QString title,
                                       QString iconUuid,
                                       QString subtitle,
                                       QString itemId,
                                       int itemType,
                                       int itemLevel,
                                       QString modelId);
    void slot_updateItemInListModel(QString title,
                                    QString iconUuid,
                                    QString subTitle,
                                    QString itemId,
                                    QString modelId);
    void slot_updateItemInListModelSorted(QString title,
                                          QString iconUuid,
                                          QString subTitle,
                                          QString itemId,
                                          QString modelId);
    void slot_deleteItem(QString itemId);
    void slot_disconnectFromDatabaseClient();

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    QList<KdbItem> m_items;
    // identifier for this list model
    QString m_modelId;
    // number of groups and items in the list view
    int m_numGroups;
    int m_numEntries;
    // indicator if this list model has registered at the global keepass database object
    bool m_registered;
    // identifier of the group from which a search for entries should be performed
    QString m_searchRootGroupId;
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
        return m_iconUuid;
    case baseRole + 2:
        return m_subtitle;
    case baseRole + 3:
        return m_id;
    case baseRole + 4:
        return m_itemType;
    case baseRole + 5:
        return m_itemLevel;
    }
    return QVariant();
}

inline QHash<int, QByteArray> KdbItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "name";
    roles[baseRole + 1] = "iconUuid";
    roles[baseRole + 2] = "subtitle";
    roles[baseRole + 3] = "id";
    roles[baseRole + 4] = "itemType";
    roles[baseRole + 5] = "itemLevel";
    return roles;
}

}

#endif // KDBLISTMODEL_H
