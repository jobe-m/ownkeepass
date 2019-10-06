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
    m_keyTransfRounds(15),
    m_cryptAlgorithm(0),
    m_keyDerivationFunction(0),
    m_showUserNamePasswordsInListView(false),
    m_readOnly(false),
    m_connected(false)
{}

void KdbDatabase::connectToDatabaseClient()
{
    // connect signals and slots to global DatabaseClient class
    bool ret = connect(this,
                       SIGNAL(openDatabase(QString,QString,QString,bool)),
                       DatabaseClient::getInstance()->getInterface(),
                       SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseOpened(int,QString)),
                  this,
                  SLOT(slot_databaseOpened(int,QString)));
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
                  SIGNAL(changeDatabaseSettings(int,int,int)),
                  DatabaseClient::getInstance()->getInterface(),
                  SLOT(slot_changeDatabaseSettings(int,int,int)));
    Q_ASSERT(ret);
    ret = connect(DatabaseClient::getInstance()->getInterface(),
                  SIGNAL(databaseSettingsChanged(int,int,int)),
                  this,
                  SLOT(slot_databaseSettingsChanged(int,int,int)));
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
    emit typeChanged();
}

void KdbDatabase::open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readOnly)
{
    // check if a database is already open
    if (m_connected) {
// TODO add check for opened database
// TODO return error to QML saying that database is already open
        DatabaseClient::getInstance()->closeDatabaseInterface();
        m_connected = false;
    }

    DatabaseClient::getInstance()->initDatabaseInterface();
    connectToDatabaseClient();
    emit typeChanged();

    // send settings to new created database client interface
    emit setting_showUserNamePasswordsInListView(m_showUserNamePasswordsInListView);
    emit setting_sortAlphabeticallyInListView(m_sortAlphabeticallyInListView);

    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readOnly);
    if (m_readOnly != readOnly) {
        m_readOnly = readOnly;
        emit readOnlyChanged();
    }
}

void KdbDatabase::slot_databaseOpened(int result, QString errorMsg)
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
    emit databaseOpened(result, errorMsg);
}

void KdbDatabase::create(const QString& dbFilePath, const QString &keyFilePath, const QString& password)
{
    // check if a database is already open
    if (m_connected) {
// TODO add check for opened database
// TODO return error to QML saying that database is already open
        DatabaseClient::getInstance()->closeDatabaseInterface();
        m_connected = false;
    }

    DatabaseClient::getInstance()->initDatabaseInterface();
    connectToDatabaseClient();
    emit typeChanged();

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

void KdbDatabase::slot_databaseSettingsChanged(int cryptAlgo, int kdf, int rounds) {
    if (cryptAlgo != m_cryptAlgorithm) {
        m_cryptAlgorithm = cryptAlgo;
        emit cryptAlgorithmChanged();
    }
    if (kdf != m_keyDerivationFunction) {
        m_keyDerivationFunction = kdf;
        emit keyDerivationFunctionChanged();
    }
    if (rounds != m_keyTransfRounds) {
        m_keyTransfRounds = rounds;
        emit keyTransfRoundsChanged();
    }
}

void KdbDatabase::changePassword(const QString &password, const QString &keyFile)
{
    if (m_connected) {
        emit changeDatabasePassword(password, keyFile);
    }
}

void KdbDatabase::saveSettings()
{
    if (m_connected) {
        emit changeDatabaseSettings(m_cryptAlgorithm, m_keyDerivationFunction, m_keyTransfRounds);
    }
}
