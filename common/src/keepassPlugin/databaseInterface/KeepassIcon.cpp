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

#include <QDir>
#include <QStandardPaths>
#include <QDebug>

using namespace kpxPublic;
using namespace kpxPrivate;

QImage KeepassIcon::requestImage(const QString &uuid, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    QImage icon;
    // Check lenth and determine if the icon is a standart keepass icon (e.g. icf12) otherwise the icon is a custom one (uuid length is 32 chars)
    if (uuid.size() != 32) {
        // Load standard image from resources
        icon = QImage(":/entryicons/" + uuid + ".png", "PNG");
        // If loading of the image failed than try load custom database icon from Keepass 1 database which starts with "ic69" or "icf69"
        if (icon.isNull() && uuid.size() != 0) {
            // Load custom image from Keepass 1 database
            icon = (dynamic_cast<AbstractDatabaseInterface*>(kpxPrivate::DatabaseClient::getInstance()->getInterface()))->getCustomIcon(uuid);
        }
    } else {
        // Load custom image from Keepass 2 database
        icon = (dynamic_cast<AbstractDatabaseInterface*>(kpxPrivate::DatabaseClient::getInstance()->getInterface()))->getCustomIcon(uuid);
    }
    if (size) {
        *size = QSize(icon.width(), icon.height());
    }
    return icon;
}

QImage IconBackground::requestImage(const QString &uuid, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    QImage icon;
    icon = QImage(":/entryicons/background.png", "PNG");
    if (size) {
        *size = QSize(icon.width(), icon.height());
    }
    return icon;
}

IconListModel::IconListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_group_icons(false),
      m_connected(false)
{
    // Just to be sure: empty m_icons list
    clear();
}

IconListModel::~IconListModel()
{}

bool IconListModel::connectToDatabaseClient()
{
    // check if database backend is already initialized and available
    if (DatabaseClient::getInstance()->getInterface() == NULL) {
        return false;
    }
    // connect signals to backend
    bool ret = connect(this,
                       SIGNAL(loadCustomIcons()),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_loadCustomIcons()));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(appendCustomIconToListModel(QString)),
                  this,
                  SLOT(slot_appendCustomIconToListModel(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(disconnectAllClients()),
                  this,
                  SLOT(slot_disconnectFromDatabaseClient()));
    Q_ASSERT(ret);

    m_connected = true;
    return true;
}

void IconListModel::slot_disconnectFromDatabaseClient()
{
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}

void IconListModel::disconnectFromDatabaseClient()
{
    // disconnect all signals to backend
    // this is not needed ?
//    bool ret = disconnect(this, 0, 0, 0);
//    Q_ASSERT(ret);

    m_connected = false;
}

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

    // signal to QML and for property update
    emit modelDataChanged();
    emit isEmptyChanged();
}

void IconListModel::clearListModel()
{
    clear();
}

void IconListModel::initListModel(int keepassIconType)
{
    // First clean up the list model
    clear();
    // Now populate the list model with standard Keepasss icons if desired
    switch(keepassIconType) {
    case LOAD_KEEPASS_ENTRY_ICONS:
        for(int i = 0; i <= 68; i++) {
            IconItem item(QString("ic%1").arg(i), KEEPASS_ICON);
            // append new entry to end of list
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_items << item;
            endInsertRows();
        }
        break;
    case LOAD_KEEPASS_GROUP_ICONS:
        for(int i = 0; i <= 68; i++) {
            IconItem item(QString("icf%1").arg(i), KEEPASS_ICON);
            // append new entry to end of list
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_items << item;
            endInsertRows();
        }
        break;
    case LOAD_CUSTOM_DATABASE_ICONS:
        if (!m_connected && !connectToDatabaseClient()) {
            // if not successfully connected just return an error
            emit iconListModelLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
        } else {
            emit loadCustomIcons();
        }
        break;
    case LOAD_OWNKEEPASS_ICON_PACK_ICONS:
// TODO
        break;
    default: // do not load any Keepass icons
        break;
    }
    // emit isEmptyChanged signal if list view was empty before
    emit isEmptyChanged();
    // signal to property to update itself in QML
    emit modelDataChanged();
}

void IconListModel::slot_appendCustomIconToListModel(QString uuid)
{
    IconItem item(uuid, CUSTOM_DATABASE_ICON);
    // append new entry to end of list
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_items << item;
    endInsertRows();
    // emit isEmptyChanged signal if list view was empty before
    if (m_items.length() == 1) {
        emit isEmptyChanged();
    }
    // signal to property to update itself in QML
    emit modelDataChanged();
}

// TODO take into use when needed
void IconListModel::slot_deleteCustomIconfromListModel(QString uuid)
{
    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_uuid == uuid) {
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
