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

#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

#include "Keepass1DatabaseInterface.h"
#include "../KdbListModel.h"
#include "../KdbGroup.h"
#include "crypto/yarrow.h"

//using namespace kpxPrivate;
using namespace kpxPrivate;
using namespace kpxPublic;

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
      m_setting_sortAlphabeticallyInListView(true)
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
    qDebug("init Yarrow");
    initYarrow();
    qDebug("generate session key");
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
//    qDebug() << "Keepass1DatabaseInterface::slot_openDatabase() - dbPath: " << filePath << " pw: " << password << " keyfile: " << keyfile;
    // check if there is an already opened database and close it
    if (m_kdb3Database) {
        if (!m_kdb3Database->close()) {
            // send signal with error
            emit errorOccured(kpxPublic::KdbDatabase::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
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
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SETKEY_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        OPEN_DB_CLEANUP
    }
    // open database
    if (!m_kdb3Database->load(filePath, readonly)) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_LOAD_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        OPEN_DB_CLEANUP
    }

// TODO check if .lock file exists and ask user if he wants to open the database in read only mode or discard and open in read/write mode
// TODO create .lock file if it does not exist yet

    // database was opened successful
    emit databaseOpened();

    // load used encryption and KeyTransfRounds and sent to KdbDatabase object so that it is shown in UI database settings page
    emit databaseCryptAlgorithmChanged(m_kdb3Database->cryptAlgorithm());
    emit databaseKeyTransfRoundsChanged(m_kdb3Database->keyTransfRounds());
}

void Keepass1DatabaseInterface::slot_closeDatabase()
{
    // check if database is already closed
    if (!m_kdb3Database) {
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_ALREADY_CLOSED, "");
        return;
    }
    // close database
    if (!m_kdb3Database->close()) {
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    delete m_kdb3Database;
    m_kdb3Database = NULL;

// TODO delete .lock file

    // database was opened successful
    emit databaseClosed();
}

void Keepass1DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
//    qDebug() << "Keepass1DatabaseInterface::slot_createNewDatabase() - dbPath: " << filePath << " pw: " << password << " keyfile: " << keyfile;
    // check if there is an already opened database and close it
    if (m_kdb3Database) {
        if (!m_kdb3Database->close()) {
            // send signal with error
            emit errorOccured(kpxPublic::KdbDatabase::RE_DB_CLOSE_FAILED, m_kdb3Database->getError());
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
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_FILE_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    m_kdb3Database->setCryptAlgorithm(CryptAlgorithm(cryptAlgorithm));
    m_kdb3Database->setKeyTransfRounds(keyTransfRounds);
    if (!m_kdb3Database->setKey(password, keyfile)) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SETKEY_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    m_kdb3Database->generateMasterKey();
    // a new database needs at least one group, so create backup group
    if (!m_kdb3Database->backupGroup(true)) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_CREATE_BACKUPGROUP_ERROR, m_kdb3Database->getError());
        qDebug("ERROR: %s", CSTR(m_kdb3Database->getError()));
        delete m_kdb3Database;
        m_kdb3Database = NULL;
        return;
    }
    if (!m_kdb3Database->save()) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SAVE_ERROR, m_kdb3Database->getError());
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
    qDebug() << "Keepass1DatabaseInterface::slot_changePassKey";
    Q_ASSERT(m_kdb3Database);
    if (!m_kdb3Database->setKey(password, keyFile)) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SETPW_ERROR, m_kdb3Database->getError());
        return;
    }
    m_kdb3Database->generateMasterKey();
    // save database
    if (!m_kdb3Database->save()) {
        // send signal with error
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SAVE_ERROR, m_kdb3Database->getError());
        return;
    }
    emit passwordChanged();
}

void Keepass1DatabaseInterface::slot_loadMasterGroups()
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
        if (masterGroup->isValid()) {
            qDebug("Mastergroup %d: %s", i, CSTR(masterGroup->title()));
            qDebug("Expanded: %d Level: %d", masterGroup->expanded(), masterGroup->level());

            int item_level = masterGroup->level();
            int level = 0;
            if (item_level == level && masterGroup->title() != "Backup") {
                int numberOfSubgroups = masterGroup->children().count();
                int numberOfEntries = m_kdb3Database->entries(masterGroup).count();
                emit addItemToListModel(masterGroup->title(),                           // group name
                                        QString("Subgroups: %1 | Entries: %2")
                                        .arg(numberOfSubgroups).arg(numberOfEntries),   // subtitle
                                        int(masterGroup),                               // item id
                                        kpxPublic::KdbListModel::GROUP,                 // item type
                                        0);                                             // list model of root group
                // save modelId and master group
                m_groups_modelId.insertMulti(0, int(masterGroup));
            }
        }
    }
    emit masterGroupsLoaded(kpxPublic::KdbListModel::RE_OK);
}

