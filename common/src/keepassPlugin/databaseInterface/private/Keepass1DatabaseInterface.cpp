/***************************************************************************
**
** Copyright (C) 2012 - 2015 Marko Koschak (marko.koschak@tisno.de)
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

#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

#include "ownKeepassGlobal.h"
#include "Keepass1DatabaseInterface.h"
#include "../KdbListModel.h"
#include "../KdbGroup.h"
#include "crypto/yarrow.h"

// the next is for using defined keys from Keepass2 in loadEntry function
#include "../../keepass2_database/keepassx/src/core/EntryAttributes.h"

using namespace kpxPrivate;
using namespace kpxPublic;
using namespace ownKeepassPublic;

// KeepassX internal stuff
KpxConfig *config;
QString  AppDir;
QString HomeDir;
QString DataDir;
QPixmap* EntryIcons;
IIconTheme* IconLoader;
// End of KeepassX internal stuff

Keepass1DatabaseInterface::Keepass1DatabaseInterface(QObject *parent)
    : QObject(parent), AbstractDatabaseInterface(),
      m_kdb3Database(NULL),
      m_setting_showUserNamePasswordsInListView(false),
      m_setting_sortAlphabeticallyInListView(true),
      m_rootGroupId(0)
{
    initDatabase();
}

Keepass1DatabaseInterface::~Keepass1DatabaseInterface()
{
    qDebug("Destructor Keepass1DatabaseInterface");
    delete m_kdb3Database;
    delete config;
    SecString::deleteSessionKey();
}

void Keepass1DatabaseInterface::initDatabase()
{
    initYarrow();
    SecString::generateSessionKey();

    // init config
    config = new KpxConfig("keepassx-config.ini");
}

#define OPEN_DB_CLEANUP \
    delete m_kdb3Database; \
    m_kdb3Database = NULL; \
    return;

void Keepass1DatabaseInterface::slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly)
{
/*
    Could not open file.;
    Could not open file.;
    Unexpected file size (DB_TOTAL_SIZE < DB_HEADER_SIZE);
    Wrong Signature;
    Unsupported File Version.;
    Unknown Encryption Algorithm.;
    Unable to initialize the twofish algorithm.;
    Unknown encryption algorithm.;
    DONE - Decryption failed. The password is wrong or the file is damaged.
    DONE - Hash test failed. The password is wrong or the key file is damaged.
    Invalid group tree.
*/

    // check if there is an already opened database and close it
    if (m_kdb3Database) {
        if (!m_kdb3Database->close()) {
            // send signal with error
            emit errorOccured(DatabaseAccessResult::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
            qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
            OPEN_DB_CLEANUP
        }
        delete m_kdb3Database;
        m_kdb3Database = NULL;
    }

    // create database object
    m_kdb3Database = new Kdb3Database();

    // set master password and key file to decrypt database
    if (!m_kdb3Database->setKey(password, keyfile)) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_SETKEY_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        OPEN_DB_CLEANUP
    }
    // open database
    if (!m_kdb3Database->load(filePath, readonly)) {
        // send signal with error
        QString errorMessage = m_kdb3Database->getError();
        if (!errorMessage.compare("Hash test failed. The password is wrong or the key file is damaged.", Qt::CaseInsensitive) ||
            !errorMessage.compare("Decryption failed. The password is wrong or the file is damaged.", Qt::CaseInsensitive)) {
            if (keyfile.isEmpty()) {
                emit databaseOpened(DatabaseAccessResult::RE_WRONG_PASSWORD_OR_DB_IS_CORRUPT, "");
            } else {
                emit databaseOpened(DatabaseAccessResult::RE_WRONG_PASSWORD_OR_KEYFILE_OR_DB_IS_CORRUPT, "");
            }
        } else {
            emit errorOccured(DatabaseAccessResult::RE_DB_LOAD_ERROR, m_kdb3Database->getError());
        }
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        OPEN_DB_CLEANUP
    }

