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
#include "../../keepass2_database/keepassxc/src/core/EntryAttributes.h"

using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

// Special handling for list model array: An "empty" list model contains exactly one (dummy) item and nothing else
// Workaround for: The list model must not be empty in order for fixing a jumping list view
// when using TextArea for editing text. If a new line is added the list view jumps to the beginning of the page... weird...
#define FIRST_ITEM_POSITION 1

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
      m_title_modified(false),
      m_url_modified(false),
      m_userName_modified(false),
      m_password_modified(false),
      m_notes_modified(false),
      m_iconUuid_modified(false),
      m_new_entry_triggered(false),
      m_edited(false),
      m_invalid_key(false)
{
    clearListModel();

    // connect signals to backend
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
                  SIGNAL(saveEntryToKdbDatabase(QString,QStringList,QStringList,QStringList,QStringList,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_saveEntry(QString,QStringList,QStringList,QStringList,QStringList,QString)));
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
}

KdbEntry::~KdbEntry()
{}

void KdbEntry::loadEntryData()
{
    Q_ASSERT(m_entryId != "");
        // trigger loading from database client
    emit loadEntryFromKdbDatabase(m_entryId);
}

void KdbEntry::saveEntryData()
{
    Q_ASSERT(m_entryId != "");
    // trigger saving to database client
    QStringList keys;
    QStringList values;
    QStringList keysToDelete;
    QStringList keysToRename;
    keys << EntryAttributes::TitleKey << EntryAttributes::URLKey << EntryAttributes::UserNameKey
         << EntryAttributes::PasswordKey << EntryAttributes::NotesKey;
    values << m_title << m_url << m_userName << m_password << m_notes;

    // Add additional attributes key and values to Stringlists
    for (int i = FIRST_ITEM_POSITION; i < m_additional_attribute_items.count(); ++i) {
        // Check for changed attribute key or value
        if (!m_additional_attribute_items[i].m_to_be_deleted &&
                ((m_additional_attribute_items[i].m_original_key !=
                  m_additional_attribute_items[i].m_key) ||
                 (m_additional_attribute_items[i].m_original_value !=
                  m_additional_attribute_items[i].m_value)))
        {
            // Add original key because the key might got renamed
            if (m_additional_attribute_items[i].m_original_key.length() != 0) {
                keys << m_additional_attribute_items[i].m_original_key;
            } else {
                keys << m_additional_attribute_items[i].m_key;
            }
            values << m_additional_attribute_items[i].m_value;
        }
        // Check which keys can be deleted
        if (m_additional_attribute_items[i].m_to_be_deleted) {
            keysToDelete << m_additional_attribute_items[i].m_key;
        }
        // Check for renamed keys
        if (!m_additional_attribute_items[i].m_to_be_deleted &&
                m_additional_attribute_items[i].m_original_key.length() != 0 &&
                (m_additional_attribute_items[i].m_original_key !=
                 m_additional_attribute_items[i].m_key)) {
            keysToRename << m_additional_attribute_items[i].m_original_key << m_additional_attribute_items[i].m_key;
        }
    }

    emit saveEntryToKdbDatabase(m_entryId, keys, values, keysToDelete, keysToRename, m_iconUuid);
}

void KdbEntry::createNewEntry()
{
    Q_ASSERT(m_groupId != "");
    // trigger creation of new entry in database client
    m_new_entry_triggered = true;
    QStringList keys;
    QStringList values;
    keys << EntryAttributes::TitleKey << EntryAttributes::URLKey << EntryAttributes::UserNameKey
         << EntryAttributes::PasswordKey << EntryAttributes::NotesKey;
    values << m_title << m_url << m_userName << m_password << m_notes;

    for (int i = FIRST_ITEM_POSITION; i < m_additional_attribute_items.count(); ++i) {
        // Add additional attributes key and values to Stringlists
        if (m_additional_attribute_items[i].m_modified &&
                !m_additional_attribute_items[i].m_to_be_deleted) {
            keys << m_additional_attribute_items[i].m_key;
            values << m_additional_attribute_items[i].m_value;
        }
    }

    emit createNewEntryInKdbDatabase(keys, values, m_groupId, m_iconUuid);
}

void KdbEntry::deleteEntry()
{
    Q_ASSERT(m_entryId != "");
    // trigger deletion of entry in database client
    emit deleteEntryFromKdbDatabase(m_entryId);
}

