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
#include <QSaveFile>

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

#define GROUP_SUBTITLE_FORMAT "| %1 | %2 | %3"

using namespace kpxPrivate;
using namespace kpxPublic;
using namespace ownKeepassPublic;

Keepass2DatabaseInterface::Keepass2DatabaseInterface(QObject *parent)
    : QObject(parent),
      m_Database(NULL),
      m_filePath(""),
      m_setting_showUserNamePasswordsInListView(false),
      m_setting_sortAlphabeticallyInListView(true)
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
        } else if (errorString.contains("The selected file is an old KeePass 1 database", Qt::CaseInsensitive)) {
            emit databaseOpened(DatabaseAccessResult::RE_OLD_KEEPASS_1_DB, "");
        } else {
            emit databaseOpened(DatabaseAccessResult::RE_UNKNOWN_ERROR, errorString);
        }
        return;
    }

    // database was opened successfully
    m_filePath = filePath;
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
    m_filePath = "";

// TODO delete .lock file

    // database was closed successfully
    emit databaseClosed();
    // trigger disconnect from database client, because reopening will reinitalize the whole interface
    // this makes it possible to load keepass 1 or 2 databases
    emit disconnectAllClients();
}

void Keepass2DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
    m_filePath = filePath;
}

void Keepass2DatabaseInterface::slot_changePassKey(QString password, QString keyFile)
{
    Q_ASSERT(m_Database);
    CompositeKey masterKey;
    masterKey.addKey(PasswordKey(password));
    if (!keyFile.isEmpty()) {
        FileKey key;
        QString errorMsg;
        if (!key.load(keyFile, &errorMsg)) {
            emit databaseOpened(DatabaseAccessResult::RE_KEYFILE_OPEN_ERROR, errorMsg);
            return;
        }
        masterKey.addKey(key);
    }
    m_Database->setKey(masterKey);

    // save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // send signal to QML
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg);
        return;
    }
    emit passwordChanged();
}

void Keepass2DatabaseInterface::slot_loadMasterGroups(bool registerListModel)
{
    // TODO will be used only to get all groups recusively in a list model
    Q_ASSERT(m_Database);
    Uuid rootGroupUuid;
    QString rootGroupId;
    if (registerListModel) {
        rootGroupUuid = m_Database->rootGroup()->uuid();
        rootGroupId = rootGroupUuid.toHex();
    } else {
        // Set default Id for list of groups
        rootGroupId = uInt2QString(0xffffffff);
    }

    // Add root group to list model
    Group* rootGroup = m_Database->rootGroup();
    int numberOfSubgroups = rootGroup->children().count();
    int numberOfEntries = rootGroup->entries().count();
    if (registerListModel) {
        // save modelId and master group only if needed
        // i.e. save model list id for master group page and don't do it for list models used in dialogs
        m_groups_modelId.insertMulti((const Uuid &)rootGroupUuid, Uuid("0"));
    }
    appendItemToListModel(rootGroup->name(),                         // group name
                          getGroupIcon(rootGroup->iconNumber(),
                                       rootGroup->iconUuid()),       // icon uuid
                          QString(GROUP_SUBTITLE_FORMAT)
                          .arg(numberOfSubgroups).arg(numberOfEntries)
                          .arg(rootGroup->notes()),                  // subTitle
                          "0",                                       // item id (root group = 0)
                          (int)DatabaseItemType::GROUP,              // item type
                          0,                                         // item level (0 = root, 1 = first level, etc.
                          rootGroupId);                              // list model of root group

    // Finally go through all groups starting from root group and build up group structure
    QList<Group *> recurGroups = rootGroup->children();
    int groupLevel = 1;
    loadMasterGroupsRecursive(recurGroups, groupLevel, rootGroupId, registerListModel);
    emit masterGroupsLoaded(DatabaseAccessResult::RE_OK, "");
}

