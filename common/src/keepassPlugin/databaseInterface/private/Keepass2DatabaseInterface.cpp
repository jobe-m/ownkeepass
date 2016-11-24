/***************************************************************************
**
** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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
#include "Keepass2DatabaseInterface.h"
#include "../KdbListModel.h"
#include "../KdbGroup.h"
#include "crypto/Crypto.h"
#include "format/KeePass2Reader.h"
#include "keys/PasswordKey.h"
#include "keys/FileKey.h"
#include "core/Group.h"
#include "core/EntrySearcher.h"
#include "core/Metadata.h"


using namespace kpxPrivate;
using namespace kpxPublic;
using namespace ownKeepassPublic;

Keepass2DatabaseInterface::Keepass2DatabaseInterface(QObject *parent)
    : QObject(parent),
      m_Database(NULL),
      m_setting_showUserNamePasswordsInListView(false),
      m_setting_sortAlphabeticallyInListView(true),
      m_rootGroupId(0)
{
    initDatabase();
}

Keepass2DatabaseInterface::~Keepass2DatabaseInterface()
{
    qDebug("Destructor Keepass2DatabaseInterface");
    delete m_Database;
}

void Keepass2DatabaseInterface::initDatabase()
{
    // init crypto algorithms
    if (!Crypto::init()) {
        // Fatal error while testing the cryptographic functions
        emit errorOccured(DatabaseAccessResult::RE_CRYPTO_INIT_ERROR, "");
        delete m_Database;
    }

}

void Keepass2DatabaseInterface::slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly)
{
    bool db_read_only = false;

    // TODO check if .lock file exists and ask user if he wants to open the database in read only mode or discard and open in read/write mode
    // TODO create .lock file if it does not exist yet

    // check if file path of database is readable or read-writable
    QFile file(filePath);
    if (readonly) {
        if (!file.open(QIODevice::ReadOnly)) {
            emit databaseOpened(DatabaseAccessResult::RE_DBFILE_OPEN_ERROR, file.errorString());
            return;
        }
        db_read_only = true;
    } else {
        if (!file.open(QIODevice::ReadWrite)) {
            if (file.open(QIODevice::ReadOnly)) {
                // Database can only be read so tell this to UI
                db_read_only = true;
            } else {
            emit databaseOpened(DatabaseAccessResult::RE_DBFILE_OPEN_ERROR, file.errorString());
            return;
            }
        }
    }

    CompositeKey masterKey;
    masterKey.addKey(PasswordKey(password));
    if (!keyfile.isEmpty()) {
        FileKey key;
        QString errorMsg;
        if (!key.load(keyfile, &errorMsg)) {
            emit databaseOpened(DatabaseAccessResult::RE_KEYFILE_OPEN_ERROR, errorMsg);
            return;
        }
        masterKey.addKey(key);
    }

    if (m_Database) {
        delete m_Database;
    }

    KeePass2Reader reader;
    m_Database = reader.readDatabase(&file, masterKey);

    if (m_Database == Q_NULLPTR) {
        // an error occured during opening of the database
        QString errorString = reader.errorString();
        qDebug() << "Error occured: " << errorString;
        if (!errorString.compare("Not a KeePass database.", Qt::CaseInsensitive)) {
            emit databaseOpened(DatabaseAccessResult::RE_NOT_A_KEEPASS_DB, "");
        } else if (!errorString.compare("Unsupported KeePass database version.", Qt::CaseInsensitive)) {
            emit databaseOpened(DatabaseAccessResult::RE_NOT_SUPPORTED_DB_VERSION, "");
        } else if (!errorString.compare("missing database headers", Qt::CaseInsensitive)) {
            emit databaseOpened(DatabaseAccessResult::RE_MISSING_DB_HEADERS, "");
        } else if (!errorString.compare("Wrong key or database file is corrupt.", Qt::CaseInsensitive)) {
            if (keyfile.isEmpty()) {
                emit databaseOpened(DatabaseAccessResult::RE_WRONG_PASSWORD_OR_DB_IS_CORRUPT, "");
            } else {
                emit databaseOpened(DatabaseAccessResult::RE_WRONG_PASSWORD_OR_KEYFILE_OR_DB_IS_CORRUPT, "");
            }
        } else if (!errorString.compare("Head doesn't match hash", Qt::CaseInsensitive)) {
            emit databaseOpened(DatabaseAccessResult::RE_HEAD_HASH_MISMATCH, "");
        }
        return;
    }

    // currently Keepass 2 database support is limited to read only, so set it here explicitly
    db_read_only = true;

    // database was opened successfully
    if (db_read_only) {
        emit databaseOpened(DatabaseAccessResult::RE_DB_READ_ONLY, "");
    } else {
        emit databaseOpened(DatabaseAccessResult::RE_OK, "");
    }

    // load used encryption and KeyTransfRounds and sent to KdbDatabase object so that it is shown in UI database settings page
    emit databaseCryptAlgorithmChanged(0); // Keepass2 only supports Rijndael_Cipher = 0
    emit databaseKeyTransfRoundsChanged(m_Database->transformRounds());
}

void Keepass2DatabaseInterface::slot_closeDatabase()
{
    // check if database is already closed
    if (!m_Database) {
        emit errorOccured(DatabaseAccessResult::RE_DB_ALREADY_CLOSED, "");
        return;
    }

    delete m_Database;
    m_Database = NULL;

// TODO delete .lock file

    // database was closed successfully
    emit databaseClosed();
    // trigger disconnect from database client, because reopening will reinitalize the whole interface
    // this makes it possible to load keepass 1 or 2 databases
    emit disconnectAllClients();
}

void Keepass2DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
}

void Keepass2DatabaseInterface::slot_changePassKey(QString password, QString keyFile)
{
}

void Keepass2DatabaseInterface::slot_loadMasterGroups(bool registerListModel)
{
    Q_ASSERT(m_Database);

//    Uuid rootGroupId = Uuid(); // root group has list model ID 0
    Uuid rootGroupId = m_Database->rootGroup()->uuid();

    QList<Group*> masterGroups = m_Database->rootGroup()->children();
    for (int i = 0; i < masterGroups.count(); i++) {
        Group* masterGroup = masterGroups.at(i);
//        qDebug() << "Mastergroup " << i << ": " << masterGroup->name();
//        qDebug() << "Expanded: " << masterGroup->isExpanded();

        int numberOfSubgroups = masterGroup->children().count();
        int numberOfEntries = masterGroup->entries().count();

        Uuid masterGroupId = masterGroup->uuid();
//        qDebug() << "Uuid: " << masterGroupId.toByteArray();
//        qDebug() << "toHex: " << masterGroupId.toHex();
        if (registerListModel) {
            // save modelId and master group only if needed
            // i.e. save model list id for master group page and don't do it for list models used in dialogs
            m_groups_modelId.insertMulti((const Uuid &)rootGroupId, (const Uuid &)masterGroupId);
        }
        if (m_setting_sortAlphabeticallyInListView) {
            emit addItemToListModelSorted(masterGroup->name(),
                                          (quint32)masterGroup->iconNumber(),          // icon id
                                          QString("Subgroups: %1 | Entries: %2")
                                          .arg(numberOfSubgroups)
                                          .arg(numberOfEntries),                       // subtitle
                                          masterGroupId.toHex(),                       // item id
                                          (int)DatabaseItemType::GROUP,                // item type
                                          0,                                           // item level (0 = root, 1 = first level, etc.
                                          rootGroupId.toHex());                        // list model of root group
        } else {
            emit appendItemToListModel(masterGroup->name(),                            // group name
                                       (quint32)masterGroup->iconNumber(),             // icon id
                                       QString("Subgroups: %1 | Entries: %2")
                                       .arg(numberOfSubgroups)
                                       .arg(numberOfEntries),                          // subtitle
                                       masterGroupId.toHex(),                          // item id
                                       (int)DatabaseItemType::GROUP,                   // item type
                                       0,                                              // item level (0 = root, 1 = first level, etc.
                                       rootGroupId.toHex());                           // list model of root group
        }
    }

    QList<Entry*> masterEntries = m_Database->rootGroup()->entries();
    for (int i = 0; i < masterEntries.count(); i++) {
        Entry* entry = masterEntries.at(i);
        Uuid itemId = entry->uuid();
        // only append to list model if item ID is valid
        if (m_setting_sortAlphabeticallyInListView) {
            emit appendItemToListModel(entry->title(),                                 // group name
                                       (quint32)entry->iconNumber(),                   // icon id
                                       getUserAndPassword(entry),                      // subtitle
                                       itemId.toHex(),                                 // item id
                                       (int)DatabaseItemType::ENTRY,                   // item type
                                       0,                                              // item level (not used here)
                                       rootGroupId.toHex());                           // list model gets groupId as its unique ID (here 0 because of root group)
        } else {
            emit addItemToListModelSorted(entry->title(),                              // group name
                                          (quint32)entry->iconNumber(),                // icon id
                                          getUserAndPassword(entry),                   // subtitle
                                          itemId.toHex(),                              // item id
                                          (int)DatabaseItemType::ENTRY,                // item type
                                          0,                                           // item level (not used here)
                                          rootGroupId.toHex());                        // list model gets groupId as its unique ID (here 0 because of root group)
        }
        // save modelId and entry
        m_entries_modelId.insertMulti(rootGroupId, itemId);
    }
    emit masterGroupsLoaded(DatabaseAccessResult::RE_OK);
}

void Keepass2DatabaseInterface::slot_loadGroupsAndEntries(QString groupId)
{
    Q_ASSERT(m_Database);
    // load sub groups and entries
    Uuid groupUuid = qString2Uuid(groupId);
    Group* group = m_Database->resolveGroup(groupUuid);
    QList<Group*> subGroups = group->children();

//    qDebug() << "group uuid: " << groupUuid.toByteArray();
//    qDebug() << "group toHex: " << groupUuid.toHex();

    for (int i = 0; i < subGroups.count(); i++) {
        Group* subGroup = subGroups.at(i);
        int numberOfSubgroups = subGroup->children().count();
        int numberOfEntries = subGroup->entries().count();
        Uuid itemId = subGroup->uuid();

        if (m_setting_sortAlphabeticallyInListView) {
            emit appendItemToListModel(subGroup->name(),                                  // group name
                                       (quint32)subGroup->iconNumber(),                   // icon id
                                       QString("Subgroups: %1 | Entries: %2")
                                       .arg(numberOfSubgroups).arg(numberOfEntries),      // subtitle
                                       itemId.toHex(),                                    // item id
                                       (int)DatabaseItemType::GROUP,                      // item type
                                       0,                                                 // item level (not used here)
                                       groupId);                                          // list model gets groupId as its unique ID
        } else {
            emit addItemToListModelSorted(subGroup->name(),                               // group name
                                          (quint32)subGroup->iconNumber(),                // icon id
                                          QString("Subgroups: %1 | Entries: %2")
                                          .arg(numberOfSubgroups).arg(numberOfEntries),   // subtitle
                                          itemId.toHex(),                                 // item id
                                          (int)DatabaseItemType::GROUP,                   // item type
                                          0,                                              // item level (not used here)
                                          groupId);                                       // list model gets groupId as its unique ID
        }
        // save modelId and group
        m_groups_modelId.insertMulti(groupUuid, itemId);
    }

    QList<Entry*> entries = group->entries();

    for (int i = 0; i < entries.count(); i++) {
        Entry* entry = entries.at(i);
        Uuid itemId = entry->uuid();

        if (m_setting_sortAlphabeticallyInListView) {
            emit appendItemToListModel(entry->title(),                                    // group name
                                       (quint32)entry->iconNumber(),                      // icon id
                                       getUserAndPassword(entry),                         // subtitle
                                       itemId.toHex(),                                    // item id
                                       (int)DatabaseItemType::ENTRY,                      // item type
                                       0,                                                 // item level (not used here)
                                       groupId);                                          // list model gets groupId as its unique ID
        } else {
            emit addItemToListModelSorted(entry->title(),                                 // group name
                                          (quint32)entry->iconNumber(),                   // icon id
                                          getUserAndPassword(entry),                      // subtitle
                                          itemId.toHex(),                                 // item id
                                          (int)DatabaseItemType::ENTRY,                   // item type
                                          0,                                              // item level (not used here)
                                          groupId);                                       // list model gets groupId as its unique ID
        }
        // save modelId and entry
        m_entries_modelId.insertMulti(groupUuid, itemId);
    }
    emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_OK);
}

void Keepass2DatabaseInterface::slot_loadEntry(QString entryId)
{
    // get entry handler for entryId
    Entry* entry = m_Database->resolveEntry(qString2Uuid(entryId));
    if (Q_NULLPTR == entry) {
        qDebug() << "ERROR: Could not find entry for UUID: " << entryId;
// TODO add error handling
//        emit entryLoaded(DB_ENTRY_NOT_FOUND,...);
        return;
    } else {
        QList<QString> keys; //entry->attributes()->customKeys();
        QList<QString> values;

        // First add default keys and values
        keys.append(EntryAttributes::TitleKey);
        keys.append(EntryAttributes::URLKey);
        keys.append(EntryAttributes::UserNameKey);
        keys.append(EntryAttributes::PasswordKey);
        keys.append(EntryAttributes::NotesKey);
        values.append(entry->title());
        values.append(entry->url());
        values.append(entry->username());
        values.append(entry->password());
        values.append(entry->notes());

        // Now add additional custom keys and values
        Q_FOREACH (const QString& key, entry->attributes()->customKeys()) {
            keys.append(key);
            values.append(entry->attributes()->value(key));
        }

        // send signal with all entry data to all connected entry objects
        // each object will check with entryId if it needs to update the details
        emit entryLoaded(DatabaseAccessResult::RE_OK,
                         entryId,
                         keys,
                         values);
    }
}

void Keepass2DatabaseInterface::slot_loadGroup(QString groupId)
{
}

void Keepass2DatabaseInterface::slot_saveGroup(QString groupId, QString title)
{
}

void Keepass2DatabaseInterface::slot_unregisterListModel(QString modelId)
{
    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(qString2Uuid(modelId));
    m_entries_modelId.remove(qString2Uuid(modelId));
}

void Keepass2DatabaseInterface::slot_createNewGroup(QString title, quint32 iconId, QString parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_saveEntry(QString entryId,
                                               QString title,
                                               QString url,
                                               QString username,
                                               QString password,
                                               QString comment)
{
    Q_ASSERT(m_Database);
}

void Keepass2DatabaseInterface::slot_createNewEntry(QString title,
                                                    QString url,
                                                    QString username,
                                                    QString password,
                                                    QString comment,
                                                    QString parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_deleteGroup(QString groupId)
{
}

//void Keepass2DatabaseInterface::updateGrandParentGroupInListModel(IGroupHandle* parentGroup)
//{
//}

void Keepass2DatabaseInterface::slot_deleteEntry(QString entryId)
{
}

void Keepass2DatabaseInterface::slot_moveEntry(QString entryId, QString newGroupId)
{
}

void Keepass2DatabaseInterface::slot_moveGroup(QString groupId, QString newParentGroupId)
{
}

void Keepass2DatabaseInterface::slot_searchEntries(QString searchString, QString rootGroupId)
{
    Group* searchGroup;
    if (rootGroupId.compare("0") == 0) {
        searchGroup = m_Database->rootGroup();
    } else {
        searchGroup = m_Database->resolveGroup(qString2Uuid(rootGroupId));
    }
    Q_ASSERT(searchGroup);
    if (searchGroup != Q_NULLPTR) {
        EntrySearcher searcher;
        QString searchId = uInt2QString(0xfffffffe);
        Uuid searchUuid = qString2Uuid(searchId);
        Q_FOREACH (Entry* entry, searcher.search(searchString, searchGroup, Qt::CaseInsensitive)) {
            // update list model with found entries
            if (m_setting_sortAlphabeticallyInListView) {
                emit addItemToListModelSorted(entry->title(),                              // entry name
                                              (quint32)entry->iconNumber(),                // icon id
                                              entry->group()->name(),                      // name of parent group as subtitle
                                              entry->uuid().toHex(),                       // item id
                                              DatabaseItemType::ENTRY,                     // item type
                                              0,                                           // item level (not used here)
                                              searchId);                                   // specifying model where entry should be added (search list model gets 0xfffffffe)
            } else {
                emit appendItemToListModel(entry->title(),                                 // entry name
                                           (quint32)entry->iconNumber(),                   // icon id
                                           entry->group()->name(),                         // name of parent group as subtitle
                                           entry->uuid().toHex(),                          // item id
                                           DatabaseItemType::ENTRY,                        // item type
                                           0,                                              // item level (not used here)
                                           searchId);                                      // specifying model where entry should be added (search list model gets 0xfffffffe)
            }
            // save modelId and entry
            m_entries_modelId.insertMulti(searchUuid, entry->uuid());
        }
        // signal to QML
        emit searchEntriesCompleted(DatabaseAccessResult::RE_OK);
    } else {
        emit searchEntriesCompleted(DatabaseAccessResult::RE_ERR_SEARCH);
    }
}

inline QString Keepass2DatabaseInterface::getUserAndPassword(Entry* entry)
{
    if (m_setting_showUserNamePasswordsInListView) {
        QString username = entry->username();
        QString password = entry->password();
        if (username.length() == 0 && password.length() == 0) {
            return QString("");
        } else {
            return QString("%1 | %2").arg(username).arg(password);
        }
    } else {
        return QString("");
    }
}

/*!
\brief Convert QString to Uuid

This function converts a 16 character long QString into a Uuid. If the
conversion is not successful it emits signal errorOccured with parameter
RE_ERR_QSTRING_TO_UUID. That happens if the QString value is not exactly 16
characters long.

\param QString value to be converted to Uuid
\return Uuid representation of the QString content or
        an empty Uuid if an error occured during conversion
*/
inline Uuid Keepass2DatabaseInterface::qString2Uuid(QString value)
{
    QByteArray baValue = QByteArray::fromHex(value.toLatin1());
    if (baValue.size() == Uuid::Length) {
        return Uuid(baValue);
    } else {
        emit errorOccured(DatabaseAccessResult::RE_ERR_QSTRING_TO_UUID, value);
        return Uuid();
    }
}

/*!
\brief Convert integer number to QString

The integer number is converted into a 4 byte long hexadecimal QString.

\param value This is the integer value which shall be converted to QString

\return Hexadecimal QString representation of the integer number
*/
inline QString Keepass2DatabaseInterface::uInt2QString(uint value)
{
    if (value == 0) {
        return "0";
    } else if (value == 0xfffffffe) {
        return "fffffffe";
    } else {
        return QString(QByteArray::number(value, 16));
    }
}

void Keepass2DatabaseInterface::slot_changeKeyTransfRounds(int value)
{
}

void Keepass2DatabaseInterface::slot_changeCryptAlgorithm(int value)
{
}

const QImage Keepass2DatabaseInterface::getCustomIcon(const QString value)
{
    const Uuid iconUuid = qString2Uuid(value);
    if (m_Database->metadata()->containsCustomIcon(iconUuid)) {
        return m_Database->metadata()->customIcon(iconUuid);
    } else {
        return QImage();
    }
}
