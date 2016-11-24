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

#ifndef KEEPASS2DATABASEINTERFACE_H
#define KEEPASS2DATABASEINTERFACE_H

#include <QObject>
#include "AbstractDatabaseInterface.h"
#include "../KdbDatabase.h"
#include "../KdbListModel.h"
#include "core/Database.h"
#include "core/Uuid.h"

using namespace kpxPublic;

namespace kpxPrivate {

class Keepass2DatabaseInterface : public QObject, public AbstractDatabaseInterface
{
    Q_OBJECT
    Q_INTERFACES(AbstractDatabaseInterface)

public:
    explicit Keepass2DatabaseInterface(QObject* parent = 0);
    virtual ~Keepass2DatabaseInterface();

signals:
    // signals to all objects
    void disconnectAllClients();

    // signals to KdbDatabase object
    void databaseOpened(int result, QString errorMsg);
    void newDatabaseCreated();
    void databaseClosed();
    void passwordChanged();
    void databaseKeyTransfRoundsChanged(int value);
    void databaseCryptAlgorithmChanged(int value);
    void errorOccured(int result,
                      QString errorMsg);

    // signals to KdbListModel object
    void appendItemToListModel(QString title,
                               quint32 iconId,
                               QString subtitle,
                               QString itemId,
                               int itemType,
                               int itemLevel,
                               QString modelId);
    void addItemToListModelSorted(QString title,
                                  quint32 iconId,
                                  QString subtitle,
                                  QString itemId,
                                  int itemType,
                                  int itemLevel,
                                  QString modelId);
    void updateItemInListModel(QString title,
                               quint32 iconId,
                               QString subTitle,
                               QString itemId,
                               QString modelId);
    void updateItemInListModelSorted(QString title,
                                     quint32 iconId,
                                     QString subTitle,
                                     QString itemId,
                                     QString modelId);
    void masterGroupsLoaded(int result);
    void groupsAndEntriesLoaded(int result);
    void deleteItemInListModel(QString itemId);
    void searchEntriesCompleted(int result);

    // signal to KdbEntry object
    void entryLoaded(int result,
                     QString entryId,
                     QList<QString> keys,
                     QList<QString> values);
    void entrySaved(int result,
                    QString entryId);
    void newEntryCreated(int result,
                         QString entryId);
    void entryDeleted(int result,
                      QString entryId);
    void entryMoved(int result,
                    QString entryId);

    // signal to KdbGroup object
    void groupLoaded(int result,
                     QString groupId,
                     QString title);
    void groupSaved(int result,
                    QString groupId);
    void newGroupCreated(int result,
                         QString groupId);
    void groupDeleted(int result,
                      QString groupId);
    void groupMoved(int result,
                    QString groupId);

public slots:
    // signals from KdbDatabase object
    void slot_openDatabase(QString filePath,
                           QString password,
                           QString keyfile,
                           bool readonly);
    void slot_createNewDatabase(QString filePath,
                                QString password,
                                QString keyfile,
                                int cryptAlgorithm,
                                int keyTransfRounds);
    void slot_closeDatabase();
    void slot_changePassKey(QString password,
                            QString keyFile);
    void slot_changeKeyTransfRounds(int value);
    void slot_changeCryptAlgorithm(int value);
    void slot_setting_showUserNamePasswordsInListView(bool value) { m_setting_showUserNamePasswordsInListView = value; }
    void slot_setting_sortAlphabeticallyInListView(bool value) { m_setting_sortAlphabeticallyInListView = value; }

    // signal from KdbListModel object
    void slot_loadMasterGroups(bool registerListModel);
    void slot_loadGroupsAndEntries(QString groupId);
    void slot_unregisterListModel(QString modelId);
    void slot_searchEntries(QString searchString,
                            QString rootGroupId);

    // signal from KdbEntry object
    void slot_loadEntry(QString entryId);
    void slot_saveEntry(QString entryId,
                        QString title,
                        QString url,
                        QString username,
                        QString password,
                        QString comment);
    void slot_createNewEntry(QString title,
                             QString url,
                             QString username,
                             QString password,
                             QString comment,
                             QString parentGroupId);
    void slot_deleteEntry(QString entryId);
    void slot_moveEntry(QString entryId,
                        QString newGroupId);

    // signal from KdbGroup object
    void slot_loadGroup(QString groupId);
    void slot_saveGroup(QString groupId,
                        QString title);
    void slot_createNewGroup(QString title,
                             quint32 iconId,
                             QString parentGroupId);
    void slot_deleteGroup(QString groupId);
    void slot_moveGroup(QString groupId,
                        QString newParentGroupId);

public:
    void getCustomIcon(QString value);

private:
    void initDatabase();
//    void updateGrandParentGroupInListModel(IGroupHandle* parentGroup);
    inline QString getUserAndPassword(Entry* entry);
    inline Uuid qString2Uuid(QString value);
    inline QString uInt2QString(uint value);

private:
    // Keepass database handler
    Database* m_Database;

    // settings
    bool m_setting_showUserNamePasswordsInListView;
    bool m_setting_sortAlphabeticallyInListView;

    // The following two hash tables store information about which list models are showing a dedicated entry or group in the UI
    QHash<Uuid, Uuid> m_entries_modelId;
    QHash<Uuid, Uuid> m_groups_modelId;
    int m_rootGroupId;
};

}
#endif // KEEPASS2DATABASEINTERFACE_H
