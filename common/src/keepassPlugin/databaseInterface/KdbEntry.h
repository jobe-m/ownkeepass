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

#ifndef KDBENTRY_H
#define KDBENTRY_H

#include <QObject>
#include "private/AbstractDatabaseInterface.h"

namespace kpxPublic {

class KdbEntry : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString entryId READ getEntryId WRITE setEntryId STORED true SCRIPTABLE true)
    Q_PROPERTY(QString title READ getTitle WRITE setTitle STORED true SCRIPTABLE true)
    Q_PROPERTY(QString url READ getUrl WRITE setUrl STORED true SCRIPTABLE true)
    Q_PROPERTY(QString userName READ getUserName WRITE setUserName STORED true SCRIPTABLE true)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword STORED true SCRIPTABLE true)
    Q_PROPERTY(QString notes READ getNotes WRITE setNotes STORED true SCRIPTABLE true)
    Q_PROPERTY(QString iconUuid READ getIconUuid WRITE setIconUuid STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadEntryData();

    Q_INVOKABLE void saveEntryData();
    Q_INVOKABLE void createNewEntry(QString parentgroupId);
    Q_INVOKABLE void deleteEntry();
    Q_INVOKABLE void moveEntry(QString newGroupId);

signals:
    // signals to QML
    void entryDataLoaded(int result,
                         QString errorMsg);
    void entryDataSaved(int result,
                        QString errorMsg);
    void newEntryCreated(int result,
                         QString errorMsg,
                         QString newEntryId);
    void entryDeleted(int result,
                      QString errorMsg);
    void entryMoved(int result,
                    QString errorMsg);

    // signals to interface of database client
    void loadEntryFromKdbDatabase(QString entryId);
    void saveEntryToKdbDatabase(QString entryId,
                                QStringList keys,
                                QStringList values,
                                QString iconUuid);
    void createNewEntryInKdbDatabase(QStringList keys,
                                     QStringList values,
                                     QString parentgroupId,
                                     QString iconUuid);
    void deleteEntryFromKdbDatabase(QString entryId);
    void moveEntryInKdbDatabase(QString entryId, QString newGroupId);

public slots:
    // signals from interface of database client
    void slot_entryDataLoaded(int result,
                              QString errorMsg,
                              QString entryId,
                              QStringList keys,
                              QStringList values,
                              QString iconUuid);
    void slot_entryDataSaved(int result,
                             QString errorMsg,
                             QString entryId);
    void slot_entryDeleted(int result,
                           QString errorMsg,
                           QString entryId);
    void slot_entryMoved(int result,
                         QString errorMsg,
                         QString entryId);
    void slot_newEntryCreated(int result,
                              QString errorMsg,
                              QString entryId);
    void slot_disconnectFromDatabaseClient();

public:
    KdbEntry(QObject *parent = 0);
    virtual ~KdbEntry();

    QString getEntryId() const { return m_entryId; }
    void setEntryId(const QString value) { m_entryId = value; }
    QString getTitle() const { return m_title; }
    void setTitle(const String value) { m_title = value; }
    QString getUrl() const { return m_url; }
    void setUrl(const String value) { m_url = value; }
    QString getUserName() const { return m_userName; }
    void setUserName(const String value) { m_userName = value; }
    QString getPassword() const { return m_password; }
    void setPassword(const String value) { m_password = value; }
    QString getNotes() const { return m_notes; }
    void setNotes(const String value) { m_notes = value; }
    QString getIconUuid() const { return m_iconUuid; }
    void setIconUuid(const QString value) { m_iconUuid = value; }

private:
    void clearData();
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    QString m_entryId;
    QString m_title;
    QString m_url;
    QString m_userName;
    QString m_password;
    QString m_notes;
    QString m_iconUuid;

    bool m_connected;
    bool m_new_entry_triggered;
};

}
#endif // KDBENTRY_H
