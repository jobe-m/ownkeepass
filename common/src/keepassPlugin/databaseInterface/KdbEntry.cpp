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

#include "QDebug"
#include "ownKeepassGlobal.h"
#include "KdbEntry.h"
#include "private/DatabaseClient.h"

// the next is for using defined keys from Keepass 2
#include "../../keepass2_database/keepassx/src/core/EntryAttributes.h"

using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

KdbEntry::KdbEntry(QObject *parent)
    : QAbstractListModel(parent),
      m_entryId(""),
      m_title(""),
      m_url(""),
      m_userName(""),
      m_password(""),
      m_notes(""),
      m_iconUuid(""),
      m_original_title(""),
      m_original_url(""),
      m_original_userName(""),
      m_original_password(""),
      m_original_notes(""),
      m_original_iconUuid(""),
      m_connected(false),
      m_new_entry_triggered(false),
      m_edited(false)
{}

bool KdbEntry::connectToDatabaseClient()
{
    // check if database backend is already initialized and available
    if (DatabaseClient::getInstance()->getInterface() == NULL) {
        return false;
    }
    // if OK then connect signals to backend
    bool ret = connect(this,
                       SIGNAL(loadEntryFromKdbDatabase(QString)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_loadEntry(QString)));
    Q_UNUSED(ret);
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryLoaded(int,QString,QString,QStringList,QStringList,QString)),
                  this,
                  SLOT(slot_entryDataLoaded(int,QString,QString,QStringList,QStringList,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(saveEntryToKdbDatabase(QString,QStringList,QStringList,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_saveEntry(QString,QStringList,QStringList,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entrySaved(int,QString,QString)),
                  this,
                  SLOT(slot_entryDataSaved(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(createNewEntryInKdbDatabase(QStringList,QStringList,QString,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_createNewEntry(QStringList,QStringList,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(newEntryCreated(int,QString,QString)),
                  this,
                  SLOT(slot_newEntryCreated(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(deleteEntryFromKdbDatabase(QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_deleteEntry(QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryDeleted(int,QString,QString)),
                  this,
                  SLOT(slot_entryDeleted(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(moveEntryInKdbDatabase(QString,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_moveEntry(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(entryMoved(int,QString,QString)),
                  this,
                  SLOT(slot_entryMoved(int,QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(disconnectAllClients()),
                  this,
                  SLOT(slot_disconnectFromDatabaseClient()));
    Q_ASSERT(ret);

    m_connected = true;
    return true;
}

void KdbEntry::disconnectFromDatabaseClient()
{
    clearData();
    m_connected = false;
    m_new_entry_triggered = false;
}

KdbEntry::~KdbEntry()
{}

void KdbEntry::loadEntryData()
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryDataLoaded(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger loading from database client
        emit loadEntryFromKdbDatabase(m_entryId);
    }
}

void KdbEntry::saveEntryData()
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryDataSaved(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger saving to database client
        QStringList keys;
        QStringList values;
        keys << EntryAttributes::TitleKey << EntryAttributes::URLKey << EntryAttributes::UserNameKey
             << EntryAttributes::PasswordKey << EntryAttributes::NotesKey;
        values << m_title << m_url << m_userName << m_password << m_notes;
        qDebug() << "Save entry data: " << m_title << m_url << m_userName << m_password << m_notes;
        emit saveEntryToKdbDatabase(m_entryId, keys, values, m_iconUuid);
    }
}

void KdbEntry::createNewEntry(QString parentgroupId)
{
    Q_ASSERT(parentgroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit newEntryCreated(DatabaseAccessResult::RE_DB_NOT_OPENED, "", 0);
    } else {
        // trigger creation of new entry in database client
        m_new_entry_triggered = true;
        QStringList keys;
        QStringList values;
        keys << EntryAttributes::TitleKey << EntryAttributes::URLKey << EntryAttributes::UserNameKey
             << EntryAttributes::PasswordKey << EntryAttributes::NotesKey;
        values << m_title << m_url << m_userName << m_password << m_notes;
        emit createNewEntryInKdbDatabase(keys, values, parentgroupId, m_iconUuid);
    }
}

void KdbEntry::deleteEntry()
{
    Q_ASSERT(m_entryId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryDeleted(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger deletion of entry in database client
        emit deleteEntryFromKdbDatabase(m_entryId);
    }
}

void KdbEntry::moveEntry(QString newGroupId)
{
    Q_ASSERT(m_entryId != "");
    Q_ASSERT(newGroupId != "");
    if (!m_connected && !connectToDatabaseClient()) {
        // if not successfully connected just return an error
        emit entryMoved(DatabaseAccessResult::RE_DB_NOT_OPENED, "");
    } else {
        // trigger moving of entry in database client
        emit moveEntryInKdbDatabase(m_entryId, newGroupId);
    }
}

void KdbEntry::slot_entryDataLoaded(int result,
                                    QString errorMsg,
                                    QString entryId,
                                    QStringList keys,
                                    QStringList values,
                                    QString iconUuid)
{
    Q_UNUSED(keys)
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        m_original_title    = m_title    = values[KeepassDefault::TITLE];
        m_original_url      = m_url      = values[KeepassDefault::URL];
        m_original_userName = m_userName = values[KeepassDefault::USERNAME];
        m_original_password = m_password = values[KeepassDefault::PASSWORD];
        m_original_notes    = m_notes    = values[KeepassDefault::NOTES];
        m_original_iconUuid = m_iconUuid = iconUuid;
        m_edited = false;
        clearListModel();
        for (int i = KeepassDefault::ADDITIONAL_ATTRIBUTES; i < keys.length(); i++) {
            AdditionalAttributeItem item(keys[i], values[i]);
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_additional_attribute_items.append(item);
            endInsertRows();
        }
        // emit isEmptyChanged signal if list view was empty before
        if (m_additional_attribute_items.length() != 0) {
            emit isEmptyChanged();
            // signal to property to update itself in QML
            emit modelDataChanged();
        }
        emit entryDataLoaded(result, errorMsg);
    }
}

void KdbEntry::slot_entryDataSaved(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryDataSaved(result, errorMsg);
    }
}

void KdbEntry::slot_newEntryCreated(int result, QString errorMsg, QString entryId)
{
    if (m_new_entry_triggered) {
        if (result == DatabaseAccessResult::RE_OK) {
            m_entryId = entryId;
        }
        m_new_entry_triggered = false;
        // forward signal to QML
        emit newEntryCreated(result, errorMsg, entryId);
    }
}

void KdbEntry::slot_entryDeleted(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        clearData();
        emit entryDeleted(result, errorMsg);
    }
}

void KdbEntry::slot_entryMoved(int result, QString errorMsg, QString entryId)
{
    // forward signal to QML only if the signal is for us
    if (entryId.compare(m_entryId) == 0) {
        emit entryMoved(result, errorMsg);
    }
}

void KdbEntry::slot_disconnectFromDatabaseClient()
{
    // database client has requested to disconnect so do accordingly if we have connected at all
    if (m_connected) {
        disconnectFromDatabaseClient();
    }
}

void KdbEntry::clearData()
{
    m_entryId  = "";
    m_title    = "";
    m_url      = "";
    m_userName = "";
    m_password = "";
    m_notes    = "";
    m_iconUuid = "";
    m_original_title    = "";
    m_original_url      = "";
    m_original_userName = "";
    m_original_password = "";
    m_original_notes    = "";
    m_original_iconUuid = "";
    m_edited = false;
    clearListModel();
}

void KdbEntry::checkIfEdited()
{
    if (m_title == m_original_title && m_url == m_original_url &&
        m_userName == m_original_userName && m_password == m_original_password &&
        m_notes == m_original_notes && m_iconUuid == m_original_iconUuid) {
        if (m_edited) {
            m_edited = false;
            emit dataEdited();
        }
    } else {
        if (m_edited == false) {
            m_edited = true;
            emit dataEdited();
        }
    }
}

// for list model
int KdbEntry::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_additional_attribute_items.count();
}

bool KdbEntry::isEmpty()
{
    return m_additional_attribute_items.isEmpty();
}

QVariant KdbEntry::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_additional_attribute_items.count())
        return QVariant();

    return m_additional_attribute_items[index.row()].get(role);
}

void KdbEntry::clearListModel()
{
    beginResetModel();
    m_additional_attribute_items.clear();
    endResetModel();

    // signal to QML and for property update
    emit modelDataChanged();
    emit isEmptyChanged();
}