void KdbEntry::moveEntry(QString newGroupId)
{
    Q_ASSERT(m_entryId != "");
    Q_ASSERT(newGroupId != "");
    // trigger moving of entry in database client
    emit moveEntryInKdbDatabase(m_entryId, newGroupId);
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
        clearData();
        m_entryId = entryId;
        m_original_title    = m_title    = values[KeepassDefault::TITLE];
        m_original_url      = m_url      = values[KeepassDefault::URL];
        m_original_userName = m_userName = values[KeepassDefault::USERNAME];
        m_original_password = m_password = values[KeepassDefault::PASSWORD];
        m_original_notes    = m_notes    = values[KeepassDefault::NOTES];
        m_original_iconUuid = m_iconUuid = iconUuid;
        for (int i = KeepassDefault::ADDITIONAL_ATTRIBUTES; i < keys.length(); i++) {
            AdditionalAttributeItem item(keys[i], values[i]);
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_additional_attribute_items.append(item);
            endInsertRows();
        }
        // emit isEmptyChanged signal if list view was empty before
        if (m_additional_attribute_items.length() != FIRST_ITEM_POSITION) {
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
    m_title_modified = false;
    m_url_modified = false;
    m_userName_modified = false;
    m_password_modified = false;
    m_notes_modified = false;
    m_iconUuid_modified = false;
    m_edited = false;
    clearListModel();
}

void KdbEntry::checkIfEdited()
{
    if (m_title_modified || m_url_modified || m_userName_modified ||
        m_password_modified || m_notes_modified || m_iconUuid_modified ||
        checkIfAdditionalAttibuteItemsModified() ) {
        if (!m_edited) {
            m_edited = true;
            emit dataEdited();
        }
    } else {
        if (m_edited) {
            m_edited = false;
            emit dataEdited();
        }
    }
}

bool KdbEntry::checkIfAdditionalAttibuteItemsModified()
{
    for (int i = FIRST_ITEM_POSITION; i < m_additional_attribute_items.count(); ++i) {
        if (m_additional_attribute_items[i].m_modified &&
                !(m_additional_attribute_items[i].m_to_be_created &&
                  m_additional_attribute_items[i].m_to_be_deleted)) {
            return true;
        }
    }
    return false;
}

void KdbEntry::setTitle(const QString value) {
    m_title = value;
    if (m_title != m_original_title) {
        m_title_modified = true;
    } else {
        m_title_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setUrl(const QString value)
{
    m_url = value;
    if (m_url != m_original_url) {
        m_url_modified = true;
    } else {
        m_url_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setUserName(const QString value)
{
    m_userName = value;
    if (m_userName != m_original_userName) {
        m_userName_modified = true;
    } else {
        m_userName_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setPassword(const QString value)
{
    m_password = value;
    if (m_password != m_original_password) {
        m_password_modified = true;
    } else {
        m_password_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setNotes(const QString value)
{
    m_notes = value;
    if (m_notes != m_original_notes) {
        m_notes_modified = true;
    } else {
        m_notes_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setIconUuid(const QString value)
{
    m_iconUuid = value;
    if (m_iconUuid != m_original_iconUuid) {
        m_iconUuid_modified = true;
    } else {
        m_iconUuid_modified = false;
    }
    checkIfEdited();
}

void KdbEntry::setGroupId(const QString value)
{
    m_groupId = value;
}

// for list model
int KdbEntry::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_additional_attribute_items.count();
}

bool KdbEntry::isEmpty()
{
    if (m_additional_attribute_items.count() == FIRST_ITEM_POSITION) {
        return true;
    } else {
        return false;
    }
}

QVariant KdbEntry::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_additional_attribute_items.count()) {
        return QVariant();
    }

    return m_additional_attribute_items[index.row()].get(role);
}

void KdbEntry::clearListModel()
{
    beginResetModel();
    m_additional_attribute_items.clear();
    endResetModel();
    // Now adding dummy item
    AdditionalAttributeItem item("", "", false, false, true);
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_additional_attribute_items.append(item);
    endInsertRows();

    // signal to QML and for property update
    emit modelDataChanged();
    emit isEmptyChanged();
}

Qt::ItemFlags KdbEntry::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return 0;
    }

    return Qt::ItemIsEditable | QAbstractListModel::flags(index);
}

bool KdbEntry::setData(const QModelIndex & index, const QVariant & value, int role)
{
    bool invalidKey = false;
    if (index.row() < 0 || index.row() >= m_additional_attribute_items.count()) {
        return false;
    } else {
        // Check if data to be set is a key
        if (role == ROLE_KEY) {
            QString newKey = value.toString();
//            qDebug() << newKey << " " << index.row();
            if (newKey.length() == 0) {
//                qDebug() << "key empty: error highlight to true";
                invalidKey = true;
            } else {
//                qDebug() << "error highlight to false";
                invalidKey = false;
            }
            // Check if new key is a duplicate of a predefined default key
            if (newKey == EntryAttributes::TitleKey || newKey == EntryAttributes::URLKey ||
                    newKey == EntryAttributes::UserNameKey || newKey == EntryAttributes::PasswordKey ||
                    newKey == EntryAttributes::NotesKey) {
                invalidKey = true;
            }
            // Check if new key name is a duplicate of another additional attribute key
            for (int i = FIRST_ITEM_POSITION; i < m_additional_attribute_items.count(); ++i) {
                if (index.row() != i) {
                    if (m_additional_attribute_items[i].m_key == newKey) {
//                        qDebug() << "key duplicate: error highlight to true";
                        invalidKey = true;
                    }
                }
            }
        }
        m_additional_attribute_items[index.row()].set(value, role);
        m_additional_attribute_items[index.row()].set(QVariant(invalidKey), ROLE_ERROR_HIGHLIGHT);
        m_invalid_key = invalidKey;
        // signal to QML and for property update
        emit invalidKeyChanged();
        emit modelDataChanged();
        return true;
    }
}

void KdbEntry::addAdditionalAttribute()
{
    // Add item with editKeyMode enabled and activated errorHighlight because new item is per default empty
    AdditionalAttributeItem item("", "", true, true, false, true);
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_additional_attribute_items.append(item);
    endInsertRows();
    // emit isEmptyChanged signal if list view was empty before
    if (m_additional_attribute_items.count() == 2) {
        emit isEmptyChanged();
    }
    // signal to property to update itself in QML
    emit modelDataChanged();
}
