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

#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "private/DatabaseClient.h"

using namespace std;
using namespace kpxPublic;
using namespace kpxPrivate;

KdbDatabase::KdbDatabase(QObject *parent):
    QObject(parent),
    // set default values
    m_keyTransfRounds(50000),
    m_cryptAlgorithm(0),
    m_showUserNamePasswordsInListView(false),
    m_readOnly(false),
    m_connected(false),
    m_database_type(DB_TYPE_UNKNOWN)
{
}

void KdbDatabase::connectToDatabaseClient()
{
    // connect signals and slots to global DatabaseClient class
    bool ret = connect(this, SIGNAL(openDatabase(QString,QString,QString,bool)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseOpened()),
                  this, SIGNAL(databaseOpened()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewDatabase(QString,QString,QString,int,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_createNewDatabase(QString,QString,QString,int,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(newDatabaseCreated()),
                  this, SIGNAL(newDatabaseCreated()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(closeDatabase()),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_closeDatabase()));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseClosed()),
                  this, SIGNAL(databaseClosed()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_setting_showUserNamePasswordsInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(setting_sortAlphabeticallyInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_setting_sortAlphabeticallyInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabasePassword(QString,QString)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changePassKey(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(passwordChanged()),
                  this, SIGNAL(databasePasswordChanged()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabaseKeyTransfRounds(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changeKeyTransfRounds(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseKeyTransfRoundsChanged(int)),
                  this, SLOT(slot_databaseKeyTransfRoundsChanged(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabaseCryptAlgorithm(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changeCryptAlgorithm(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseCryptAlgorithmChanged(int)),
                  this, SLOT(slot_databaseCryptAlgorithmChanged(int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(), SIGNAL(errorOccured(int,QString)),
                  this, SIGNAL(errorOccured(int,QString)));
    Q_ASSERT(ret);
}

void KdbDatabase::open(const int databaseType, const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly)
{
    // check if a database is already open
    if (m_connected) {
// TODO
        emit databaseOpened(/* RE_DB_OPEN*/);
        return;
    }
    // first set up interface to database client
    Q_ASSERT((databaseType > DB_TYPE_UNKNOWN) && (databaseType <= DB_TYPE_KEEPASS_2));
    DatabaseClient::getInstance()->initDatabaseInterface(databaseType);
    connectToDatabaseClient();
    m_database_type = databaseType;

    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readonly);
    m_readOnly = readonly;
    m_connected = true;
}

void KdbDatabase::create(const int databaseType, const QString& dbFilePath, const QString &keyFilePath, const QString& password)
{
    // check if a database is already open
    if (m_connected) {
// TODO
        emit newDatabaseCreated(/* RE_DB_OPEN*/);
        return;
    }
    // first set up interface to database client
    Q_ASSERT((databaseType > DB_TYPE_UNKNOWN) && (databaseType >= DB_TYPE_KEEPASS_2));
    DatabaseClient::getInstance()->initDatabaseInterface(databaseType);
    connectToDatabaseClient();
    m_database_type = databaseType;

    // send signal to the global Keepass database interface component
    emit createNewDatabase(dbFilePath, password, keyFilePath, m_cryptAlgorithm, m_keyTransfRounds);
    m_readOnly = false;
    m_connected = true;
}

void KdbDatabase::close()
{
    emit closeDatabase();
}

void KdbDatabase::changePassword(const QString &password, const QString &keyFile)
{
    emit changeDatabasePassword(password, keyFile);
}

void KdbDatabase::slot_databaseClosed()
{
    // disconnect all signals
    // connect signals and slots to global DatabaseClient class
    bool ret = disconnect(this, SIGNAL(openDatabase(QString,QString,QString,bool)),
                       DatabaseClient::getInstance()->getInterface(), SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseOpened()),
                  this, SIGNAL(databaseOpened()));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(createNewDatabase(QString,QString,QString,int,int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_createNewDatabase(QString,QString,QString,int,int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(newDatabaseCreated()),
                  this, SIGNAL(newDatabaseCreated()));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(closeDatabase()),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_closeDatabase()));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseClosed()),
                  this, SLOT(slot_databaseClosed()));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_setting_showUserNamePasswordsInListView(bool)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(setting_sortAlphabeticallyInListView(bool)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_setting_sortAlphabeticallyInListView(bool)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(changeDatabasePassword(QString,QString)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changePassKey(QString,QString)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(passwordChanged()),
                  this, SIGNAL(databasePasswordChanged()));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(changeDatabaseKeyTransfRounds(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changeKeyTransfRounds(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseKeyTransfRoundsChanged(int)),
                  this, SLOT(slot_databaseKeyTransfRoundsChanged(int)));
    Q_ASSERT(ret);
    ret = disconnect(this, SIGNAL(changeDatabaseCryptAlgorithm(int)),
                  DatabaseClient::getInstance()->getInterface(), SLOT(slot_changeCryptAlgorithm(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(databaseCryptAlgorithmChanged(int)),
                  this, SLOT(slot_databaseCryptAlgorithmChanged(int)));
    Q_ASSERT(ret);
    ret = disconnect(DatabaseClient::getInstance()->getInterface(), SIGNAL(errorOccured(int,QString)),
                  this, SIGNAL(errorOccured(int,QString)));
    Q_ASSERT(ret);

    m_connected = false;
    m_database_type = DB_TYPE_UNKNOWN;
}
