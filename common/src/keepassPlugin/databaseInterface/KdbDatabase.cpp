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
#include "private/KdbInterface.h"

using namespace std;
using namespace kpxPublic;
using namespace kpxPrivate;

KdbDatabase::KdbDatabase(QObject *parent):
    QObject(parent),
    // set default values
    m_keyTransfRounds(50000),
    m_cryptAlgorithm(0),
    m_showUserNamePasswordsInListView(false),
    m_isLocked(false),
    m_dbFilePath(""),
    m_keyFilePath(""),
    m_readOnly(false)
{
    // connect signals and slots to global KdbInterface class
    bool ret = connect(this, SIGNAL(openDatabase(QString,QString,QString,bool)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseOpened()),
                  this, SIGNAL(databaseOpened()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewDatabase(QString,QString,QString,int,int)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_createNewDatabase(QString,QString,QString,int,int)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(newDatabaseCreated()),
                  this, SIGNAL(newDatabaseCreated()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(closeDatabase()),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_closeDatabase()));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseClosed()),
                  this, SIGNAL(databaseClosed()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_setting_showUserNamePasswordsInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabasePassword(QString,QString)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_changePassKey(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(passwordChanged()),
                  this, SIGNAL(databasePasswordChanged()));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabaseKeyTransfRounds(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_changeKeyTransfRounds(int)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseKeyTransfRoundsChanged(int)),
                     this, SLOT(slot_databaseKeyTransfRoundsChanged(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabaseCryptAlgorithm(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_changeCryptAlgorithm(int)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseCryptAlgorithmChanged(int)),
                     this, SLOT(slot_databaseCryptAlgorithmChanged(int)));
    Q_ASSERT(ret);
    ret = connect(KdbInterface::getInstance()->getWorker(), SIGNAL(errorOccured(int,QString)),
                     this, SIGNAL(errorOccured(int,QString)));
    Q_ASSERT(ret);
}

void KdbDatabase::open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly)
{
    qDebug() << "KdbDatabase::open()";
    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readonly);
    m_dbFilePath = dbFilePath;
    m_keyFilePath = keyFilePath;
    m_readOnly = readonly;
}

void KdbDatabase::create(const QString& dbFilePath, const QString &keyFilePath, const QString& password)
{
    qDebug() << "KdbDatabase::create()";
    // send signal to the global Keepass database interface component
    emit createNewDatabase(dbFilePath, password, keyFilePath, m_cryptAlgorithm, m_keyTransfRounds);
    m_dbFilePath = dbFilePath;
    m_keyFilePath = keyFilePath;
    m_readOnly = false;
}

void KdbDatabase::close()
{
    m_isLocked = false;
    m_dbFilePath = "";
    m_keyFilePath = "";
    emit closeDatabase();
}

void KdbDatabase::lock()
{
    // Lock database means saving database and key file path and closing database
    if (!m_isLocked) {
        m_isLocked = true;
        emit closeDatabase();
    }
}

void KdbDatabase::unlock(const QString& password)
{
    // Unlock database means open the saved database again
    if (m_isLocked) {
        emit openDatabase(m_dbFilePath, password, m_keyFilePath, m_readOnly);
    }
}

void KdbDatabase::changePassword(const QString &password, const QString &keyFile)
{
    emit changeDatabasePassword(password, keyFile);
}