// TODO check if .lock file exists and ask user if he wants to open the database in read only mode or discard and open in read/write mode
// TODO create .lock file if it does not exist yet

    // database was opened successfully
    emit databaseOpened(DatabaseAccessResult::RE_OK, "");

    // load used encryption and KeyTransfRounds and sent to KdbDatabase object so that it is shown in UI database settings page
    emit databaseCryptAlgorithmChanged(m_kdb3Database->cryptAlgorithm());
    emit databaseKeyTransfRoundsChanged(m_kdb3Database->keyTransfRounds());
}

void Keepass1DatabaseInterface::slot_closeDatabase()
{
    // check if database is already closed
    if (!m_kdb3Database) {
        emit errorOccured(DatabaseAccessResult::RE_DB_ALREADY_CLOSED, "");
        return;
    }
    // close database
    if (!m_kdb3Database->close()) {
        emit errorOccured(DatabaseAccessResult::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    delete m_kdb3Database;
    m_kdb3Database = NULL;

// TODO delete .lock file

    // database was closed successfully
    emit databaseClosed();
    // trigger disconnect from database client, because reopening will reinitalize the whole interface
    // this makes it possible to load keepass 1 or 2 databases
    emit disconnectAllClients();
}

void Keepass1DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
//    qDebug() << "Keepass1DatabaseInterface::slot_createNewDatabase() - dbPath: " << filePath << " pw: " << password << " keyfile: " << keyfile;
    // check if there is an already opened database and close it
    if (m_kdb3Database) {
        if (!m_kdb3Database->close()) {
            // send signal with error
            emit errorOccured(DatabaseAccessResult::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
            qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
            delete m_kdb3Database;
            m_kdb3Database = NULL;
            return;
        }
        delete m_kdb3Database;
        m_kdb3Database = NULL;
    }

    // create database object
    m_kdb3Database = new Kdb3Database();

    m_kdb3Database->create();
    if (!m_kdb3Database->changeFile(filePath)) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_FILE_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    m_kdb3Database->setCryptAlgorithm(CryptAlgorithm(cryptAlgorithm));
    m_kdb3Database->setKeyTransfRounds(keyTransfRounds);
    if (!m_kdb3Database->setKey(password, keyfile)) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_SETKEY_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    m_kdb3Database->generateMasterKey();
    // a new database needs at least one group, so create backup group
    if (!m_kdb3Database->backupGroup(true)) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_CREATE_BACKUPGROUP_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    if (!m_kdb3Database->save()) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }

// TODO create .lock file

    // send signal with success code
    emit newDatabaseCreated();
}

void Keepass1DatabaseInterface::slot_changePassKey(QString password, QString keyFile)
{
    Q_ASSERT(m_kdb3Database);
    if (!m_kdb3Database->setKey(password, keyFile)) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_SETPW_ERROR, m_kdb3Database->getError());
        return;
    }
    m_kdb3Database->generateMasterKey();
    // save database
    if (!m_kdb3Database->save()) {
        // send signal with error
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, m_kdb3Database->getError());
        return;
    }
    emit passwordChanged();
}

void Keepass1DatabaseInterface::slot_loadMasterGroups(bool registerListModel)
{
    Q_ASSERT(m_kdb3Database);
    QList<IGroupHandle*> masterGroups;
    if (m_setting_sortAlphabeticallyInListView) {
        masterGroups = m_kdb3Database->sortedGroups();
    } else {
        masterGroups = m_kdb3Database->groups();
    }
    for (int i = 0; i < masterGroups.count(); i++) {
        IGroupHandle* masterGroup = masterGroups.at(i);
//        qDebug() << "int of mastergroup: " << uint(masterGroup);
        if (masterGroup->isValid()) {
//            qDebug("Mastergroup %d: %s", i, CSTR(masterGroup->title()));
//            qDebug("Expanded: %d Level: %d", masterGroup->expanded(), masterGroup->level());

            int item_level = masterGroup->level();
            if (masterGroup->title() != "Backup") {
                int numberOfSubgroups = masterGroup->children().count();
                int numberOfEntries = m_kdb3Database->entries(masterGroup).count();
                int listModelId = 0xffffffff;
                if (registerListModel) {
                    // save modelId and master group only if needed
                    // i.e. save model list id for master group page and don't do it for list models used in dialogs
                    listModelId = 0;
                    m_groups_modelId.insertMulti(listModelId, uint(masterGroup));
                }
                emit appendItemToListModel(masterGroup->title(),                           // group name
                                           masterGroup->image(),                           // icon id
                                           QString("Subgroups: %1 | Entries: %2")
                                           .arg(numberOfSubgroups).arg(numberOfEntries),   // subtitle
//                                           masterGroup->image(),
                                           uInt2QString(uint(masterGroup)),                // item id
                                           DatabaseItemType::GROUP,                        // item type
                                           item_level,                                     // item level (0 = root, 1 = first level, etc.
                                           uInt2QString(uint(listModelId)));               // list model of root group
            }
        }
    }
    emit masterGroupsLoaded(DatabaseAccessResult::RE_OK);
}

