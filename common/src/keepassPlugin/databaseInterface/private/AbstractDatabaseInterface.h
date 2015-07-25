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

#ifndef DATABASEINTERFACE_H
#define DATABASEINTERFACE_H

#include <QString>


// Interface for accessing a database
class AbstractDatabaseInterface
{
public:
    virtual ~AbstractDatabaseInterface(){}

public:
    // Whenever changing here enums don't forget to update the enum wrappers in KdbDatabase, KdbEntry, KdbGroup and KdbListModel !!!
    enum eDatabaseAccessResult {
        RE_OK = 0,                                  // no error
        RE_DB_LOAD_ERROR,                           // error loading data from database
        RE_DB_SAVE_ERROR,                           // error saving data into database
        RE_DB_NOT_OPENED,                           // database is not opened
        RE_DB_OPEN,                                 // other database is currently open, close it first
        RE_DB_ALREADY_CLOSED,                       // database already closed, no harm
        RE_DB_CLOSE_FAILED,                         // database closing failed
        RE_DB_FILE_ERROR,                           // file path error for new database
        RE_DB_SETKEY_ERROR,                         // error setting key (consisting of password and/or keyfile
        RE_DB_SETPW_ERROR,                          // error setting password for database
        RE_DB_SETKEYFILE_ERROR,                     // error setting key file for database
        RE_DB_CREATE_BACKUPGROUP_ERROR,             // error creating backup group
        RE_PRECHECK_DB_PATH_ERROR,                  // database file does not exists on precheck
        RE_PRECHECK_KEY_FILE_PATH_ERROR,            // key file does not exists on precheck
        RE_PRECHECK_DB_PATH_CREATION_ERROR,         // path to database file could not be created

        // Keepass 1 specific
        RE_ERR_QSTRING_TO_INT,                      // conversion of QString to int failed

        // Keepass 2 specific
        RE_ERR_UUID_TO_QSTRING,                     // conversion of uuid to QString failed (for passing a reference to QML)

        RE_LAST
    };

    enum eDatabaseItemType {
        UNKNOWN = 0,
        GROUP,
        ENTRY,
    };

    // to be used as type in initDatabaseInterface()
    enum eDatabaseType {
        DB_TYPE_UNKNOWN = -1,
        DB_TYPE_KEEPASS_1 = 0,
        DB_TYPE_KEEPASS_2 = 1,
    };

protected: // signals
    // signals to all objects
    virtual void disconnectAllClients() = 0;

    // signals to KdbDatabase object
    virtual void databaseOpened() = 0;
    virtual void newDatabaseCreated() = 0;
    virtual void databaseClosed() = 0;
    virtual void passwordChanged() = 0;
    virtual void databaseKeyTransfRoundsChanged(int value) = 0;
    virtual void databaseCryptAlgorithmChanged(int value) = 0;
    virtual void errorOccured(int result,
                              QString errorMsg) = 0;

    // signals to KdbListModel object
    virtual void appendItemToListModel(QString title,
                                       QString subtitle,
                                       QString itemId,
                                       int itemType,
                                       int itemLevel,
                                       QString modelId) = 0;
    virtual void addItemToListModelSorted(QString title,
                                          QString subtitle,
                                          QString itemId,
                                          int itemType,
                                          int itemLevel,
                                          QString modelId) = 0;
    virtual void updateItemInListModel(QString title,
                                       QString subTitle,
                                       QString itemId,
                                       QString modelId) = 0;
    virtual void updateItemInListModelSorted(QString title,
                                             QString subTitle,
                                             QString itemId,
                                             QString modelId) = 0;
    virtual void masterGroupsLoaded(int result) = 0;
    virtual void groupsAndEntriesLoaded(int result) = 0;
    virtual void deleteItemInListModel(QString itemId) = 0;
    virtual void searchEntriesCompleted(int result) = 0;

    // signal to KdbEntry object
    virtual void entryLoaded(int result,
                             QString entryId,
                             QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment,
                             QString binaryDesc,
                             QString creation,
                             QString lastMod,
                             QString lastAccess,
                             QString expire,
                             quint32 binarySize,
                             QString friendlySize) = 0;
    virtual void entrySaved(int result,
                            QString entryId) = 0;
    virtual void newEntryCreated(int result,
                                 QString entryId) = 0;
    virtual void entryDeleted(int result,
                              QString entryId) = 0;
    virtual void entryMoved(int result,
                            QString entryId) = 0;

    // signal to KdbGroup object
    virtual void groupLoaded(int result,
                             QString groupId,
                             QString title) = 0;
    virtual void groupSaved(int result,
                            QString groupId) = 0;
    virtual void newGroupCreated(int result,
                                 QString groupId) = 0;
    virtual void groupDeleted(int result,
                              QString groupId) = 0;
    virtual void groupMoved(int result,
                            QString groupId) = 0;


public: // slots
    // signals from KdbDatabase object
    virtual void slot_openDatabase(QString filePath,
                                   QString password,
                                   QString keyfile,
                                   bool readonly) = 0;
    virtual void slot_createNewDatabase(QString filePath,
                                        QString password,
                                        QString keyfile,
                                        int cryptAlgorithm,
                                        int keyTransfRounds) = 0;
    virtual void slot_closeDatabase() = 0;
    virtual void slot_changePassKey(QString password,
                                    QString keyFile) = 0;
    virtual void slot_changeKeyTransfRounds(int value) = 0;
    virtual void slot_changeCryptAlgorithm(int value) = 0;
    virtual void slot_setting_showUserNamePasswordsInListView(bool value) = 0;
    virtual void slot_setting_sortAlphabeticallyInListView(bool value) = 0;

    // signal from KdbListModel object
    virtual void slot_loadMasterGroups(bool registerListModel) = 0;
    virtual void slot_loadGroupsAndEntries(QString groupId) = 0;
    virtual void slot_unregisterListModel(QString modelId) = 0;
    virtual void slot_searchEntries(QString searchString,
                                    QString rootGroupId) = 0;

    // signal from KdbEntry object
    virtual void slot_loadEntry(QString entryId) = 0;
    virtual void slot_saveEntry(QString entryId,
                        QString title,
                        QString url,
                        QString username,
                        QString password,
                        QString comment) = 0;
    virtual void slot_createNewEntry(QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment,
                             QString parentGroupId) = 0;
    virtual void slot_deleteEntry(QString entryId) = 0;
    virtual void slot_moveEntry(QString entryId,
                                QString newGroupId) = 0;

    // signal from KdbGroup object
    virtual void slot_loadGroup(QString groupId) = 0;
    virtual void slot_saveGroup(QString groupId,
                                QString title) = 0;
    virtual void slot_createNewGroup(QString title,
                                     quint32 iconId,
                                     QString parentGroupId) = 0;
    virtual void slot_deleteGroup(QString groupId) = 0;
    virtual void slot_moveGroup(QString groupId,
                                QString newParentGroupId) = 0;
};

Q_DECLARE_INTERFACE(AbstractDatabaseInterface, "harbour.ownkeepass.AbstractDatabaseInterface")
//Q_DECLARE_INTERFACE(DatabaseDefines, "harbour.ownkeepass.DatabaseDefines")

#endif // DATABASEINTERFACE_H