void Keepass1DatabaseInterface::slot_loadGroupsAndEntries(int groupId)
{
    qDebug("start KdbListModel::slot_loadGroupsAndEntries");
    Q_ASSERT(m_kdb3Database);
    // load sub groups and entries
    IGroupHandle* group = (IGroupHandle*)(groupId);
    QList<IGroupHandle*> subGroups;
    if (m_setting_sortAlphabeticallyInListView) {
        subGroups = m_kdb3Database->sortedGroups();
    } else {
        subGroups = m_kdb3Database->groups();
    }
    for (int i = 0; i < subGroups.count(); i++) {
        IGroupHandle* subGroup = subGroups.at(i);
        if (subGroup->isValid() && subGroup->parent() == group) {
            qDebug("Group %d: %s", i, CSTR(subGroup->title()));
            int numberOfSubgroups = subGroup->children().count();
            int numberOfEntries = m_kdb3Database->entries(subGroup).count();
            emit addItemToListModel(subGroup->title(),                              // group name
                                    QString("Subgroups: %1 | Entries: %2")
                                    .arg(numberOfSubgroups).arg(numberOfEntries),   // subtitle
                                    int(subGroup),                                  // item id
                                    kpxPublic::KdbListModel::GROUP,                 // item type
                                    groupId);                                       // list model gets groupId as its unique ID
            // save modelId and group
            m_groups_modelId.insertMulti(groupId, int(subGroup));
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
            emit addItemToListModel(entry->title(),                     // group name
                                    getUserAndPassword(entry),          // subtitle
                                    int(entry),                         // item id
                                    kpxPublic::KdbListModel::ENTRY,     // item type
                                    groupId);                           // list model gets groupId as its unique ID
            // save modelId and entry
            m_entries_modelId.insertMulti(groupId, int(entry));
        }
    }
    emit groupsAndEntriesLoaded(kpxPublic::KdbListModel::RE_OK);
}

void Keepass1DatabaseInterface::slot_loadEntry(int entryId)
{
    // get entry handler for entryId
    IEntryHandle* entry = (IEntryHandle*)(entryId);
    // decrypt password which is usually stored encrypted in memory
    SecString password = entry->password();
    password.unlock();
    // send signal with all entry data to all connected entry objects
    // each object will check with entryId if the updated data is interesting to it
    emit entryLoaded(entryId,
                     entry->title(),
                     entry->url(),
                     entry->username(),
                     password.string(),
                     entry->comment(),
                     entry->binaryDesc(),
                     entry->creation().toString(),
                     entry->lastMod().toString(),
                     entry->lastAccess().toString(),
                     entry->expire().toString(),
                     entry->binarySize(),
                     entry->friendlySize()
                     );
    // encrypt password in memory again
    password.lock();
}

void Keepass1DatabaseInterface::slot_loadGroup(int groupId)
{
    // get group handler for groupId
    IGroupHandle* group = (IGroupHandle*)(groupId);
    emit groupLoaded(group->title());
}

void Keepass1DatabaseInterface::slot_saveGroup(int groupId, QString title)
{
    qDebug("slot_saveGroup() groupID: %d", groupId);
    Q_ASSERT(m_kdb3Database);
    Q_ASSERT(groupId != 0); // master group cannot be changed or saved

    //  save changes on group details to database
    IGroupHandle* group = (IGroupHandle*)(groupId);
    group->setTitle(title);
    if (!m_kdb3Database->save()) {
        emit groupSaved(kpxPublic::KdbGroup::RE_SAVE_ERROR);
        return;
    }

    // update all list models which contain the changed group
    QList<int> modelIds = m_groups_modelId.keys(groupId);
    int numberOfSubgroups = group->children().count();
    int numberOfEntries = m_kdb3Database->entries(group).count();
    for (int i = 0; i < modelIds.count(); i++) {
        emit updateItemInListModel(title,                                           // update group name
                                   QString("Subgroups: %1 | Entries: %2")
                                   .arg(numberOfSubgroups).arg(numberOfEntries),    // subtitle
                                   groupId,                                         // identifier for group item in list model
                                   modelIds[i]);                                    // identifier for list model
    }
    // signal to QML
    emit groupSaved(kpxPublic::KdbGroup::RE_OK);
}