void Keepass1DatabaseInterface::slot_loadGroupsAndEntries(QString groupId)
{
//    qDebug() << "groupId " << groupId;

    Q_ASSERT(m_kdb3Database);
    // load sub groups and entries
    IGroupHandle* group = (IGroupHandle*)qString2UInt(groupId);
    Q_ASSERT(group);
//    qDebug() << "int of group: " << uint(group);

    QList<IGroupHandle*> subGroups;
    if (m_setting_sortAlphabeticallyInListView) {
        subGroups = m_kdb3Database->sortedGroups();
    } else {
        subGroups = m_kdb3Database->groups();
    }
    for (int i = 0; i < subGroups.count(); i++) {
        IGroupHandle* subGroup = subGroups.at(i);
//        qDebug() << "int of subgroup: " << uint(subGroup->parent()) << " (title: " << subGroup->parent()->title() << ")";

        if (subGroup->isValid() && subGroup->parent() == group) {
//            qDebug("Group %d: %s", i, CSTR(subGroup->title()));
            int numberOfSubgroups = subGroup->children().count();
            int numberOfEntries = m_kdb3Database->entries(subGroup).count();
            emit appendItemToListModel(subGroup->title(),                              // group name
                                       subGroup->image(),                              // icon id
                                       QString("Subgroups: %1 | Entries: %2")
                                       .arg(numberOfSubgroups).arg(numberOfEntries),   // subtitle
                                       uInt2QString(uint(subGroup)),                   // item id
                                       DatabaseItemType::GROUP,                        // item type
                                       0,                                              // item level (not used here)
                                       groupId);                                       // list model gets groupId as its unique ID
            // save modelId and group
            m_groups_modelId.insertMulti(uint(group), uint(subGroup));
        }
    }

    QList<IEntryHandle*> entries;
    if (m_setting_sortAlphabeticallyInListView) {
        entries = m_kdb3Database->entriesSortedStd(group);
    } else {
        entries = m_kdb3Database->entries(group);
    }
    for (int i = 0; i < entries.count(); i++) {
        IEntryHandle* entry = entries.at(i);
        if (entry->isValid()) {
            emit appendItemToListModel(entry->title(),                                 // group name
                                       entry->image(),                                 // icon id
                                       getUserAndPassword(entry),                      // subtitle
                                       uInt2QString(uint(entry)),                      // item id
                                       DatabaseItemType::ENTRY,                        // item type
                                       0,                                              // item level (not used here)
                                       groupId);                                       // list model gets groupId as its unique ID
            // save modelId and entry
            m_entries_modelId.insertMulti(uint(group), uint(entry));
        }
    }
    emit groupsAndEntriesLoaded(DatabaseAccessResult::RE_OK);
}

