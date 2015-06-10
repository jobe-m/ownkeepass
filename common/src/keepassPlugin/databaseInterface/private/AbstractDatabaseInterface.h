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

// to be used as type in initDatabaseInterface()
#define DATABASE_UNKNOWN_TYPE 0
#define DATABASE_KEEPASS_1    1
#define DATABASE_KEEPASS_2    2

// Interface for accessing a database
class AbstractDatabaseInterface
{
public:
    virtual ~AbstractDatabaseInterface(){}

protected: // signals
    // signals to KdbDatabase object
    virtual void databaseOpened() = 0;
    virtual void newDatabaseCreated() = 0;
    virtual void databaseClosed() = 0;
    virtual void passwordChanged() = 0;
    virtual void databaseKeyTransfRoundsChanged(int value) = 0;
    virtual void databaseCryptAlgorithmChanged(int value) = 0;
    virtual void errorOccured(int result, QString errorMsg) = 0;

    // signals to KdbListModel object
    virtual void addItemToListModel(QString title, QString subtitle, int itemId, int itemType, int itemLevel, int modelId, bool sortAbc) = 0;
    virtual void masterGroupsLoaded(int result) = 0;
    virtual void groupsAndEntriesLoaded(int result) = 0;
    virtual void updateItemInListModel(QString title, QString subTitle, int itemId, int modelId, bool sortAbc) = 0;
    virtual void deleteItemInListModel(int itemId) = 0;
    virtual void searchEntriesCompleted(int result) = 0;

    // signal to KdbEntry object
    virtual void entryLoaded(int entryId,
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
                     QString friendlySize
                     ) = 0;
    virtual void entrySaved(int result) = 0;
    virtual void newEntryCreated(int result, int entryId) = 0;
    virtual void entryDeleted(int result) = 0;
    virtual void entryMoved(int result) = 0;

    // signal to KdbGroup object
    virtual void groupLoaded(QString title) = 0;
    virtual void groupSaved(int result) = 0;
    virtual void newGroupCreated(int result, int groupId) = 0;
    virtual void groupDeleted(int result) = 0;


public: // slots
    // signals from KdbDatabase object
    virtual void slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly) = 0;
    virtual void slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds) = 0;
    virtual void slot_closeDatabase() = 0;
    virtual void slot_changePassKey(QString password, QString keyFile) = 0;
    virtual void slot_changeKeyTransfRounds(int value) = 0;
    virtual void slot_changeCryptAlgorithm(int value) = 0;
    virtual void slot_setting_showUserNamePasswordsInListView(bool value) = 0;
    virtual void slot_setting_sortAlphabeticallyInListView(bool value) = 0;

    // signal from KdbListModel object
    virtual void slot_loadMasterGroups(bool registerListModel) = 0;
    virtual void slot_loadGroupsAndEntries(int groupId) = 0;
    virtual void slot_unregisterListModel(int modelId) = 0;
    virtual void slot_searchEntries(QString searchString, int rootGroupId) = 0;

    // signal from KdbEntry object
    virtual void slot_loadEntry(int entryId) = 0;
    virtual void slot_saveEntry(int entryId,
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
                             int parentGroupId) = 0;
    virtual void slot_deleteEntry(int entryId) = 0;
    virtual void slot_moveEntry(int entryId, int newGroupId) = 0;

    // signal from KdbGroup object
    virtual void slot_loadGroup(int groupId) = 0;
    virtual void slot_saveGroup(int groupId, QString title) = 0;
    virtual void slot_deleteGroup(int groupId) = 0;
    virtual void slot_createNewGroup(QString title, quint32 iconId, int parentGroupId) = 0;
};

Q_DECLARE_INTERFACE(AbstractDatabaseInterface, "harbour.ownkeepass.AbstractDatabaseInterface")

#endif // DATABASEINTERFACE_H