void Keepass1DatabaseInterface::slot_unregisterListModel(int modelId)
{
    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(modelId);
    m_entries_modelId.remove(modelId);
}

void Keepass1DatabaseInterface::slot_createNewGroup(QString title, quint32 iconId, int parentGroupId)
{
    qDebug() << "Keepass1DatabaseInterface::slot_createNewGroup";
    Q_ASSERT(m_kdb3Database);

    // get parent group handle and identify IDs of list model
    IGroupHandle* parentGroup;
    if (parentGroupId == 0) {
        // this is the indicator for "addGroup" in database to insert new group into root group as a new master group
        parentGroup = NULL; // set explicitly to NULL, this indicates the root of all master groups
    } else {
        // parent group is not the master group
        parentGroup = (IGroupHandle*)(parentGroupId);
    }
    CGroup* groupData = new CGroup(); // ownership will be given to m_kdb3Database object
    groupData->Title = title;
    groupData->Image = iconId;
    IGroupHandle* newGroup = m_kdb3Database->addGroup(groupData, parentGroup);
    Q_ASSERT(newGroup);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit newGroupCreated(kpxPublic::KdbGroup::RE_SAVE_ERROR, int(newGroup));
        return;
    }

    // update all list model of parent groups where new group was added
    emit addItemToListModel(title,                              // group name
                            "Subgroups: 0 | Entries: 0",        // subtitle
                            int(newGroup),                      // item id
                            kpxPublic::KdbListModel::GROUP,     // item type
                            parentGroupId);                     // for distinguishing different models
    // save modelid and group
    m_groups_modelId.insertMulti(parentGroupId, int(newGroup));

    // update all grandparent groups subtitle in UI
    // check if parent group is root group, then we don't need to do anything
    if (parentGroup != NULL) {
        updateGrandParentGroupInListModel(parentGroup);
    }

    // signal to QML
    emit newGroupCreated(kpxPublic::KdbGroup::RE_OK, int(newGroup));
}

void Keepass1DatabaseInterface::slot_saveEntry(int entryId,
                                        QString title,
                                        QString url,
                                        QString username,
                                        QString password,
                                        QString comment)
{
    Q_ASSERT(m_kdb3Database);
    Q_ASSERT(entryId);
    //  save changes on entry details to database
    IEntryHandle* entry = (IEntryHandle*)(entryId);

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
        emit entrySaved(kpxPublic::KdbGroup::RE_SAVE_ERROR);
        return;
    }

    // update entry item in list model
    QList<int> modelIds = m_entries_modelId.keys(entryId);
    for (int i = 0; i < modelIds.count(); i++) {
        emit updateItemInListModel(title,                          // group name
                                   getUserAndPassword(entry),      // subtitle
                                   entryId,                        // identifier for item in list model
                                   modelIds[i]);                   // identifier for list model of master group
    }
    // signal to QML
    emit entrySaved(kpxPublic::KdbGroup::RE_OK);
    // update all entry objects, there might be two instances open
    // decrypt password which is usually stored encrypted in memory
    s_password = entry->password();
    s_password.unlock();
    emit entryLoaded(entryId,
                     entry->title(),
                     entry->url(),
                     entry->username(),
                     s_password.string(),
                     entry->comment(),
                     entry->binaryDesc(),
                     entry->creation().toString(),
                     entry->lastMod().toString(),
                     entry->lastAccess().toString(),
                     entry->expire().toString(),
                     entry->binarySize(),
                     entry->friendlySize()
                     );
    s_password.lock();
}

