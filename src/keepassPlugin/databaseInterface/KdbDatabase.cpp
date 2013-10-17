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

#include <QtDeclarative/qdeclarative.h>
#include <QDebug>

#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "private/KdbInterface.h"

using namespace std;
using namespace kpxPublic;
using namespace kpxPrivate;

// reference to global interface of Keepass database
extern KdbInterface* databaseInterface;

KdbDatabase::KdbDatabase(QObject *parent):
    QObject(parent),
    m_showUserNamePasswordsInListView(false)
{
    // connect signals and slots to global KdbInterface class
    Q_ASSERT(databaseInterface);
    bool ret = connect(this, SIGNAL(preCheckFilePaths(QString,QString)),
                       databaseInterface->worker(), SLOT(slot_preCheckFilePaths(QString,QString)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(preCheckFilePathsDone(int)),
                  this, SIGNAL(preCheckDone(int)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(openDatabase(QString,QString,QString,bool)),
                  databaseInterface->worker(), SLOT(slot_openDatabase(QString,QString,QString,bool)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(databaseOpened(int,QString)),
                  this, SIGNAL(databaseOpened(int,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(createNewDatabase(QString,QString,QString,int)),
                  databaseInterface->worker(), SLOT(slot_createNewDatabase(QString,QString,QString,int)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(newDatabaseCreated(int,QString)),
                  this, SIGNAL(newDatabaseCreated(int,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(closeDatabase()),
                  databaseInterface->worker(), SLOT(slot_closeDatabase()));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(databaseClosed(int,QString)),
                  this, SIGNAL(databaseClosed(int,QString)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  databaseInterface->worker(), SLOT(slot_setting_showUserNamePasswordsInListView(bool)));
    Q_ASSERT(ret);
    ret = connect(this, SIGNAL(changeDatabasePassword(QString)),
                  databaseInterface->worker(), SLOT(slot_changePassword(QString)));
    Q_ASSERT(ret);
    ret = connect(databaseInterface->worker(), SIGNAL(passwordChanged(int,QString)),
                  this, SIGNAL(databasePasswordChanged(int,QString)));
    Q_ASSERT(ret);
}

void KdbDatabase::preCheck(const QString& dbFilePath, const QString &keyFilePath)
{
    qDebug() << "KdbDatabase::preCheck()";
    emit preCheckFilePaths(dbFilePath, keyFilePath);
}

void KdbDatabase::open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly)
{
    qDebug() << "KdbDatabase::open()";
    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readonly);
}

void KdbDatabase::create(const QString& dbFilePath, const QString &keyFilePath, const QString& password, int cryptAlgorithm)
{
    qDebug() << "KdbDatabase::create()";
    // send signal to the global Keepass database interface component
    emit createNewDatabase(dbFilePath, password, keyFilePath, cryptAlgorithm);
}

void KdbDatabase::close()
{
    emit closeDatabase();
}

void KdbDatabase::changePassword(const QString &password)
{
    emit changeDatabasePassword(password);
}