void Keepass1DatabaseInterface::slot_loadEntry(QString entryId)
{
//    qDebug() << "entryId " << entryId;

    // get entry handler for entryId
    IEntryHandle* entry = (IEntryHandle*)qString2UInt(entryId);
    // decrypt password which is usually stored encrypted in memory
    SecString password = entry->password();
    password.unlock();

    QList<QString> keys;
    QList<QString> values;

    // Add default keys and values (Keepass 1 does not provide custom keys and values as supported in Keepass 2)
    keys.append(EntryAttributes::TitleKey);
    keys.append(EntryAttributes::URLKey);
    keys.append(EntryAttributes::UserNameKey);
    keys.append(EntryAttributes::PasswordKey);
    keys.append(EntryAttributes::NotesKey);
    values.append(entry->title());
    values.append(entry->url());
    values.append(entry->username());
    values.append(password.string());
    values.append(entry->comment());

    // send signal with all entry data to all connected entry objects
    // each object will check with entryId if it needs to update the details
    emit entryLoaded((int)DatabaseAccessResult::RE_OK,
                     entryId,
                     keys,
                     values);

    // encrypt password in memory again
    password.lock();
}

void Keepass1DatabaseInterface::slot_loadGroup(QString groupId)
{
//    qDebug() << "groupId " << groupId;

    // get group handler for groupId
    IGroupHandle* group = (IGroupHandle*)qString2UInt(groupId);
    Q_ASSERT(group);
    emit groupLoaded(DatabaseAccessResult::RE_OK, groupId, group->title());
}

void Keepass1DatabaseInterface::slot_saveGroup(QString groupId, QString title)
{
//    qDebug() << "groupId " << groupId;

    Q_ASSERT(m_kdb3Database);

    //  save changes on group details to database
    IGroupHandle* group = (IGroupHandle*)qString2UInt(groupId);
    Q_ASSERT(group); // Master group (0) cannot be changed
    group->setTitle(title);
    if (!m_kdb3Database->save()) {
        emit groupSaved(DatabaseAccessResult::RE_DB_SAVE_ERROR, groupId);
        return;
    }

    // update all list models which contain the changed group
    QList<int> modelIds = m_groups_modelId.keys(uint(group));
    int numberOfSubgroups = group->children().count();
    int numberOfEntries = m_kdb3Database->entries(group).count();
    for (int i = 0; i < modelIds.count(); i++) {
        if (m_setting_sortAlphabeticallyInListView) {
            emit updateItemInListModelSorted(title,                                           // update group name
                                             group->image(),                                  // icon id
                                             QString("Subgroups: %1 | Entries: %2")
                                             .arg(numberOfSubgroups).arg(numberOfEntries),    // subtitle
                                             groupId,                                         // identifier for group item in list model
                                             uInt2QString(modelIds[i]));                      // identifier for list model
        } else {
            emit updateItemInListModel(title,                                                 // update group name
                                       group->image(),                                        // icon id
                                       QString("Subgroups: %1 | Entries: %2")
                                       .arg(numberOfSubgroups).arg(numberOfEntries),          // subtitle
                                       groupId,                                               // identifier for group item in list model
                                       uInt2QString(modelIds[i]));                            // identifier for list model
        }
    }
    // signal to QML
    emit groupSaved(DatabaseAccessResult::RE_OK, groupId);
}

void Keepass1DatabaseInterface::slot_unregisterListModel(QString modelId)
{
//    qDebug() << "modelId " << modelId;

    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(qString2UInt(modelId));
    m_entries_modelId.remove(qString2UInt(modelId));
}