void Keepass1DatabaseInterface::slot_createNewEntry(QString title,
                                             QString url,
                                             QString username,
                                             QString password,
                                             QString comment,
                                             int parentGroupId)
{
    // create new entry in specified group
    IGroupHandle* parentGroup = (IGroupHandle*)(parentGroupId);
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
        emit newEntryCreated(kpxPublic::KdbGroup::RE_SAVE_ERROR, int(newEntry));
        return;
    }

    // add entry to list model in order to update UI by sending signal to list models with identifier modelId
    emit addItemToListModel(title,                          // title
                            getUserAndPassword(newEntry),   // subtitle
                            int(newEntry),                  // item id
                            kpxPublic::KdbListModel::ENTRY, // item type
                            parentGroupId);                 // id of list model where to put this entry in
    // save modelId and entry
    m_entries_modelId.insertMulti(parentGroupId, int(newEntry));

    // update all grandparent groups subtitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(parentGroup);
    // signal to QML
    emit newEntryCreated(kpxPublic::KdbGroup::RE_OK, int(newEntry));
}

void Keepass1DatabaseInterface::slot_deleteGroup(int groupId)
{
    Q_ASSERT(groupId);
    // get group handles
    IGroupHandle* group = (IGroupHandle*)(groupId);
    IGroupHandle* parentGroup = group->parent();
    // delete group from database
    Q_ASSERT(m_kdb3Database);
    m_kdb3Database->deleteGroup(group);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit groupDeleted(kpxPublic::KdbGroup::RE_SAVE_ERROR);
        return;
    }

    // remove group from all active list models where it might be added
    emit deleteItemInListModel(groupId);

    // update all grandparent groups subtitle, ie. subgroup counter has to be updated in UI
    if (parentGroup != NULL) { // if parent group is root group we don't need to do anything
        updateGrandParentGroupInListModel(parentGroup);
    }
    // signal to QML
    emit groupDeleted(kpxPublic::KdbGroup::RE_OK);
}

void Keepass1DatabaseInterface::updateGrandParentGroupInListModel(IGroupHandle* parentGroup)
{
    qDebug() << "Keepass1DatabaseInterface::updateGrandParentGroupInListModel";

    IGroupHandle* grandParentGroup = parentGroup->parent();
    int numberOfSubgroups = parentGroup->children().count();
    Q_ASSERT(m_kdb3Database);
    int numberOfEntries = m_kdb3Database->entries(parentGroup).count();
    emit updateItemInListModel(parentGroup->title(),                                // group name
                               QString("Subgroups: %1 | Entries: %2")
                               .arg(numberOfSubgroups).arg(numberOfEntries),        // subtitle
                               int(parentGroup),                                    // identifier for group item in list model
                               int(grandParentGroup));                              // identifier for list model
    qDebug() << "Keepass1DatabaseInterface::updateGrandParentGroupInListModel end";
}

void Keepass1DatabaseInterface::slot_deleteEntry(int entryId)
{
    qDebug() << "Keepass1DatabaseInterface::slot_deleteEntry - entryId: " << entryId;

    // get handles
    IEntryHandle* entry = (IEntryHandle*)(entryId);
    Q_ASSERT(entry);
    IGroupHandle* parentGroup = entry->group();

    qDebug() << "Keepass1DatabaseInterface::slot_deleteEntry got parent group";

    Q_ASSERT(m_kdb3Database);
    // delete entry from database
    m_kdb3Database->deleteEntry(entry);
    // save changes to database
    if (!m_kdb3Database->save()) {
        emit entryDeleted(kpxPublic::KdbGroup::RE_SAVE_ERROR);
        return;
    }

    // remove entry from all active list models where it might be added
    emit deleteItemInListModel(entryId);
    // update all grandparent groups subtitle, ie. entries counter has to be updated in UI
    updateGrandParentGroupInListModel(parentGroup);
    // signal to QML
    emit entryDeleted(kpxPublic::KdbGroup::RE_OK);
}

void Keepass1DatabaseInterface::slot_searchEntries(QString searchString, int rootGroupId)
{
    // get group handle
    IGroupHandle* rootGroup = (IGroupHandle*)(rootGroupId);
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
            emit addItemToListModel(entry->title(),                     // entry name
                                    getUserAndPassword(entry),          // subtitle
                                    int(entry),                         // item id
                                    kpxPublic::KdbListModel::ENTRY,     // item type
                                    -1);                                // specifying model where entry should be added (search list model gets -1)
            // save modelId and entry
            m_entries_modelId.insertMulti(-1, int(entry));
        }
    }
    // signal to QML
    emit searchEntriesCompleted(kpxPublic::KdbListModel::RE_OK);
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
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SAVE_ERROR, "");
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
        emit errorOccured(kpxPublic::KdbDatabase::RE_DB_SAVE_ERROR, "");
        return;
    }
}
