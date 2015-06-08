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
#include "KdbListModel.h"
#include "private/DatabaseClient.h"

using namespace kpxPublic;
using namespace kpxPrivate;

KdbListModel::KdbListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_modelId(0),
      m_numGroups(0),
      m_numEntries(0),
      m_registered(false),
      m_searchRootGroupId(0)
{
    // connect signals to backend
    bool ret = connect(this, SIGNAL(loadMasterGroups(bool)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_loadMasterGroups(bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(loadGroupsAndEntries(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_loadGroupsAndEntries(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(groupsAndEntriesLoaded(int)),
                  this, SIGNAL(groupsAndEntriesLoaded(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(addItemToListModel(QString, QString, int, int, int, int, bool)),
                  this, SLOT(slot_addItemToListModel(QString, QString, int, int, int, int, bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(unregisterFromDatabaseClient(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_unregisterListModel(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(updateItemInListModel(QString, QString, int, int, bool)),
                  this, SLOT(slot_updateItemInListModel(QString, QString, int, int, bool)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(masterGroupsLoaded(int)),
                  this, SIGNAL(masterGroupsLoaded(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(deleteItemInListModel(int)),
                  this, SLOT(slot_deleteItem(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(searchEntries(QString,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_searchEntries(QString,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(searchEntriesCompleted(int)),
                  this, SIGNAL(searchEntriesCompleted(int)));
    Q_ASSERT(ret);
}

KdbListModel::~KdbListModel()
{
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
    }
}

/// slot which adds a new item to the data model
void KdbListModel::slot_addItemToListModel(QString title, QString subtitle, int id, int itemType, int itemLevel, int modelId, bool sortAbc)
{
    if (!m_registered) {
        m_modelId = modelId;
        m_registered = true;
    }

    if (m_modelId == modelId) {
        KdbItem item(title, subtitle, id, itemType, itemLevel);
        if (sortAbc) {
            // compare and insert alphabetically into list model depending if it is an password entry or group
            // groups are put at the beginning of the list view before entries
            int i = 0;
            int max = 0;
            if (itemType == kpxPublic::KdbListModel::ENTRY) {
                i = m_numGroups;
                max = m_items.length();
                ++m_numEntries;
//                qDebug() << "insert entry i: " << i << " max: " << max << " numEntries: " << m_numEntries << "name: " << title;
            } else {
                i = 0;
                max = m_numGroups;
                ++m_numGroups;
//                qDebug() << "insert group i: " << i << " max: " << max << " numGroups: " << m_numGroups << "name: " << title;
            }
            // now find the position in the list model to insert the item sorted by name
            // take itemLevel into account so that group names are only compared within the same level
            while (i < max && (itemLevel != m_items[i].m_itemLevel || m_items[i].m_name.toLower().compare(title.toLower()) < 0)) {
//               qDebug() << "sort item " << i << " m_name: " << m_items[i].m_name << " =?= " << title << " result: " << m_items[i].m_name.toLower().compare(title.toLower());
               ++i;
            }
            beginInsertRows(QModelIndex(), i, i);
            m_items.insert(i, item);
            endInsertRows();

        } else {
            // don't sort items, just add them as they drop in the list model
            if (itemType == kpxPublic::KdbListModel::ENTRY) {
                // append new entry to end of list
                beginInsertRows(QModelIndex(), rowCount(), rowCount());
                m_items << item;
                endInsertRows();
                m_numEntries++;
            } else {
                // insert new group after last group in list
                int i = 0;
                while (i < m_items.count() && m_items[i].m_itemType == kpxPublic::KdbListModel::GROUP) { ++i; }
                beginInsertRows(QModelIndex(), i, i);
                m_items.insert(i, item);
                endInsertRows();
                m_numGroups++;
            }
        }
        // emit isEmptyChanged signal if list view was empty before
        if (m_items.length() == 1) {
            emit isEmptyChanged();
        }
    }

    // signal to property to update itself in QML
    emit modelDataChanged();
}

/*!
 * \brief KdbListModel::slot_updateItemInListModel
 * This function updates a single groups item in the list model data.
 *
 * \param title The detail that should be changed in the item.
 * \param groupId Identifier for the item inside of the list model.
 * \param modelId Identifier for list model, which needs to be changed.
 */
void KdbListModel::slot_updateItemInListModel(QString title, QString subTitle, int groupId, int modelId, bool sortAbc)

{
    // check if we need to do anything
    if (m_modelId == modelId) {
        // look at each item in list model
        for (int i = 0; i < m_items.count(); i++) {
            if (m_items[i].m_id == groupId) {
                // if list view is sorted alphabetically a new title might change the position of the item
                if (sortAbc) {
//                    qDebug() << "adding in sorted mode: " << title;
                    // now remove and insert item again, this makes sure that the new item will appear
                    // in the correct position in the alphabetically sorted list view
                    int itemId = m_items[i].m_id;
                    int itemType = m_items[i].m_itemType;
                    int itemLevel = m_items[i].m_itemLevel;
                    slot_deleteItem(itemId);
                    slot_addItemToListModel(title, subTitle, itemId, itemType, itemLevel, modelId, sortAbc);
                } else {
//                    qDebug() << "adding in non sorted mode: " << title;
                    // list view has custom sorting so position of item will stay the same and item just needs an update
                    beginResetModel();
                    // set new title name
                    m_items[i].m_name = title;
                    m_items[i].m_subtitle = subTitle;
                    endResetModel();
                }
            }
        }

        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}

void KdbListModel::loadMasterGroupsFromDatabase()
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
        m_registered = false;
    }
    // send signal to global interface of keepass database to get master groups
    emit loadMasterGroups(true);
}

void KdbListModel::loadGroupListFromDatabase()
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
        m_registered = false;
    }
    // this list model is only used in a dialog and is thrown away afterwards, so it does not need to be registered
    // i.e. changes on the database which are normally reflecte to list models are not needed here
    m_registered = true;
    m_modelId = -1;
    // send signal to global interface of keepass database to get master groups
    emit loadMasterGroups(false);
}

void KdbListModel::loadGroupsAndEntriesFromDatabase(int groupId)
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
        m_registered = false;
    }
    // send signal to global interface of keepass database to get entries and subgroups
    emit loadGroupsAndEntries(groupId);
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

void KdbListModel::slot_deleteItem(int itemId)
{
    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_id == itemId) {
//            qDebug() << "delete item: " << m_items[i].m_name;
            // check item type and decrease appropriate item number counter
            if (m_items[i].m_itemType == kpxPublic::KdbListModel::ENTRY) {
                m_numEntries--;
            } else {
                m_numGroups--;
            }
            // now delete it from list model
            beginRemoveRows(QModelIndex(), i, i);
            m_items.removeAt(i);
            endRemoveRows();
            // signal to property to update itself in QML
            emit modelDataChanged();
            // emit isEmptyChanged signal if last item was deleted
            if (m_items.isEmpty()) {
                emit isEmptyChanged();
            }
        }
    }
}

void KdbListModel::searchEntriesInKdbDatabase(QString searchString)
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    if (m_registered) {
        emit unregisterFromDatabaseClient(m_modelId);
    }

    // list model for searching is -1 per default, so set it here already
    m_modelId = -1;
    m_registered = true;

    // send signal to backend to start search in database
    emit searchEntries(searchString, m_searchRootGroupId);
}
