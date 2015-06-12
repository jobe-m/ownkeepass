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

class KdbEntry : public QObject, public DatabaseDefines
{
    Q_OBJECT
    Q_INTERFACES(DatabaseDefines)

public:
    Q_ENUMS(eDatabaseAccessResult)

    Q_PROPERTY(int entryId READ getEntryId WRITE setEntryId STORED true SCRIPTABLE true)

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
                                    int parentgroupId);
    Q_INVOKABLE void deleteEntry();
    Q_INVOKABLE void moveEntry(int newGroupId);

signals:
    // signals to QML
    void entryDataLoaded(int result,
                         QString title,
                         QString url,
                         QString username,
                         QString password,
                         QString comment,
                         QString binaryDesc,
                         QString creation,
                         QString lastMod,
                         QString lastAccess,
                         QString expire,
                         quint32 binarySize,
                         QString friendlySize
                         );
    void entryDataSaved(int result);
    void newEntryCreated(int result, int newEntryId);
    void entryDeleted(int result);
    void entryMoved(int result);

    // signals to interface of database client
    void loadEntryFromKdbDatabase(int entryId);
    void saveEntryToKdbDatabase(int entryId,
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
                                     int parentgroupId);
    void deleteEntryFromKdbDatabase(int entryId);
    void moveEntryInKdbDatabase(int entryId, int newGroupId);

public slots:
    // signals from interface of database client
    void slot_entryDataLoaded(int result,
                              int entryId,
                              QString title,
                              QString url,
                              QString username,
                              QString password,
                              QString comment,
                              QString binaryDesc,
                              QString creation,
                              QString lastMod,
                              QString lastAccess,
                              QString expire,
                              quint32 binarySize,
                              QString friendlySize);
    void slot_entryDataSaved(int result, int entryId);
    void slot_entryDeleted(int result, int entryId);
    void slot_entryMoved(int result, int entryId);
    void slot_newEntryCreated(int result, int entryId);
    void slot_disconnectFromDatabaseClient();

public:
    KdbEntry(QObject *parent = 0);
    virtual ~KdbEntry() {}

    int getEntryId() const { return m_entryId; }
    void setEntryId(const int value) { m_entryId = value; }

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    int m_entryId;
    bool m_connected;
    bool m_new_entry_triggered;
};

}
#endif // KDBENTRY_H