void Keepass1DatabaseInterface::slot_createNewGroup(QString title, quint32 iconId, QString parentGroupId)
{
//    qDebug() << "parentGroupId " << parentGroupId;

    Q_ASSERT(m_kdb3Database);

    // get parent group handle and identify IDs of list model
    IGroupHandle* parentGroup = (IGroupHandle*)qString2UInt(parentGroupId);

    CGroup* groupData = new CGroup(); // ownership will be given to m_kdb3Database object
    groupData->Title = title;
    groupData->Image = iconId;
    IGroupHandle* newGroup = m_kdb3Database->addGroup(groupData, parentGroup);
    Q_ASSERT(newGroup);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit newGroupCreated(DatabaseAccessResult::RE_DB_SAVE_ERROR, uInt2QString(uint(newGroup)));
        return;
    }

    // update all list model of parent groups where new group was added
    if (m_setting_sortAlphabeticallyInListView) {
        emit addItemToListModelSorted(title,                                       // group name
                                      iconId,                                      // icon id
                                      "Subgroups: 0 | Entries: 0",                 // subtitle
                                      uInt2QString(uint(newGroup)),                  // item id
                                      DatabaseItemType::GROUP,                     // item type
                                      0,                                           // item level (not used here)
                                      parentGroupId);                              // for distinguishing different models
    } else {
        emit appendItemToListModel(title,                                          // group name
                                   iconId,                                         // icon id
                                   "Subgroups: 0 | Entries: 0",                    // subtitle
                                   uInt2QString(uint(newGroup)),                     // item id
                                   DatabaseItemType::GROUP,                        // item type
                                   0,                                              // item level (not used here)
                                   parentGroupId);                                 // for distinguishing different models
    }
    // save modelid and group
    m_groups_modelId.insertMulti(uint(parentGroup), uint(newGroup));

    // update all grandparent groups subtitle in UI
    // check if parent group is root group, then we don't need to do anything
    if (parentGroup != NULL) {
        updateGrandParentGroupInListModel(parentGroup);
    }

    // signal to QML
    emit newGroupCreated(DatabaseAccessResult::RE_OK, uInt2QString(uint(newGroup)));
}

void Keepass1DatabaseInterface::slot_saveEntry(QString entryId,
                                               QString title,
                                               QString url,
                                               QString username,
                                               QString password,
                                               QString comment)
{
//    qDebug() << "entryId " << entryId;

    Q_ASSERT(m_kdb3Database);
    //  save changes on entry details to database
    IEntryHandle* entry = (IEntryHandle*)qString2UInt(entryId);
    Q_ASSERT(entry);

    entry->setTitle(title);
    entry->setUrl(url);
    entry->setUsername(username);
    SecString s_password;
    s_password.setString(password);
    s_password.lock();
    entry->setPassword(s_password);
    entry->setComment(comment);
    // save changes to database and send signal with result
    if (!m_kdb3Database->save()) {
        emit entrySaved(DatabaseAccessResult::RE_DB_SAVE_ERROR, entryId);
        return;
    }

    // update entry item in list model
    QList<int> modelIds = m_entries_modelId.keys(uint(entry));
    for (int i = 0; i < modelIds.count(); i++) {
        if (m_setting_sortAlphabeticallyInListView) {
            emit updateItemInListModelSorted(title,                                 // group name
                                             entry->image(),                        // icon id
                                             getUserAndPassword(entry),             // subtitle
                                             entryId,                               // identifier for item in list model
                                             uInt2QString(modelIds[i]));            // identifier for list model of master group
        } else {
            emit updateItemInListModel(title,                                       // group name
                                       entry->image(),                              // icon id
                                       getUserAndPassword(entry),                   // subtitle
                                       entryId,                                     // identifier for item in list model
                                       uInt2QString(modelIds[i]));                  // identifier for list model of master group
        }
    }
    // signal to QML
    emit entrySaved(DatabaseAccessResult::RE_OK, entryId);
    // update all entry objects, there might be two instances open
    // decrypt password which is usually stored encrypted in memory
    s_password = entry->password();
    s_password.unlock();

    QList<QString> keys;
    QList<QString> values;

    // Add default keys and values (Keepass 1 does not provide custom keys and values as supported in Keepass 2)
    keys.append(EntryAttributes::TitleKey);
    keys.append(EntryAttributes::URLKey);
    keys.append(EntryAttributes::UserNameKey);
    keys.append(EntryAttributes::PasswordKey);
    keys.append(EntryAttributes::NotesKey);
    values.append(entry->title());
    values.append(entry->url());
    values.append(entry->username());
    values.append(s_password.string());
    values.append(entry->comment());

    // send signal with all entry data to all connected entry objects
    // each object will check with entryId if it needs to update the details
    emit entryLoaded((int)DatabaseAccessResult::RE_OK,
                     entryId,
                     keys,
                     values);
    s_password.lock();
}

