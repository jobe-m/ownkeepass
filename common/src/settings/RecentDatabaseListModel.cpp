/***************************************************************************
**
** Copyright (C) 2014 - 2019 Marko Koschak (marko.koschak@tisno.de)
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

using namespace settingsPrivate;

RecentDatabaseListModel::RecentDatabaseListModel(int lengthOfListModel, QObject *parent)
    : QAbstractListModel(parent),
      m_lengthOfListModel(lengthOfListModel)
{}

RecentDatabaseListModel::~RecentDatabaseListModel()
{}

/// Function which adds a new item to the data model at the first position in the list
void RecentDatabaseListModel::addRecent(QString uiName,
                                        QString uiPath,
                                        int dbLocation,
                                        QString dbFilePath,
                                        bool useKeyFile,
                                        int keyFileLocation,
                                        QString keyFilePath,
                                        int databaseType)
{
    DatabaseItem item(uiName, uiPath, dbLocation, dbFilePath, useKeyFile, keyFileLocation, keyFilePath, databaseType);
    beginInsertRows(QModelIndex(), 0, 0);
    m_items.insert(0, item);
    endInsertRows();

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
    if (index < m_items.count()) {
        // found it, delete it from list model
        beginRemoveRows(QModelIndex(), index, index);
        m_items.removeAt(index);
        endRemoveRows();
        // signal to property to update itself in QML
        emit modelDataChanged();
    }
}
