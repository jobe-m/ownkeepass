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
#include <QStringList>
#include <QImage>


// Interface for accessing a database
class AbstractDatabaseInterface
{
public:
    virtual ~AbstractDatabaseInterface(){}

protected: // signals
    // signals to all objects
    virtual void disconnectAllClients() = 0;

    // signals to KdbDatabase object

    /// \brief The databaseOpened() signal is emmitted after calling
    /// slot_openDatabase(). It signals that opening of the Keepass database is finished.
    /// If database could be opened successfully (result is RE_OK or
    /// RE_DB_READ_ONLY) other database access operations can be used like
    /// slot_loadMasterGroups() or slot_loadEntry().
    ///
    /// \param result: This parameter is set to one of the following error codes:
    ///   \li \c RE_OK if no error happened, database can be opened
    ///   \li \c RE_DB_READ_ONLY if database file is read-only, database can be
    ///          opened
    ///   \li \c RE_NOT_A_KEEPASS_DB if the file is not a KeePass database
    ///          (Keepass 2 only)
    ///   \li \c RE_NOT_SUPPORTED_DB_VERSION if the file contains an unsupported
    ///          KeePass database version (Keepass 2 only)
    ///        \li \c RE_MISSING_DB_HEADERS if database headers are missing (Keepass 2
    ///          only)
    ///        \li \c RE_WRONG_PASSWORD_OR_DB_IS_CORRUPT if wrong master password was
    ///          specified or if database file is corrupt
    ///   \li \c     RE_WRONG_PASSWORD_OR_KEYFILE_OR_DB_IS_CORRUPT if wrong master
    ///          password or wrong keyfile was specified or if either keyfile or
    ///          database file is corrupt
    ///   \li \c     RE_HEAD_HASH_MISMATCH if database head doesn't match corresponding
    ///          hash value (Keepass 2 only)
    ///   \li \c     RE_DBFILE_OPEN_ERROR if database file cannot be opened, more
    ///          detailed error message available in errorMsg (Keepass 2 only)
    ///   \li \c     RE_KEYFILE_OPEN_ERROR if key file cannot be opened, more detailed
    ///          error message available in errorMsg (Keepass 2 only)
    ///
    /// \param errorMsg: This paramter is a string containing more details about the error or
    ///        is empty if no further details are available.
    ///
    virtual void databaseOpened(int result, QString errorMsg) = 0;
    virtual void newDatabaseCreated() = 0;
    virtual void databaseClosed() = 0;
    virtual void passwordChanged() = 0;
    virtual void databaseKeyTransfRoundsChanged(int value) = 0;
    virtual void databaseCryptAlgorithmChanged(int value) = 0;

    /// \brief The errorOccured() signal is emitted whenever an internal error
    /// occured. Refer to the result list for the severity of the error and if
    /// accessing the database is still possible.
    ///
    /// \param result is one from the folloing list:
    ///        RE_ERR_QSTRING_TO_UUID QString value is not exactly 16 characters
    ///          long and cannot be converted successfully (Keepass 2 only)
    ///          Access to database is still possible. Severity low.
    ///        RE_ERR_QSTRING_TO_INT Conversion from QString to integer number
    ///          failed (Keepass 1 only)
    ///          Access to database is still possible. Severity low.
    ///        RE_CRYPTO_INIT_ERROR Cryptographic algorithms could not be
    ///          initialized successfully, abort opening of any Keepass database
    ///          for safety (Keepass 2 only)
    ///          Severity high.
    ///
    virtual void errorOccured(int result,
                              QString errorMsg) = 0;