void Keepass1DatabaseInterface::slot_createNewEntry(QString title,
                                             QString url,
                                             QString username,
                                             QString password,
                                             QString comment,
                                             QString parentGroupId)
{
//    qDebug() << "parentGroupId " << parentGroupId;

    // create new entry in specified group
    IGroupHandle* parentGroup = (IGroupHandle*)qString2UInt(parentGroupId);
    Q_ASSERT(parentGroup);
    Q_ASSERT(m_kdb3Database);
    IEntryHandle* newEntry = m_kdb3Database->newEntry(parentGroup);
    // add data to new entry
    newEntry->setTitle(title);
    newEntry->setUrl(url);
    newEntry->setUsername(username);
    SecString s_password;
    s_password.setString(password);
    s_password.lock();
    newEntry->setPassword(s_password);
    newEntry->setComment(comment);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit newEntryCreated(DatabaseAccessResult::RE_DB_SAVE_ERROR, uInt2QString(uint(newEntry)));
        return;
    }

    // add entry to list model in order to update UI by sending signal to list models with identifier modelId
    if (m_setting_sortAlphabeticallyInListView) {
        emit addItemToListModelSorted(title,                                       // title
                                      newEntry->image(),                           // icon id
                                      getUserAndPassword(newEntry),                // subtitle
                                      uInt2QString(uint(newEntry)),                // item id
                                      DatabaseItemType::ENTRY,                     // item type
                                      0,                                           // item level (not used here)
                                      parentGroupId);                              // id of list model where to put this entry in
    } else {
        emit appendItemToListModel(title,                                          // title
                                   newEntry->image(),                              // icon id
                                   getUserAndPassword(newEntry),                   // subtitle
                                   uInt2QString(uint(newEntry)),                   // item id
                                   DatabaseItemType::ENTRY,                        // item type
                                   0,                                              // item level (not used here)
                                   parentGroupId);                                 // id of list model where to put this entry in
    }
    // save modelId and entry
    m_entries_modelId.insertMulti(uint(parentGroup), uint(newEntry));

    // update all grandparent groups subtitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(parentGroup);
    // signal to QML
    emit newEntryCreated(DatabaseAccessResult::RE_OK, uInt2QString(uint(newEntry)));
}

void Keepass1DatabaseInterface::slot_deleteGroup(QString groupId)
{
//    qDebug() << "groupId " << groupId;

    // get group handles
    IGroupHandle* group = (IGroupHandle*)qString2UInt(groupId);
    Q_ASSERT(group);
    IGroupHandle* parentGroup = group->parent();
    // delete group from database
    Q_ASSERT(m_kdb3Database);
    m_kdb3Database->deleteGroup(group);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit groupDeleted(DatabaseAccessResult::RE_DB_SAVE_ERROR, groupId);
        return;
    }

    // remove group from all active list models where it might be added
    emit deleteItemInListModel(groupId);

    // update all grandparent groups subtitle, ie. subgroup counter has to be updated in UI
    if (parentGroup != NULL) { // if parent group is root group we don't need to do anything
        updateGrandParentGroupInListModel(parentGroup);
    }
    // signal to QML
    emit groupDeleted(DatabaseAccessResult::RE_OK, groupId);
}

void Keepass1DatabaseInterface::updateGrandParentGroupInListModel(IGroupHandle* parentGroup)
{
    Q_ASSERT(m_kdb3Database);
    IGroupHandle* grandParentGroup = parentGroup->parent();
    int numberOfSubgroups = parentGroup->children().count();
    int numberOfEntries = m_kdb3Database->entries(parentGroup).count();
    emit updateItemInListModel(parentGroup->title(),                                  // group name
                               parentGroup->image(),                                  // icon id
                               QString("Subgroups: %1 | Entries: %2")
                               .arg(numberOfSubgroups).arg(numberOfEntries),          // subtitle
                               uInt2QString(uint(parentGroup)),                       // identifier for group item in list model
                               uInt2QString(uint(grandParentGroup)));                 // identifier for list model
}

