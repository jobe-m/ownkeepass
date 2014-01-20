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
    // connect signals to backend
//    bool ret = connect(this, SIGNAL(loadMasterGroups()),
//                       KdbInterface::getInstance()->getWorker(), SLOT(slot_loadMasterGroups()));
//    Q_ASSERT(ret);
}

RecentDatabaseListModel::~RecentDatabaseListModel()
{}

/// Function which adds a new item to the data model
void RecentDatabaseListModel::addRecent(QString uiName,
                                        QString uiPath,
                                        int dbLocation,
                                        QString dbFilePath,
                                        bool useKeyFile,
                                        int keyFileLocation,
                                        QString keyFilePath)
{
    // Find item in list model and delete it if it exist
    for (int i = 0; i < m_items.count(); ++i) {
        if ((m_items[i].m_ui_name == uiName) && (m_items[i].m_ui_path == uiPath)) {
            deleteItem(i);
        }
    }
    // Insert recent at first position in the list model
    DatabaseItem item(uiName, uiPath, dbLocation, dbFilePath, useKeyFile, keyFileLocation, keyFilePath);
    beginInsertRows(QModelIndex(), 0, 0);
    m_items.insert(0, item);
    endInsertRows();

    qDebug() << "addRecent - added: " << uiName;

    // signal to property to update itself in QML
    emit modelDataChanged();
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

void RecentDatabaseListModel::deleteItem(int index)
{
    qDebug() << "RecentDatabaseListModel::deleteItem (index: " << index << ")";

    if (index < m_items.count()) {
        // found it, delete it from list model
        beginRemoveRows(QModelIndex(), index, index);
        m_items.removeAt(index);
        endRemoveRows();
        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}

void RecentDatabaseListModel::loadRecentDatabaseList()
{
    // make list view empty and unregister if necessary
    if (!isEmpty()) {
        clear();
    }
    // send signal to settings backend
    emit requestLoadRecentDatabaseList();
}

void RecentDatabaseListModel::saveRecentDatabaseList()
{
// TODO
}
