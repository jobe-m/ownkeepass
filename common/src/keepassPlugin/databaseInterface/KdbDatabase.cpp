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

#include <QDebug>

#include "ownKeepassGlobal.h"
#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "private/DatabaseClient.h"

using namespace std;
using namespace kpxPublic;
using namespace kpxPrivate;
using namespace ownKeepassPublic;

KdbDatabase::KdbDatabase(QObject *parent):
    QObject(parent),
    // set default values
    m_keyTransfRounds(50000),
    m_cryptAlgorithm(0),
    m_showUserNamePasswordsInListView(false),
    m_readOnly(false),
    m_connected(false),
    m_database_type(DatabaseType::DB_TYPE_UNKNOWN)
{
}

void KdbDatabase::connectToDatabaseClient()
{
    // connect signals and slots to global DatabaseClient class
    bool ret = connect(this,
                       SIGNAL(openDatabase(QString,QString,QString,bool)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseOpened(int)),
                  this,
                  SLOT(slot_databaseOpened(int)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(createNewDatabase(QString,QString,QString,int,int)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_createNewDatabase(QString,QString,QString,int,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(newDatabaseCreated()),
                  this,
                  SIGNAL(newDatabaseCreated()));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(closeDatabase()),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_closeDatabase()));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseClosed()),
                  this,
                  SLOT(slot_databaseClosed()));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_setting_showUserNamePasswordsInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(setting_sortAlphabeticallyInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_setting_sortAlphabeticallyInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(changeDatabasePassword(QString,QString)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_changePassKey(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(passwordChanged()),
                  this,
                  SIGNAL(databasePasswordChanged()));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(changeDatabaseKeyTransfRounds(int)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_changeKeyTransfRounds(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseKeyTransfRoundsChanged(int)),
                  this,
                  SLOT(slot_databaseKeyTransfRoundsChanged(int)));
    Q_ASSERT(ret);
    ret = connect(this,
                  SIGNAL(changeDatabaseCryptAlgorithm(int)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_changeCryptAlgorithm(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseCryptAlgorithmChanged(int)),
                  this,
                  SLOT(slot_databaseCryptAlgorithmChanged(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(errorOccured(int,QString)),
                  this,
                  SIGNAL(errorOccured(int,QString)));
    Q_ASSERT(ret);

    m_connected = true;
}

void KdbDatabase::disconnectFromDatabaseClient()
{
    // disconnect all signals to backend
    bool ret = disconnect(this, 0, 0, 0);
    Q_ASSERT(ret);

    m_connected = false;
    m_database_type = DatabaseType::DB_TYPE_UNKNOWN;
}

void KdbDatabase::open(const int databaseType, const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly)
{
    // check if a database is already open
    if (m_connected) {
// TODO add check for opened database
// TODO return error to QML saying that database is already open
        DatabaseClient::getInstance()->closeDatabaseInterface();
        m_connected = false;
    }

    // first set up interface to database client
    Q_ASSERT((databaseType > DatabaseType::DB_TYPE_UNKNOWN) && (databaseType <= DatabaseType::DB_TYPE_KEEPASS_2));
    DatabaseClient::getInstance()->initDatabaseInterface(databaseType);
    connectToDatabaseClient();
    m_database_type = databaseType;

    // send settings to new created database client interface
    emit setting_showUserNamePasswordsInListView(m_showUserNamePasswordsInListView);
    emit setting_sortAlphabeticallyInListView(m_sortAlphabeticallyInListView);

    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readonly);
    if (m_readOnly != readonly) {
        m_readOnly = readonly;
        emit readOnlyChanged();
    }
}

void KdbDatabase::slot_databaseOpened(int result)
{
    if (result == DatabaseAccessResult::RE_DB_READ_ONLY) {
        if (!m_readOnly) {
            m_readOnly = true;
            emit readOnlyChanged();
        }
    } else {
        if (m_readOnly) {
            m_readOnly = false;
            emit readOnlyChanged();
        }
    }
    emit databaseOpened(result);
}

void KdbDatabase::create(const int databaseType, const QString& dbFilePath, const QString &keyFilePath, const QString& password)
{
    // check if a database is already open
    if (m_connected) {
// TODO add check for opened database
// TODO return error to QML saying that database is already open
        DatabaseClient::getInstance()->closeDatabaseInterface();
        m_connected = false;
    }

    // first set up interface to database client
    Q_ASSERT((databaseType > DatabaseType::DB_TYPE_UNKNOWN) && (databaseType <= DatabaseType::DB_TYPE_KEEPASS_2));
    DatabaseClient::getInstance()->initDatabaseInterface(databaseType);
    connectToDatabaseClient();
    m_database_type = databaseType;

    // send settings to new created database client interface
    emit setting_showUserNamePasswordsInListView(m_showUserNamePasswordsInListView);
    emit setting_sortAlphabeticallyInListView(m_sortAlphabeticallyInListView);

    // send signal to database client interface
    emit createNewDatabase(dbFilePath, password, keyFilePath, m_cryptAlgorithm, m_keyTransfRounds);
    m_readOnly = false;
}

void KdbDatabase::close()
{
    if (m_connected) {
        // if a database is opened forward to database client interface
        emit closeDatabase();
    } else {
        DatabaseClient::getInstance()->closeDatabaseInterface();
        // signal to QML
        emit databaseClosed();
    }
}

void KdbDatabase::slot_databaseClosed()
{
    disconnectFromDatabaseClient();
    DatabaseClient::getInstance()->closeDatabaseInterface();
    // signal to QML
    emit databaseClosed();
}

void KdbDatabase::changePassword(const QString &password, const QString &keyFile)
{
    if (m_connected) {
        emit changeDatabasePassword(password, keyFile);
    }
}