void Keepass2DatabaseInterface::loadMasterGroupsRecursive(QList<Group *> recurGroups, int level, QString rootGroupId, bool registerListModel)
{
    Uuid rootGroupUuid = qString2Uuid(rootGroupId);
    for (int i = 0; i < recurGroups.count(); ++i) {
        Group* recurGroup = recurGroups[i];
        // If recycle bin is existing do not show it in the list view
        if (NULL == m_Database->metadata()->recycleBin() || recurGroup->uuid() != m_Database->metadata()->recycleBin()->uuid()) {
            int numberOfSubgroups = recurGroup->children().count();
            int numberOfEntries = recurGroup->entries().count();
            Uuid recurGroupUuid = recurGroup->uuid();
            if (registerListModel) {
                // save modelId and master group only if needed
                // i.e. save model list id for master group page and don't do it for list models used in dialogs
                m_groups_modelId.insertMulti((const Uuid &)rootGroupUuid, (const Uuid &)recurGroupUuid);
            }
            appendItemToListModel(recurGroup->name(),                         // group name
                                  getGroupIcon(recurGroup->iconNumber(),
                                               recurGroup->iconUuid()),       // icon uuid
                                  QString(GROUP_SUBTITLE_FORMAT)
                                  .arg(numberOfSubgroups).arg(numberOfEntries)
                                  .arg(recurGroup->notes()),                  // subTitle
                                  recurGroupUuid.toHex(),                     // item id
                                  (int)DatabaseItemType::GROUP,               // item type
                                  level,                                      // item level (0 = root, 1 = first level, etc.
                                  rootGroupId);                               // list model of root group
            // go recursive through all children if existing
            if (recurGroup->children().count() != 0) {
                loadMasterGroupsRecursive(recurGroup->children(), level + 1, rootGroupId, registerListModel);
            }
        }
    }
}


void Keepass2DatabaseInterface::slot_loadGroupsAndEntries(QString groupId)
{
    Q_ASSERT(m_Database);
    Uuid groupUuid = getGroupUuidFromDatabase(groupId);
    Group* group = getGroupFromDatabase(groupId);
    // load sub groups and entries
    if (Q_NULLPTR == group) {
        qDebug() << "ERROR: Could not find group for UUID: " << groupId;
        emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "");
        return;
    }

    QList<Group*> subGroups = group->children();
    for (int i = 0; i < subGroups.count(); i++) {
        Group* subGroup = subGroups.at(i);
        int numberOfSubgroups = subGroup->children().count();
        int numberOfEntries = subGroup->entries().count();
        Uuid itemId = subGroup->uuid();
        // If recycle bin is existing do not show it in the list view
        if (NULL == m_Database->metadata()->recycleBin() || itemId != m_Database->metadata()->recycleBin()->uuid()) {
            addToListModel(subGroup->name(),                               // group name
                           getGroupIcon(subGroup->iconNumber(),
                                        subGroup->iconUuid()),             // icon uuid
                           QString(GROUP_SUBTITLE_FORMAT)
                           .arg(numberOfSubgroups).arg(numberOfEntries)
                           .arg(subGroup->notes()),                        // subTitle
                           itemId.toHex(),                                 // item id
                           (int)DatabaseItemType::GROUP,                   // item type
                           0,                                              // item level (not used here)
                           groupUuid.toHex());                             // list model gets groupId as its unique ID
            // save modelId and group
            m_groups_modelId.insertMulti(groupUuid, itemId);
        }
    }

    QList<Entry*> entries = group->entries();
    for (int i = 0; i < entries.count(); i++) {
        Entry* entry = entries.at(i);
        if (Q_NULLPTR == entry) {
            qDebug() << "ERROR: Could not find entry for UUID: " << entry;
            emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "");
            return;
        }
        Uuid itemId = entry->uuid();
        addToListModel(entry->title(),                                 // group name
                       getEntryIcon(entry->iconNumber(),
                                    entry->iconUuid()),                // icon uuid
                       getUserAndPassword(entry),                      // subTitle
                       itemId.toHex(),                                 // item id
                       (int)DatabaseItemType::ENTRY,                   // item type
                       0,                                              // item level (not used here)
                       groupUuid.toHex());                             // list model gets groupId as its unique ID
        // save modelId and entry
        m_entries_modelId.insertMulti(groupUuid, itemId);
    }
    emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_OK, "");
}

