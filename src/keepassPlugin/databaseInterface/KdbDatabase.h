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

#ifndef KDBDATABASE_H
#define KDBDATABASE_H

#include <QObject>
#include <QFile>

namespace kpxPublic {

class KdbDatabase : public QObject
{
    Q_OBJECT

public:
    Q_ENUMS(eResult)

    Q_PROPERTY(int keyTransfRounds READ keyTransfRounds WRITE setKeyTransfRounds NOTIFY keyTransfRoundsChanged)
    Q_PROPERTY(int cryptAlgorithm READ cryptAlgorithm WRITE setCryptAlgorithm NOTIFY cryptAlgorithmChanged)
    Q_PROPERTY(bool showUserNamePasswordsInListView
               READ showUserNamePasswordsInListView WRITE setShowUserNamePasswordsInListView
               STORED true SCRIPTABLE true)

public: // QtQuick 1.1 needs here a public keyword otherwise if does not find the next function ???
    Q_INVOKABLE void preCheck(const QString& dbFilePath, const QString &keyFilePath);
    Q_INVOKABLE void open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly);
    Q_INVOKABLE void create(const QString& dbFilePath, const QString &keyFilePath, const QString& password);
    Q_INVOKABLE void close();
    Q_INVOKABLE void changePassword(const QString& password);

public:
    enum eResult {
        RE_OK = 0,                                  // no error
        RE_DB_OPEN,                                 // other database is currently open, close it first
        RE_DB_ALREADY_CLOSED,                       // database already closed, no harm
        RE_DB_CLOSE_FAILED,                         // database closing failed
        RE_DB_FILE_ERROR,                           // file path error for new database
        RE_DB_SETPW_ERROR,                          // error setting password for database
        RE_DB_SETKEYFILE_ERROR,                     // error setting key file for database
        RE_DB_LOAD_ERROR,                           // error during loading and reading from database
        RE_DB_SAVE_ERROR,                           // error saving database on creation
        RE_DB_CREATE_BACKUPGROUP_ERROR,             // error creating backup group
        RE_PRECHECK_DB_PATH_ERROR,                  // database file does not exists on precheck
        RE_PRECHECK_KEY_FILE_PATH_ERROR,            // key file does not exists on precheck
        RE_PRECHECK_DB_PATH_CREATION_ERROR,         // path to database file could not be created
        RE_PRECHECK_KEY_FILE_PATH_CREATION_ERROR,   // path to key file could not be created
        RE_DB_SETKEYTRANSFROUNDS_FAILED,            // KeyTransfRounds could not be set in database

        RE_LAST
    };

    KdbDatabase(QObject* parent=0);
    virtual ~KdbDatabase() {}

    void setKeyTransfRounds(const int value) { emit changeDatabaseKeyTransfRounds(value); }
    int keyTransfRounds() const { return m_keyTransfRounds; }

    void setCryptAlgorithm(const int value) { emit changeDatabaseCryptAlgorithm(value); }
    int cryptAlgorithm() const { return m_cryptAlgorithm; }

    void setShowUserNamePasswordsInListView(bool value) {
        m_showUserNamePasswordsInListView = value;
        emit setting_showUserNamePasswordsInListView(value);
    }
    bool showUserNamePasswordsInListView() const { return m_showUserNamePasswordsInListView; }

signals:
    // signals to KdbInterface backend thread
    void preCheckFilePaths(QString dbFile, QString keyFile);
    void openDatabase(QString filePath, QString password, QString keyfile, bool readonly);
    void createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds);
    void closeDatabase();
    void changeDatabasePassword(QString password);
    void changeDatabaseKeyTransfRounds(int value);
    void changeDatabaseCryptAlgorithm(int value);
    void setting_showUserNamePasswordsInListView(bool value);

    // signals to QML
    void preCheckDone(int result);
    void databaseOpened(int result, QString errorMsg);
    void newDatabaseCreated(int result, QString errorMsg);
    void databaseClosed(int result, QString errorMsg);
    void databasePasswordChanged(int result, QString errorMsg);
    void keyTransfRoundsChanged();
    void cryptAlgorithmChanged();

private slots:
    // signals from KdbInterface backend thread
    void slot_databaseKeyTransfRoundsChanged(int value) {
        if (value != m_keyTransfRounds) {
            m_keyTransfRounds = value;
            emit keyTransfRoundsChanged();
        }
    }
    void slot_databaseCryptAlgorithmChanged(int value) {
        if (value != m_cryptAlgorithm) {
            m_cryptAlgorithm = value;
            emit cryptAlgorithmChanged();
        }
    }

private:
    // the following properties are read from backend and therefore there are slots for it
    int m_keyTransfRounds;
    int m_cryptAlgorithm;
    // settings are simply passed over to the backend thread
    bool m_showUserNamePasswordsInListView;

    Q_DISABLE_COPY(KdbDatabase)
};

}
#endif // KDBDATABASE_H
