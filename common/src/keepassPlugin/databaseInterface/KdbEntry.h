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

public:
    Q_INVOKABLE void loadEntryData();
    Q_INVOKABLE void saveEntryData(QString title,
                                   QString url,
                                   QString username,
                                   QString password,
                                   QString comment);
    Q_INVOKABLE void createNewEntry(QString title,
                                    QString url,
                                    QString username,
                                    QString password,
                                    QString comment,
                                    QString parentgroupId);
    Q_INVOKABLE void deleteEntry();
    Q_INVOKABLE void moveEntry(QString newGroupId);

signals:
    // signals to QML
    void entryDataLoaded(int result,
                         QList<QString> keys,
                         QList<QString> values);
    void entryDataSaved(int result);
    void newEntryCreated(int result, QString newEntryId);
    void entryDeleted(int result);
    void entryMoved(int result);

    // signals to interface of database client
    void loadEntryFromKdbDatabase(QString entryId);
    void saveEntryToKdbDatabase(QString entryId,
                                QString title,
                                QString url,
                                QString username,
                                QString password,
                                QString comment);
    void createNewEntryInKdbDatabase(QString title,
                                     QString url,
                                     QString username,
                                     QString password,
                                     QString comment,
                                     QString parentgroupId);
    void deleteEntryFromKdbDatabase(QString entryId);
    void moveEntryInKdbDatabase(QString entryId, QString newGroupId);

public slots:
    // signals from interface of database client
    void slot_entryDataLoaded(int result,
                              QString entryId,
                              QList<QString> keys,
                              QList<QString> values);
    void slot_entryDataSaved(int result, QString entryId);
    void slot_entryDeleted(int result, QString entryId);
    void slot_entryMoved(int result, QString entryId);
    void slot_newEntryCreated(int result, QString entryId);
    void slot_disconnectFromDatabaseClient();

public:
    KdbEntry(QObject *parent = 0);
    virtual ~KdbEntry();

    QString getEntryId() const { return m_entryId; }
    void setEntryId(const QString value) { m_entryId = value; }

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    QString m_entryId;
    bool m_connected;
    bool m_new_entry_triggered;
};

}
#endif // KDBENTRY_H