    // signals to KdbListModel object
    virtual void appendItemToListModel(QString title,
                                       QString iconUuid,
                                       QString subtitle,
//                                       int numberOfSubGroups,
//                                       int numberOfEntries,
                                       QString itemId,
                                       int itemType,
                                       int itemLevel,
                                       QString modelId) = 0;
    virtual void addItemToListModelSorted(QString title,
                                          QString iconUuid,
                                          QString subtitle,
//                                          int numberOfSubGroups,
//                                          int numberOfEntries,
                                          QString itemId,
                                          int itemType,
                                          int itemLevel,
                                          QString modelId) = 0;
    virtual void updateItemInListModel(QString title,
                                       QString iconUuid,
                                       QString subTitle,
//                                       int numberOfSubGroups,
//                                       int numberOfEntries,
                                       QString itemId,
                                       QString modelId) = 0;
    virtual void updateItemInListModelSorted(QString title,
                                             QString iconUuid,
                                             QString subTitle,
//                                             int numberOfSubGroups,
//                                             int numberOfEntries,
                                             QString itemId,
                                             QString modelId) = 0;
    virtual void masterGroupsLoaded(int result,
                                    QString errorMsg) = 0;
    virtual void groupsAndEntriesLoaded(int result,
                                        QString errorMsg) = 0;
    virtual void deleteItemInListModel(QString itemId) = 0;
    virtual void searchEntriesCompleted(int result,
                                        QString errorMsg) = 0;

    // signal to KdbEntry object
    virtual void entryLoaded(int result,
                             QString errorMsg,
                             QString entryId,
                             QStringList keys,
                             QStringList values,
                             QString iconUuid) = 0;
    virtual void entrySaved(int result,
                            QString errorMsg,
                            QString entryId) = 0;
    virtual void newEntryCreated(int result,
                                 QString errorMsg,
                                 QString entryId) = 0;
    virtual void entryDeleted(int result,
                              QString errorMsg,
                              QString entryId) = 0;
    virtual void entryMoved(int result,
                            QString errorMsg,
                            QString entryId) = 0;

    // signal to KdbGroup object
    virtual void groupLoaded(int result,
                             QString errorMsg,
                             QString groupId,
                             QString title,
                             QString notes,
                             QString iconUuid) = 0;
    virtual void groupSaved(int result,
                            QString errorMsg,
                            QString groupId) = 0;
    virtual void newGroupCreated(int result,
                                 QString errorMsg,
                                 QString groupId) = 0;
    virtual void groupDeleted(int result,
                              QString errorMsg,
                              QString groupId) = 0;
    virtual void groupMoved(int result,
                            QString errorMsg,
                            QString groupId) = 0;

    // signal to KeepassIcon
    virtual void appendCustomIconToListModel(QString uuid) = 0;

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
                                QStringList keys,
                                QStringList values,
                                QStringList keysToDelete,
                                QString iconUuid) = 0;
    virtual void slot_createNewEntry(QStringList keys,
                                     QStringList values,
                                     QString parentGroupId,
                                     QString iconUuid) = 0;
    virtual void slot_deleteEntry(QString entryId) = 0;
    virtual void slot_moveEntry(QString entryId,
                                QString newGroupId) = 0;

    // signal from KdbGroup object
    virtual void slot_loadGroup(QString groupId) = 0;
    virtual void slot_saveGroup(QString groupId,
                                QString title,
                                QString notes,
                                QString iconUuid) = 0;
    virtual void slot_createNewGroup(QString title,
                                     QString notes,
                                     QString parentGroupId,
                                     QString iconUuid) = 0;
    virtual void slot_deleteGroup(QString groupId) = 0;
    virtual void slot_moveGroup(QString groupId,
                                QString newParentGroupId) = 0;

    // signal from KeepassIcon
    virtual void slot_loadCustomIcons() = 0;

public:
    /// \brief The getCustomIcon function returns a custom database icon
    /// with the Uuid represented as the QString value.
    ///
    /// \param value
    /// \returns A custom database icon as QImage or an empty QImage if the Uuid is not valid.
    ///
    virtual const QImage getCustomIcon(const QString value) = 0;
};

Q_DECLARE_INTERFACE(AbstractDatabaseInterface, "harbour.ownkeepass.AbstractDatabaseInterface")

#endif // DATABASEINTERFACE_H