void Keepass1DatabaseInterface::slot_deleteEntry(QString entryId)
{
//    qDebug() << "entryId " << entryId;

    // get handles
    IEntryHandle* entry = (IEntryHandle*)qString2UInt(entryId);
    Q_ASSERT(entry);
    IGroupHandle* parentGroup = entry->group();
    Q_ASSERT(parentGroup);

    Q_ASSERT(m_kdb3Database);
    // delete entry from database
    m_kdb3Database->deleteEntry(entry);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit entryDeleted(DatabaseAccessResult::RE_DB_SAVE_ERROR, entryId);
        return;
    }

    // remove entry from all active list models where it might be added
    emit deleteItemInListModel(entryId);
    // update all grandparent groups subtitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(parentGroup);
    // signal to QML
    emit entryDeleted(DatabaseAccessResult::RE_OK, entryId);
}

void Keepass1DatabaseInterface::slot_moveEntry(QString entryId, QString newGroupId)
{
//    qDebug() << "entryId " << entryId;
//    qDebug() << "newGroupId " << newGroupId;

    IEntryHandle* entry = (IEntryHandle*)qString2UInt(entryId);
    Q_ASSERT(entry);
    IGroupHandle* parentGroup = entry->group();
    Q_ASSERT(parentGroup);
    IGroupHandle* newGroup = (IGroupHandle*)qString2UInt(newGroupId);
    Q_ASSERT(newGroup);
    Q_ASSERT(m_kdb3Database);

    // move entry to new group within the database
    m_kdb3Database->moveEntry(entry, newGroup);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit entryMoved(DatabaseAccessResult::RE_DB_SAVE_ERROR, entryId);
        return;
    }

    // remove entry from all active list models where it might be added
    emit deleteItemInListModel(entryId);
    // update all grandparent groups subtitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(parentGroup);

    // add entry item in list model of new group if this group is actually visible in UI
    if (m_groups_modelId.contains(uint(newGroup))) {
        // register entry to list model of parent group
        m_entries_modelId.insertMulti(uint(newGroup), uint(entry));
        // now update list model with moved entry
        if (m_setting_sortAlphabeticallyInListView) {
            emit addItemToListModelSorted(entry->title(),                          // entry name
                                          entry->image(),                          // icon id
                                          getUserAndPassword(entry),               // subtitle
                                          entryId,                                 // identifier for entry item in list model
                                          DatabaseItemType::ENTRY,                 // item type
                                          0,                                       // item level (not used here)
                                          newGroupId);                             // identifier for list model where this item should be inserted
        } else {
            emit appendItemToListModel(entry->title(),                             // entry name
                                       entry->image(),                             // icon id
                                       getUserAndPassword(entry),                  // subtitle
                                       entryId,                                    // identifier for entry item in list model
                                       DatabaseItemType::ENTRY,                    // item type
                                       0,                                          // item level (not used here)
                                       newGroupId);                                // identifier for list model where this item should be inserted
        }
    }
    // update subtitle of parent list model where password entry was moved to
    parentGroup = entry->group();
    updateGrandParentGroupInListModel(parentGroup);
    // signal to QML
    emit entryMoved(DatabaseAccessResult::RE_OK, entryId);
}

void Keepass1DatabaseInterface::slot_moveGroup(QString groupId, QString newParentGroupId)
{
    Q_UNUSED(groupId);
    Q_UNUSED(newParentGroupId);
    // TODO
}