void Keepass2DatabaseInterface::slot_loadEntry(QString entryId)
{
    QStringList keys;
    QStringList values;

    // get entry handler for entryId
    Entry* entry = m_Database->resolveEntry(qString2Uuid(entryId));
    if (Q_NULLPTR == entry) {
        qDebug() << "ERROR: Could not find entry for UUID: " << entryId;
        emit entryLoaded(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "", entryId, keys, values, "");
        return;
    } else {
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

        // Send signal with all entry data to all connected entry objects
        // Each object will check with entryId if it needs to update the details
        emit entryLoaded(DatabaseAccessResult::RE_OK,
                         "",
                         entryId,
                         keys,
                         values,
                         getEntryIcon(entry->iconNumber(),
                                      entry->iconUuid()));
    }
}

void Keepass2DatabaseInterface::slot_loadGroup(QString groupId)
{
    Q_ASSERT(m_Database);
    // get group handle and load group details
    Uuid groupUuid = qString2Uuid(groupId);
    Group* group = m_Database->resolveGroup(groupUuid);
    if (Q_NULLPTR == group) {
        qDebug() << "ERROR: Could not find group for UUID: " << groupId;
        emit groupLoaded(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND,
                         "",
                         groupId,
                         "",
                         "",
                         "");
        return;
    }
    Uuid customIconUuid = group->iconUuid();
    QString iconUuid;
    if (customIconUuid.isNull()) {
        iconUuid = QString("icf%1").arg(group->iconNumber());
    } else {
        iconUuid = customIconUuid.toHex();
    }
    emit groupLoaded(DatabaseAccessResult::RE_OK,
                     "",
                     groupId,
                     group->name(),
                     group->notes(),
                     iconUuid);
}

void Keepass2DatabaseInterface::slot_saveGroup(QString groupId, QString title, QString notes, QString iconUuid)
{
    Q_ASSERT(m_Database);
    // get group handle and load group details
    Uuid groupUuid = qString2Uuid(groupId);
    Group* group = m_Database->resolveGroup(groupUuid);
    if (Q_NULLPTR == group) {
        qDebug() << "ERROR: Could not find group for UUID: " << groupId;
        emit groupSaved(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "", groupId);
        return;
    }
    group->setName(title);
    group->setNotes(notes);
    if (iconUuid.size() != (Uuid::Length * 2)) {
        // Remove icf from icon name, e.g. "icf12" so that 12 is the icon number
        QString iconNumber = iconUuid;
        group->setIcon(iconNumber.remove(0, 3).toInt());
    } else {
        group->setIcon(qString2Uuid(iconUuid));
    }

    // save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // send signal to QML
        emit groupSaved(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, groupId);
        return;
    }

    // update all list models which contain the changed group
    QList<Uuid> modelIds   = m_groups_modelId.keys(groupUuid);
    int numberOfSubgroups = group->children().count();
    int numberOfEntries   = group->entries().count();
    for (int i = 0; i < modelIds.count(); i++) {
        updateInListModel(title,                                        // update group name
                          iconUuid,                                     // update icon uuid
                          QString(GROUP_SUBTITLE_FORMAT)
                          .arg(numberOfSubgroups).arg(numberOfEntries)
                          .arg(notes),                                  // subTitle
                          groupId,                                      // identifier for group item in list model
                          modelIds[i].toHex());                         // identifier for list model
    }

    // send signal to QML
    emit groupSaved(DatabaseAccessResult::RE_OK, "", groupId);
}

void Keepass2DatabaseInterface::slot_unregisterListModel(QString modelId)
{
    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(qString2Uuid(modelId));
    m_entries_modelId.remove(qString2Uuid(modelId));
}

