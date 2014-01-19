/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
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
#include "RecentDatabaseListModel.h"

using namespace settingsPublic;

RecentDatabaseListModel::RecentDatabaseListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_registered = false;

    // connect signals to backend
//    bool ret = connect(this, SIGNAL(loadMasterGroups()),
//                       KdbInterface::getInstance()->getWorker(), SLOT(slot_loadMasterGroups()));
//    Q_ASSERT(ret);
}

RecentDatabaseListModel::~RecentDatabaseListModel()
{}

/// slot which adds a new item to the data model
//void RecentDatabaseListModel::slot_addItemToListModel(QString title, QString subtitle, int id, int itemType, int modelId)
//{
//    qDebug() << "RecentDatabaseListModel::slot_addItemToListModel (m_modelId: " << m_modelId << " modelId: " << modelId << ")";
//    if (!m_registered) {
//        m_modelId = modelId;
//        m_registered = true;
//    }
//    if (m_modelId == modelId) {
//        KdbItem item(title, subtitle, id, itemType);
//        if (itemType == kpxPublic::KdbListModel::ENTRY) {
//            // append new entry to end of list
//            beginInsertRows(QModelIndex(), rowCount(), rowCount());
//            m_items << item;
//            endInsertRows();
//        } else {
//            // insert new group after last group in list
//            int i = 0;
//            while (i < m_items.count() && m_items[i].m_itemType == kpxPublic::KdbListModel::GROUP) ++i;
//            beginInsertRows(QModelIndex(), i, i);
//            m_items.insert(i, item);
//            endInsertRows();

//        }

//        qDebug("slot_addItemToListModel - added: %s", CSTR(title));
//    }

//    // signal to property to update itself in QML
//    emit modelDataChanged();
//}

/*!
 * \brief KdbListModel::slot_updateItemInListModel
 * This function updates a single groups item in the list model data.
 *
 * \param title The detail that should be changed in the item.
 * \param groupId Identifier for the item inside of the list model.
 * \param modelId Identifier for list model, which needs to be changed.
 */
//void RecentDatabaseListModel::slot_updateItemInListModel(QString title, QString subTitle, int groupId, int modelId)
//{
//    qDebug() << "RecentDatabaseListModel::slot_deleteItem (m_modelId: " << m_modelId << " modelId: " << modelId << " groupId: " << groupId << ")";

//    // check if we need to do anything
//    if (m_modelId == modelId) {
//        // look at each item in list model
//        for (int i = 0; i < m_items.count(); i++) {
//            if (m_items[i].m_id == groupId) {
//                // set new title name
//                beginResetModel();
//                m_items[i].m_name = title;
//                m_items[i].m_subtitle = subTitle;
//                endResetModel();
//            }
//        }

//        // signal to property to update itself in QML
//        emit modelDataChanged();
//    }
//}

void RecentDatabaseListModel::loadMasterGroupsFromDatabase()
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    // send signal to settings backend
    emit requestLoadRecentDatabaseList();
}

int RecentDatabaseListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_items.count();
}

bool RecentDatabaseListModel::isEmpty()
{
    return m_items.isEmpty();
}

QVariant RecentDatabaseListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_items.count())
        return QVariant();

    return m_items[index.row()].get(role);
}

void RecentDatabaseListModel::clear()
{
    beginResetModel();
    m_items.clear();
    endResetModel();

    // signal to property to update itself in QML
    emit modelDataChanged();
}

void RecentDatabaseListModel::clearListModel()
{
    clear();
}

void RecentDatabaseListModel::slot_deleteItem(int itemId)
{
    qDebug() << "RecentDatabaseListModel::slot_deleteItem (modelId: " << m_modelId << " itemId: " << itemId << ")";

    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_id == itemId) {
            // found it, delete it from list model
            beginRemoveRows(QModelIndex(), i, i);
            m_items.removeAt(i);
            endRemoveRows();
            // signal to property to update itself in QML
            emit modelDataChanged();
        }
    }
}