void Keepass1DatabaseInterface::slot_searchEntries(QString searchString, QString rootGroupId)
{
//    qDebug() << "rootGroupId " << rootGroupId;

    // get group handle
    IGroupHandle* rootGroup = (IGroupHandle*)qString2UInt(rootGroupId);
    // search for entries in database
    // rootGroup is the groups from which search is performed recursively in the (sub-)tree of the database
    Q_ASSERT(m_kdb3Database);
    QList<IEntryHandle*> entries = m_kdb3Database->search(rootGroup,    // root group
                                                          searchString, // search string
                                                          false,        // is case sensitive
                                                          false,        // is regular expression
                                                          true,         // recursive search
                                                          NULL);        // fields to search
    // update list model with found entries
    for (int i = 0; i < entries.count(); i++) {
        IEntryHandle* entry = entries.at(i);
        if (entry->isValid()) {
//            qDebug() << "entry found: " << entry->title() << " " << uint(entry);
            if (m_setting_sortAlphabeticallyInListView) {
                emit addItemToListModelSorted(entry->title(),                              // entry name
                                              entry->image(),                              // icon id
                                              entry->group()->title(),                     // name of parent group as subtitle
                                              uInt2QString(uint(entry)),                   // item id
                                              DatabaseItemType::ENTRY,                     // item type
                                              0,                                           // item level (not used here)
                                              uInt2QString(0xfffffffe));                   // specifying model where entry should be added (search list model gets 0xfffffffe)
            } else {
                emit appendItemToListModel(entry->title(),                                 // entry name
                                           entry->image(),                                 // icon id
                                           entry->group()->title(),                        // name of parent group as subtitle
                                           uInt2QString(uint(entry)),                      // item id
                                           DatabaseItemType::ENTRY,                        // item type
                                           0,                                              // item level (not used here)
                                           uInt2QString(0xfffffffe));                      // specifying model where entry should be added (search list model gets 0xfffffffe)
            }
            // save modelId and entry
            m_entries_modelId.insertMulti(0xfffffffe, uint(entry));
        }
    }
    // signal to QML
    emit searchEntriesCompleted(DatabaseAccessResult::RE_OK);
}

inline QString Keepass1DatabaseInterface::getUserAndPassword(IEntryHandle* entry)
{
    if (m_setting_showUserNamePasswordsInListView) {
        SecString password = entry->password();
        password.unlock();
        if (entry->username().length() == 0 && password.string().length() == 0) {
            return QString("");
        } else {
            return QString("%1 | %2").arg(entry->username()).arg(password.string());
        }
    } else {
        return QString("");
    }
}

void Keepass1DatabaseInterface::slot_changeKeyTransfRounds(int value)
{
    // do nothing if no database is opened database
    if (!m_kdb3Database) return;

    // set key transformation rounds in database and emit changed signal
    m_kdb3Database->setKeyTransfRounds(value);
    m_kdb3Database->generateMasterKey();
    emit databaseKeyTransfRoundsChanged(m_kdb3Database->keyTransfRounds());
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, "");
        return;
    }
}

void Keepass1DatabaseInterface::slot_changeCryptAlgorithm(int value)
{
    // do nothing if no database is opened database
    if (!m_kdb3Database) return;

    // set crypto algorithm in database and emit changed signal
    m_kdb3Database->setCryptAlgorithm(CryptAlgorithm(value));
    emit databaseCryptAlgorithmChanged(m_kdb3Database->cryptAlgorithm());
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit errorOccured(DatabaseAccessResult::RE_DB_SAVE_ERROR, "");
        return;
    }
}

QImage Keepass1DatabaseInterface::getCustomIcon(QString value)
{
    return QImage;
}

/*!
\brief Convert integer number to QString

The integer number is converted into a 4 byte long hexadecimal QString.

\param value This is the integer value which shall be converted to QString

\return Hexadecimal QString representation of the integer number
*/
inline QString Keepass1DatabaseInterface::uInt2QString(uint value)
{
    if (value == 0) {
        return "0";
    } else if (value == 0xfffffffe) {
        return "fffffffe";
    } else {
        return QString(QByteArray::number(value, 16));
    }
}

/*!
\brief Convert QString to integer

Convert a 4 byte long hexadecimal number in string format to a integer number.
It emits errorOccured signal with result RE_ERR_QSTRING_TO_INT and QString value
if conversion from QString to integer number fails.

\param value This is the QString value which shall be converted to integer
\return positive number if conversion succeeded
        0xfffffffe placeholder for search group if database search is ongoing
        0xffffffff if conversion did not succeed
*/
inline uint Keepass1DatabaseInterface::qString2UInt(QString value)
{
    bool ok = false;
    // threat QString value as hexadecimal number
    uint uintValue = value.toLatin1().toUInt(&ok, 16);
    if (ok) {
        return uintValue;
    } else {
        if (value.compare("0")) {
            return 0;
        } else if (value.compare("fffffffe")) {
            return 0xfffffffe;
        } else {
            emit errorOccured(DatabaseAccessResult::RE_ERR_QSTRING_TO_INT, value);
            return 0xffffffff;
        }
    }
}