void Keepass2DatabaseInterface::slot_createNewGroup(QString title, QString notes, QString parentGroupId, QString iconUuid)
{
    Uuid parentGroupUuid = getGroupUuidFromDatabase(parentGroupId);
    Group* parentGroup = getGroupFromDatabase(parentGroupId);
    if (Q_NULLPTR == parentGroup) {
        qDebug() << "ERROR: Could not find group for UUID: " << parentGroupId;
        emit groupSaved(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "", parentGroupId);
        return;
    }

    // Create new empty group
    Group* newGroup = new Group();
    newGroup->setUuid(Uuid::random());
    newGroup->setName(title);
    newGroup->setNotes(notes);
    int iconNumber = 0;
    // Check lenth and determine if the icon is a stardart keepass icon (e.g. icf12) otherwise the icon is a custom one (uuid length is 32 chars)
    if (iconUuid.size() != (Uuid::Length * 2)) {
        QString standardIcon = iconUuid;
        iconNumber = standardIcon.remove(0, 3).toInt();
        newGroup->setIcon(iconNumber);
    } else {
        newGroup->setIcon(qString2Uuid(iconUuid));
    }
    // new group will get handle to database from parent group
    newGroup->setParent(parentGroup);

    // save database
    QString newGroupId = newGroup->uuid().toHex();
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // send signal to QML
        emit newGroupCreated(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, newGroupId);
        return;
    }

    // update all list model of parent groups where new group was added
    addToListModel(title,                                    // group name
                   getGroupIcon(newGroup->iconNumber(),
                                newGroup->iconUuid()),       // icon uuid
                   QString(GROUP_SUBTITLE_FORMAT)
                   .arg(0).arg(0).arg(notes),                // subTitle
                   newGroupId,                               // identifier for group item in list model
                   DatabaseItemType::GROUP,                  // item type
                   0,                                        // item level (not used here)
                   parentGroupUuid.toHex());                 // identifier for list model
    // save modelid and group
    m_groups_modelId.insertMulti(parentGroupUuid, newGroup->uuid());

    // update all grandparent groups subTitle in UI
    // check if parent group is root group, then we don't need to do anything
    if (parentGroup != m_Database->rootGroup()) {
        updateGrandParentGroupInListModel(parentGroup);
    }

    // send signal to QML
    emit newGroupCreated(DatabaseAccessResult::RE_OK, "", newGroupId);
}

void Keepass2DatabaseInterface::slot_saveEntry(QString entryId,
                                               QStringList keys,
                                               QStringList values,
                                               QStringList keysToDelete,
                                               QStringList keysToRename,
                                               QString iconUuid)
{
    Q_ASSERT(m_Database);
    // get group handle and load group details
    Uuid entryUuid = qString2Uuid(entryId);
    Entry* entry = m_Database->resolveEntry(entryUuid);
    if (Q_NULLPTR == entry) {
        qDebug() << "ERROR: Could not find entry for UUID: " << entryId;
        emit entrySaved(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "", entryId);
        return;
    }

    // Using predefined order of keys for default values
    entry->setTitle(values[KeepassDefault::TITLE]);
    entry->setUrl(values[KeepassDefault::URL]);
    entry->setUsername(values[KeepassDefault::USERNAME]);
    entry->setPassword(values[KeepassDefault::PASSWORD]);
    entry->setNotes(values[KeepassDefault::NOTES]);

    // Do not change order of key update, rename and delete
    // Add or update existing keys and values
    for (int i = KeepassDefault::ADDITIONAL_ATTRIBUTES; i < keys.count(); ++i) {
        entry->attributes()->set(keys[i], values[i]);
//        qDebug() << "add or update: " << keys[i] << values[i];
    }

    // Rename existing keys
    for (int i = 0; i < keysToRename.count(); i = i+2) {
        entry->attributes()->rename(keysToRename[i], keysToRename[i+1]);
//        qDebug() << "rename: " << keysToRename[i] << keysToRename[i+1];
    }

    // Delete existing keys
    for (int i = 0; i < keysToDelete.count(); ++i) {
        entry->attributes()->remove(keysToDelete[i]);
//        qDebug() << "delete: " << keysToDelete[i];
    }

    if (iconUuid.size() != (Uuid::Length * 2)) {
        // Remove ic from icon name, e.g. "ic12" so that 12 is the icon number
        QString iconNumber = iconUuid;
        entry->setIcon(iconNumber.remove(0, 2).toInt());
    } else {
        entry->setIcon(qString2Uuid(iconUuid));
    }

    // Save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // Send signal to QML
        emit entrySaved(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, entryId);
        return;
    }

    // Update all list models which contain the changed entry
    QList<Uuid> modelIds = m_entries_modelId.keys(entryUuid);
    for (int i = 0; i < modelIds.count(); i++) {
        updateInListModel(values[KeepassDefault::TITLE],         // entry name
                getEntryIcon(entry->iconNumber(),
                             entry->iconUuid()),       // icon uuid
                getUserAndPassword(entry),             // subTitle
                entryId,                               // identifier for item in list model
                modelIds[i].toHex());                  // identifier for list model of master group
    }
    // Signal to QML
    emit entrySaved(DatabaseAccessResult::RE_OK, "", entryId);

    // In order to update ShowEntryDetailsPage just call loadEntry slot with the entry Id
    slot_loadEntry(entryId);
}

