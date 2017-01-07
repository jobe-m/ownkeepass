/***************************************************************************
**
** Copyright (C) 2016 Marko Koschak (marko.koschak@tisno.de)
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
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include "KeepassIcon.h"
#include "private/DatabaseClient.h"
#include "private/AbstractDatabaseInterface.h"
#include "core/Uuid.h"

#include <QDir>
#include <QStandardPaths>
#include <QDebug>

using namespace kpxPublic;

QImage KeepassIcon::requestImage(const QString &uuid, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    QImage icon;
    // Check lenth and determine if the icon is a stardart keepass icon (e.g. icf12) otherwise the icon is a custom one (uuid length is 16 byte)
    if (uuid.size() != Uuid::Length) {
        // Load standard image from resources
        icon = QImage(":/entryicons/" + uuid + ".png", "PNG");
    } else {
        // Load custom image from Keepass database
        icon = (dynamic_cast<AbstractDatabaseInterface*>(kpxPrivate::DatabaseClient::getInstance()->getInterface()))->getCustomIcon(uuid);
    }
    if (size) {
        *size = QSize(icon.width(), icon.height());
    }
    return icon;
}

IconListModel::IconListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_group_icons(false)
{}


IconListModel::~IconListModel()
{}

int IconListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_items.count();
}

bool IconListModel::isEmpty()
{
    return m_items.isEmpty();
}

QVariant IconListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_items.count())
        return QVariant();

    return m_items[index.row()].get(role);
}

void IconListModel::clear()
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

void IconListModel::clearListModel()
{
    clear();
}

void KdbListModel::slot_appendItemToListModel(QString title, quint32 iconId, QString customIconUuid, QString subtitle, QString itemId, int itemType, int itemLevel, QString modelId)
{
    if (!m_registered) {
        m_modelId = modelId;
        m_registered = true;
    }
    // only append if this item is for us
    if (m_modelId.compare(modelId) == 0) {
        KdbItem item(title, iconId, customIconUuid, subtitle, itemId, itemType, itemLevel);
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

void KdbListModel::slot_deleteItem(QString itemId)
{
    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_id == itemId) {
//            qDebug() << "delete item: " << m_items[i].m_name;
            // check item type and decrease appropriate item number counter
            if (m_items[i].m_itemType == DatabaseItemType::ENTRY) {
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
