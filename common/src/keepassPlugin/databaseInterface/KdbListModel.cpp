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
#include "KdbListModel.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

KdbListModel::KdbListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_modelId(""),
      m_numGroups(0),
      m_numEntries(0),
      m_registered(false),
      m_searchRootGroupId(""),
      m_connected(false),
      m_level_0_count(0)
{}

bool KdbListModel::connectToDatabaseClient()
{
    // check if database backend is already initialized and available
    if (DatabaseClient::getInstance()->getInterface() == NULL) {
        return false;
    }
    // connect signals to backend
    bool ret = connect(this,
                       SIGNAL(loadMasterGroups(bool)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_loadMasterGroups(bool)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(masterGroupsLoaded(int, QString)),
                  this,
                  SIGNAL(masterGroupsLoaded(int, QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(loadGroupsAndEntries(QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_loadGroupsAndEntries(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(groupsAndEntriesLoaded(int, QString)),
                  this,
                  SIGNAL(groupsAndEntriesLoaded(int, QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(searchEntries(QString, QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_searchEntries(QString, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(searchEntriesCompleted(int, QString)),
                  this,
                  SIGNAL(searchEntriesCompleted(int, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(appendItemToListModel(QString, QString, QString, QString, int, int, QString)),
                  this,
                  SLOT(slot_appendItemToListModel(QString, QString, QString, QString, int, int, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(addItemToListModelSorted(QString, QString, QString, QString, int, int, QString)),
                  this,
                  SLOT(slot_addItemToListModelSorted(QString, QString, QString, QString, int, int, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(updateItemInListModel(QString, QString, QString, QString, QString)),
                  this,
                  SLOT(slot_updateItemInListModel(QString, QString, QString, QString, QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(updateItemInListModelSorted(QString, QString, QString, QString, QString)),
                  this,
                  SLOT(slot_updateItemInListModelSorted(QString, QString, QString, QString, QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(unregisterFromDatabaseClient(QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_unregisterListModel(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(deleteItemInListModel(QString)),
                  this,
                  SLOT(slot_deleteItem(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(disconnectAllClients()),
                  this,
                  SLOT(slot_disconnectFromDatabaseClient()));
    Q_ASSERT(ret);

    m_connected = true;
    return true;
}

void KdbListModel::disconnectFromDatabaseClient()
{
    // disconnect all signals to backend
    // this is not needed ?
//    bool ret = disconnect(this, 0, 0, 0);
//    Q_ASSERT(ret);

    m_connected = false;
    m_registered = false;
    m_modelId = "";
}

KdbListModel::~KdbListModel()
{
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
    }
}

void KdbListModel::loadGroupListFromDatabase()
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit masterGroupsLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        if (m_registered) {
            emit unregisterFromDatabaseClient(m_modelId);
            m_registered = false;
        }
        // this list model is only used in a dialog and is thrown away afterwards, so it does not need to be registered
        // i.e. changes on the database which are normally reflected to list models are not needed here
        m_registered = true;
        m_modelId = "ffffffff";
        // send signal to global interface of keepass database to get master groups
// TODO clanup loadMasterGroups... registerListModel is not needed anymore...
        emit loadMasterGroups(false);
    }
}

void KdbListModel::loadGroupsAndEntriesFromDatabase(QString groupId)
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        if (m_registered) {
            emit unregisterFromDatabaseClient(m_modelId);
            m_registered = false;
        }
        // send signal to global interface of keepass database to get entries and subgroups
        emit loadGroupsAndEntries(groupId);
    }
}

void KdbListModel::searchEntriesInKdbDatabase(QString searchString)
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit searchEntriesCompleted(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        if (m_registered) {
            emit unregisterFromDatabaseClient(m_modelId);
            m_registered = false;
        }
        // list model for searching is 0xfffffffe per default, so set it here already
        m_modelId = "fffffffe";
        m_registered = true;

        // send signal to backend to start search in database
        emit searchEntries(searchString, m_searchRootGroupId);
    }
}

int KdbListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_items.count();
}

bool KdbListModel::isEmpty()
{
    return m_items.isEmpty();
}

QVariant KdbListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_items.count())
        return QVariant();

    return m_items[index.row()].get(role);
}

void KdbListModel::clear()
{
    beginResetModel();
    m_items.clear();
    endResetModel();
    m_numGroups = 0;
    m_numEntries = 0;

    // signal to QML and for property update
    emit modelDataChanged();
    emit isEmptyChanged();
}

void KdbListModel::clearListModel()
{
    clear();
}

void KdbListModel::slot_appendItemToListModel(QString title, QString iconUuid, QString subTitle, QString itemId, int itemType, int itemLevel, QString modelId)
{
    if (!m_registered) {
        m_modelId = modelId;
        m_registered = true;
    }
    // only append if this item is for us
    if (m_modelId.compare(modelId) == 0) {
        // Increase level 0 count if item has level 0
        if (0 == itemLevel) {
            ++m_level_0_count;
        }
        KdbItem item(title, iconUuid, subTitle, itemId, itemType, itemLevel);
        if (itemType == DatabaseItemType::ENTRY) {
            // append new entry to end of list
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_items << item;
            endInsertRows();
            m_numEntries++;
        } else {
            // insert new group after last group in list
            int i = 0;
            while (i < m_items.count() && m_items[i].m_itemType == DatabaseItemType::GROUP) { ++i; }
            beginInsertRows(QModelIndex(), i, i);
            m_items.insert(i, item);
            endInsertRows();
            m_numGroups++;
        }
        // emit isEmptyChanged signal if list view was empty before
        if (m_items.length() == 1) {
            emit isEmptyChanged();
        }
        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}

void KdbListModel::slot_addItemToListModelSorted(QString title, QString iconUuid, QString subTitle, QString itemId, int itemType, int itemLevel, QString modelId)
{
    if (!m_registered) {
        m_modelId = modelId;
        m_registered = true;
    }
    // only append if this item is for us
    if (m_modelId.compare(modelId) == 0) {
        // Increase level 0 count if item has level 0
        if (0 == itemLevel) {
            ++m_level_0_count;
        }
        KdbItem item(title, iconUuid, subTitle, itemId, itemType, itemLevel);
        // compare and insert alphabetically into list model depending if it is an password entry or group
        // groups are put at the beginning of the list view before entries
        int i = 0;
        int max = 0;
        if (itemType == DatabaseItemType::ENTRY) {
            i = m_numGroups;
            max = m_items.length();
            ++m_numEntries;
//            qDebug() << "insert entry i: " << i << " max: " << max << " numEntries: " << m_numEntries << "name: " << title;
        } else {
            i = 0;
            max = m_numGroups;
            ++m_numGroups;
//            qDebug() << "insert group i: " << i << " max: " << max << " numGroups: " << m_numGroups << "name: " << title;
        }
        // now find the position in the list model to insert the item sorted by name
        // take itemLevel into account so that group names are only compared within the same level
        while (i < max && (itemLevel != m_items[i].m_itemLevel || m_items[i].m_name.toLower().compare(title.toLower()) < 0)) {
//        qDebug() << "sort item " << i << " m_name: " << m_items[i].m_name << " =?= " << title << " result: " << m_items[i].m_name.toLower().compare(title.toLower());
            ++i;
        }
        beginInsertRows(QModelIndex(), i, i);
        m_items.insert(i, item);
        endInsertRows();
        // emit isEmptyChanged signal if list view was empty before
        if (m_items.length() == 1) {
            emit isEmptyChanged();
        }
        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}

/******************************************************************************
\brief KdbListModel::slot_updateItemInListModel

This function updates a single groups item in the list model data.

\param title The detail that should be changed in the item.
\param groupId Identifier for the item inside of the list model.
\param modelId Identifier for list model, which needs to be changed.
******************************************************************************/
void KdbListModel::slot_updateItemInListModel(QString title, QString iconUuid, QString subTitle, QString itemId, QString modelId)
{
    // check if we need to do anything
    if (m_modelId.compare(modelId) == 0) {
        // look at each item in list model
        for (int i = 0; i < m_items.count(); i++) {
            if (m_items[i].m_id == itemId) {
//                qDebug() << "adding in non sorted mode: " << title;
                // list view has custom sorting so position of item will stay the same and item just needs an update
                beginResetModel();
                // set new title name, icon uuid and sub title
                m_items[i].m_name = title;
                m_items[i].m_iconUuid = iconUuid;
                m_items[i].m_subTitle = subTitle;
                endResetModel();
            }
        }
        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}

void KdbListModel::slot_updateItemInListModelSorted(QString title, QString iconUuid, QString subTitle, QString itemId, QString modelId)
{
    // check if we need to do anything
    if (m_modelId.compare(modelId) == 0) {
        // look at each item in list model
        for (int i = 0; i < m_items.count(); ++i) {
            if (m_items[i].m_id == itemId) {
                // list view is sorted alphabetically so a new title might change the position of the item
                // remove and insert item again, this makes sure that the new item will appear
                // in the correct position in the alphabetically sorted list view
                int itemType = m_items[i].m_itemType;
                int itemLevel = m_items[i].m_itemLevel;
                beginResetModel();
                // check item type and decrease appropriate item number counter
                if (DatabaseItemType::ENTRY == itemType) {
                    m_numEntries--;
                } else {
                    m_numGroups--;
                }
                m_items.removeAt(i);
                KdbItem item(title, iconUuid, subTitle, itemId, itemType, itemLevel);
                // compare and insert alphabetically into list model depending if it is an password entry or group
                // groups are put at the beginning of the list view before entries
                int i = 0;
                int max = 0;
                if (DatabaseItemType::ENTRY == itemType) {
                    i = m_numGroups;
                    max = m_items.length();
                    ++m_numEntries;
                } else {
                    i = 0;
                    max = m_numGroups;
                    ++m_numGroups;
                }
                // now find the position in the list model to insert the item sorted by name
                // take itemLevel into account so that group names are only compared within the same level
                while (i < max && (itemLevel != m_items[i].m_itemLevel || m_items[i].m_name.toLower().compare(title.toLower()) < 0)) {
                    ++i;
                }
                m_items.insert(i, item);
                endResetModel();
            }
        }
    }
}

void KdbListModel::slot_deleteItem(QString itemId)
{
    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_id == itemId) {
            // check item type and decrease appropriate item number counter
            if (m_items[i].m_itemType == DatabaseItemType::ENTRY) {
                m_numEntries--;
            } else {
                m_numGroups--;
            }
            // Decrease level 0 count if level of item is 0
            if (0 == m_items[i].m_itemLevel) {
                --m_level_0_count;
            }
            // now delete it from list model
            beginRemoveRows(QModelIndex(), i, i);
            m_items.removeAt(i);
            endRemoveRows();
            // signal to property to update itself in QML
            emit modelDataChanged();
            // emit isEmptyChanged signal if last item was deleted
            // of if there is no level 0 item in the list view any more
            if (m_items.isEmpty() || 0 == m_level_0_count) {
                emit isEmptyChanged();
                emit lastItemDeleted();
            }
        }
    }
}

void KdbListModel::slot_disconnectFromDatabaseClient()
{
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}