void Keepass2DatabaseInterface::slot_createNewEntry(QStringList keys,
                                                    QStringList values,
                                                    QString parentGroupId,
                                                    QString iconUuid)
{
    Uuid parentGroupUuid = getGroupUuidFromDatabase(parentGroupId);
    Group* parentGroup = getGroupFromDatabase(parentGroupId);
    if (Q_NULLPTR == parentGroup) {
        qDebug() << "ERROR: Could not find group for UUID: " << parentGroupId;
        emit groupSaved(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "", parentGroupId);
        return;
    }

    Entry* newEntry = new Entry();
    newEntry->setUuid(Uuid::random());
    newEntry->setTitle(values[KeepassDefault::TITLE]);
    newEntry->setUrl(values[KeepassDefault::URL]);
    newEntry->setUsername(values[KeepassDefault::USERNAME]);
    newEntry->setPassword(values[KeepassDefault::PASSWORD]);
    newEntry->setNotes(values[KeepassDefault::NOTES]);

    // Add or update existing keys and values
    for (int i = KeepassDefault::ADDITIONAL_ATTRIBUTES; i < keys.count(); ++i) {
        newEntry->attributes()->set(keys[i], values[i]);
//        qDebug() << "save: " << keys[i] << values[i];
    }

    // Add this new entry to a group in the database
    newEntry->setGroup(parentGroup);

    if (iconUuid.size() != (Uuid::Length * 2)) {
        // Remove ic from icon name, e.g. "ic12" so that 12 is the icon number
        QString iconNumber = iconUuid;
        newEntry->setIcon(iconNumber.remove(0, 2).toInt());
    } else {
        newEntry->setIcon(qString2Uuid(iconUuid));
    }

    // save database
    QString newEntryId = newEntry->uuid().toHex();
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // send signal to QML
        emit newEntryCreated(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, newEntryId);
        return;
    }

    // update all list models of parent groups where new entry was added
    if (m_setting_sortAlphabeticallyInListView) {
        emit addItemToListModelSorted(values[KeepassDefault::TITLE],            // entry name
                                      getEntryIcon(newEntry->iconNumber(),
                                                   newEntry->iconUuid()),       // icon uuid
                                      getUserAndPassword(newEntry),             // subTitle
                                      newEntryId,                               // identifier for entry item in list model
                                      DatabaseItemType::ENTRY,                  // item type
                                      0,                                        // item level (not used here)
                                      parentGroupUuid.toHex());                 // identifier for list model
    } else {
        emit appendItemToListModel(values[KeepassDefault::TITLE],               // entry name
                                   getEntryIcon(newEntry->iconNumber(),
                                                newEntry->iconUuid()),          // icon uuid
                                   getUserAndPassword(newEntry),                // subTitle
                                   newEntryId,                                  // identifier for entry item in list model
                                   DatabaseItemType::ENTRY,                     // item type
                                   0,                                           // item level (not used here)
                                   parentGroupUuid.toHex());                    // identifier for list model
    }
    // save modelid and group
    m_entries_modelId.insertMulti(parentGroupUuid, newEntry->uuid());

    // update all grandparent groups subTitle in UI
    // check if parent group is root group, then we don't need to do anything
    if (parentGroup != m_Database->rootGroup()) {
        updateGrandParentGroupInListModel(parentGroup);
    }

    // signal to QML
    emit newEntryCreated(DatabaseAccessResult::RE_OK, "", newEntryId);
}

void Keepass2DatabaseInterface::updateGrandParentGroupInListModel(Group* parentGroup)
{
    Q_ASSERT(m_Database);
    if (parentGroup != m_Database->rootGroup()) {
        Group* grandParentGroup = parentGroup->parentGroup();
        int numberOfSubgroups = parentGroup->children().count();
        int numberOfEntries   = parentGroup->entries().count();
        emit updateItemInListModel(parentGroup->name(),                                   // group name
                                   getGroupIcon(parentGroup->iconNumber(),
                                                parentGroup->iconUuid()),                 // icon uuid
                                   QString(GROUP_SUBTITLE_FORMAT)
                                   .arg(numberOfSubgroups).arg(numberOfEntries)
                                   .arg(parentGroup->notes()),                            // subTitle
                                   parentGroup->uuid().toHex(),                           // identifier for group item in list model
                                   grandParentGroup->uuid().toHex());                     // identifier for list model
    }
}

void Keepass2DatabaseInterface::slot_deleteEntry(QString entryId)
{
    Q_ASSERT(m_Database);
    Uuid entryUuid = qString2Uuid(entryId);
    Entry* entry = m_Database->resolveEntry(entryUuid);
    if (Q_NULLPTR == entry) {
        qDebug() << "ERROR: Could not find entry for UUID: " << entryId;
        emit entryDeleted(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "", entryId);
        return;
    }
    Group* parentGroup = entry->group();
    // This puts entry into recycle bin or deletes it directy if recycle bin is not enabled
    m_Database->recycleEntry(entry);

    // Save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // Send signal to QML
        emit entryDeleted(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, entryId);
        return;
    }

    // remove entry from all active list models where it might be added
    emit deleteItemInListModel(entryId);
    // update all grandparent groups subTitle, ie. entries counter has to be updated in UI
    if (parentGroup != m_Database->rootGroup()) { // if parent group is root group we don't need to do anything
        updateGrandParentGroupInListModel(parentGroup);
    }
    // signal to QML
    emit entryDeleted(DatabaseAccessResult::RE_OK, "", entryId);
}

void Keepass2DatabaseInterface::slot_deleteGroup(QString groupId)
{
    Q_ASSERT(m_Database);
    Uuid groupUuid = qString2Uuid(groupId);
    Group* group = m_Database->resolveGroup(groupUuid);
    if (Q_NULLPTR == group) {
        qDebug() << "ERROR: Could not find group for UUID: " << groupId;
        emit groupDeleted(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "", groupId);
        return;
    }
    Group* parentGroup = group->parentGroup();
    // This puts entry into recycle bin or deletes it directy if recycle bin is not enabled
    m_Database->recycleGroup(group);

    // Save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // Send signal to QML
        emit groupDeleted(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, groupId);
        return;
    }

    // remove group from all active list models where it might be added
    emit deleteItemInListModel(groupId);

    // update all grandparent groups subTitle, ie. subgroup counter has to be updated in UI
    if (parentGroup != m_Database->rootGroup()) { // if parent group is root group we don't need to do anything
        updateGrandParentGroupInListModel(parentGroup);
    }
    // signal to QML
    emit groupDeleted(DatabaseAccessResult::RE_OK, "", groupId);
}

void Keepass2DatabaseInterface::slot_moveEntry(QString entryId, QString newGroupId)
{
    Q_ASSERT(m_Database);
    Uuid entryUuid = qString2Uuid(entryId);
    Entry* entry = m_Database->resolveEntry(entryUuid);
    if (Q_NULLPTR == entry) {
        qDebug() << "ERROR: Could not find entry for UInt: " << entryId;
        emit entryMoved(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "", entryId);
        return;
    }

    Uuid newGroupUuid = qString2Uuid(newGroupId);
    Group* newGroup = m_Database->resolveGroup(newGroupUuid);
    if (Q_NULLPTR == newGroup) {
        qDebug() << "ERROR: Could not find group for UInt: " << newGroup;
        emit entryMoved(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "", newGroupId);
        return;
    }

    Group* oldGroup = entry->group();
    entry->setGroup(newGroup);
    // Save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        // Send signal to QML
        emit entryMoved(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg, entryId);
        return;
    }

    // remove entry from all active list models where it might be added
    emit deleteItemInListModel(entryId);
    // update all grandparent groups subTitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(oldGroup);

    // add entry item in list model of new group if this group is actually visible in UI
    if (m_groups_modelId.contains(newGroupUuid)) {
        // register entry to list model of parent group
        m_entries_modelId.insertMulti(newGroupUuid, entryUuid);
        // now update list model with moved entry
        if (m_setting_sortAlphabeticallyInListView) {
            emit addItemToListModelSorted(entry->title(),                          // entry name
                                          getEntryIcon(entry->iconNumber(),
                                                       entry->iconUuid()),         // icon uuid
                                          getUserAndPassword(entry),               // subTitle
                                          entryId,                                 // identifier for entry item in list model
                                          DatabaseItemType::ENTRY,                 // item type
                                          0,                                       // item level (not used here)
                                          newGroupId);                             // identifier for list model where this item should be inserted
        } else {
            emit appendItemToListModel(entry->title(),                             // entry name
                                       getEntryIcon(entry->iconNumber(),
                                                    entry->iconUuid()),            // icon uuid
                                       getUserAndPassword(entry),                  // subTitle
                                       entryId,                                    // identifier for entry item in list model
                                       DatabaseItemType::ENTRY,                    // item type
                                       0,                                          // item level (not used here)
                                       newGroupId);                                // identifier for list model where this item should be inserted
        }
    }
    // update subTitle of parent list model where password entry was moved to
    updateGrandParentGroupInListModel(newGroup);
    // signal to QML
    emit entryMoved(DatabaseAccessResult::RE_OK, "", entryId);
}

void Keepass2DatabaseInterface::slot_moveGroup(QString groupId, QString newParentGroupId)
{
}

void Keepass2DatabaseInterface::slot_searchEntries(QString searchString, QString rootGroupId)
{
    Group* searchGroup = getGroupFromDatabase(rootGroupId);
    if (searchGroup != Q_NULLPTR) {
        EntrySearcher searcher;
        QString searchId = uInt2QString(0xfffffffe);
        Uuid searchUuid = qString2Uuid(searchId);
        Q_FOREACH (Entry* entry, searcher.search(searchString, searchGroup, Qt::CaseInsensitive)) {
            if (Q_NULLPTR == entry) {
                qDebug() << "ERROR: Could not find entry for UUID: " << entry;
                emit searchEntriesCompleted(DatabaseAccessResult::RE_DB_ENTRY_NOT_FOUND, "");
                return;
            }
            // update list model with found entries
            if (m_setting_sortAlphabeticallyInListView) {
                emit addItemToListModelSorted(entry->title(),                              // entry name
                                              getEntryIcon(entry->iconNumber(),
                                                           entry->iconUuid()),             // icon uuid
                                              entry->group()->name(),                      // name of parent group as subTitle
                                              entry->uuid().toHex(),                       // item id
                                              DatabaseItemType::ENTRY,                     // item type
                                              0,                                           // item level (not used here)
                                              searchId);                                   // specifying model where entry should be added (search list model gets 0xfffffffe)
            } else {
                emit appendItemToListModel(entry->title(),                                 // entry name
                                           getEntryIcon(entry->iconNumber(),
                                                        entry->iconUuid()),                // icon uuid
                                           entry->group()->name(),                         // name of parent group as subTitle
                                           entry->uuid().toHex(),                          // item id
                                           DatabaseItemType::ENTRY,                        // item type
                                           0,                                              // item level (not used here)
                                           searchId);                                      // specifying model where entry should be added (search list model gets 0xfffffffe)
            }
            // save modelId and entry
            m_entries_modelId.insertMulti(searchUuid, entry->uuid());
        }
        // signal to QML
        emit searchEntriesCompleted(DatabaseAccessResult::RE_OK, "");
    } else {
        emit searchEntriesCompleted(DatabaseAccessResult::RE_DB_GROUP_NOT_FOUND, "");
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
    } else if (value.compare("0") == 0) {
        if (m_Database && m_Database->rootGroup()) {
            return m_Database->rootGroup()->uuid();
        } else {
            return Uuid();
        }
    } else if (value.compare("fffffffe") == 0) {
        // special handle for search (group) list model
        return Uuid("fffffffe");
    } else if (value.compare("ffffffff") == 0) {
        // special handle for not registered list models
        return Uuid("ffffffff");
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
    switch (value) {
    case 0:
        return "0";
    case 0xfffffffe:
        return "fffffffe";
    case 0xffffffff:
        return "ffffffff";
    default:
        return QString(QByteArray::number(value, 16));
    }
}

void Keepass2DatabaseInterface::slot_changeKeyTransfRounds(int value)
{
    Q_ASSERT(m_Database);
    m_Database->setTransformRounds((quint64) value);
    // Save database
    QString errorMsg = saveDatabase();
    if (errorMsg.length() != 0) {
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, errorMsg);
        return;
    }
    emit databaseKeyTransfRoundsChanged(value);
}

void Keepass2DatabaseInterface::slot_changeCryptAlgorithm(int value)
{
    Q_UNUSED(value);
    // Not available in Keepass 2 database
}

void Keepass2DatabaseInterface::slot_loadCustomIcons()
{
    Q_FOREACH (const Uuid& iconUuid, m_Database->metadata()->customIconsOrder()) {
        emit appendCustomIconToListModel(iconUuid.toHex());
    }
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

QString Keepass2DatabaseInterface::saveDatabase()
{
    QSaveFile saveFile(m_filePath);
    if (saveFile.open(QIODevice::WriteOnly)) {
        m_writer.writeDatabase(&saveFile, m_Database);
        if (m_writer.hasError()) {
            // error occured in the Keepass 2 writer
            return m_writer.errorString();
        }
        if (!saveFile.commit()) {
            // could not save to file
            return saveFile.errorString();
        }
    } else {
        // could not open file
        return saveFile.errorString();
    }
    return "";
}

QString Keepass2DatabaseInterface::getEntryIcon(int standardIcon, Uuid customIcon)
{
    // if custom icon is not set then the uuid contains the file name of the standard Keepass icon
    if (customIcon.isNull()) {
        return QString("ic%1").arg(standardIcon);
    } else {
        return customIcon.toHex();
    }
}

QString Keepass2DatabaseInterface::getGroupIcon(int standardIcon, Uuid customIcon)
{
    // if custom icon is not set then the uuid contains the file name of the standard Keepass icon
    if (customIcon.isNull()) {
        return QString("icf%1").arg(standardIcon);
    } else {
        return customIcon.toHex();
    }
}

Uuid Keepass2DatabaseInterface::getGroupUuidFromDatabase(QString groupId)
{
    Q_ASSERT(m_Database);
    Uuid groupUuid;
    // Id for root group is "0" otherwise it is uuid for of parent group
    if (groupId.compare("0") == 0) {
        groupUuid = m_Database->rootGroup()->uuid();
    } else {
        groupUuid = qString2Uuid(groupId);
    }
    return groupUuid;
}

Group* Keepass2DatabaseInterface::getGroupFromDatabase(QString groupId)
{
    Q_ASSERT(m_Database);
    Group* group;
    // Id for root group is "0" otherwise it is uuid for of parent group
    if (groupId.compare("0") == 0) {
        group = m_Database->rootGroup();
    } else {
        group = m_Database->resolveGroup(qString2Uuid(groupId));
    }
    return group;
}

void Keepass2DatabaseInterface::addToListModel(QString title, QString iconUuid, QString subTitle,
                                               QString itemId, int itemType, int itemLevel, QString modelId) {
    if (m_setting_sortAlphabeticallyInListView) {
        emit addItemToListModelSorted(title, iconUuid, subTitle, itemId, itemType, itemLevel, modelId);
    } else {
        emit appendItemToListModel(title, iconUuid, subTitle, itemId, itemType, itemLevel, modelId);
    }
}

void Keepass2DatabaseInterface::updateInListModel(QString title, QString iconUuid, QString subTitle, QString itemId, QString modelId)
{
    if (m_setting_sortAlphabeticallyInListView) {
        emit updateItemInListModelSorted(title, iconUuid, subTitle, itemId, modelId);
    } else {
        emit updateItemInListModel(title, iconUuid, subTitle, itemId, modelId);
    }
}
