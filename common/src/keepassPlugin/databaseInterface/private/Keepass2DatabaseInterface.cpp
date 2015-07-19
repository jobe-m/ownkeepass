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

#include <QDebug>
#include "Keepass2DatabaseInterface.h"
#include "../KdbListModel.h"
#include "../KdbGroup.h"
#include "crypto/Crypto.h"
#include "format/KeePass2Reader.h"
#include "keys/PasswordKey.h"
#include "keys/FileKey.h"
#include "core/Group.h"


using namespace kpxPrivate;
using namespace kpxPublic;


Keepass2DatabaseInterface::Keepass2DatabaseInterface(QObject *parent)
    : QObject(parent),
      m_Database(NULL),
      m_setting_showUserNamePasswordsInListView(false),
      m_setting_sortAlphabeticallyInListView(true),
      m_rootGroupId(0)
{
    initDatabase();
}

Keepass2DatabaseInterface::~Keepass2DatabaseInterface()
{
    qDebug("Destructor Keepass2DatabaseInterface");
    delete m_Database;
}

void Keepass2DatabaseInterface::initDatabase()
{
    // init crypto algorithms
    if (!Crypto::init()) {
        // Fatal error while testing the cryptographic functions
// TODO add error handling
    }

}

void Keepass2DatabaseInterface::slot_openDatabase(QString filePath, QString password, QString keyfile, bool readonly)
{
    // check if filePath is readable or read-writable
    QFile file(filePath);
    if (readonly) {
        if (!file.open(QIODevice::ReadOnly)) {
            qDebug() << "ERROR: Keepass 2 database is not readable!";
// TODO: return signal with error type
            return;
        }
    } else {
        if (!file.open(QIODevice::ReadWrite)) {
            qDebug() << "ERROR: Keepass 2 databasse is not read-writeable!";
// TODO: return signal with error type
            return;
        }
    }

    CompositeKey masterKey;
    masterKey.addKey(PasswordKey(password));
    if (!keyfile.isEmpty()) {
        FileKey key;
        QString errorMsg;
        if (!key.load(keyfile, &errorMsg)) {
            qDebug() << "ERROR: Cannot open key file for Keepass 2 database. " << errorMsg;
//            MessageBox::warning(this, tr("Error"), tr("Can't open key file").append(":\n").append(errorMsg));
// TODO: return signal with error type
            return;
        }
        masterKey.addKey(key);
    }

    if (m_Database) {
        delete m_Database;
    }

    KeePass2Reader reader;
    m_Database = reader.readDatabase(&file, masterKey);

// TODO check if .lock file exists and ask user if he wants to open the database in read only mode or discard and open in read/write mode
// TODO create .lock file if it does not exist yet

    // database was opened successfully
    emit databaseOpened();

    // load used encryption and KeyTransfRounds and sent to KdbDatabase object so that it is shown in UI database settings page
    emit databaseCryptAlgorithmChanged(0); // Keepass2 only supports Rijndael_Cipher = 0
    emit databaseKeyTransfRoundsChanged(m_Database->transformRounds());

    qDebug() << "Keepass 2 database successfully opened!";
}

void Keepass2DatabaseInterface::slot_closeDatabase()
{
}

void Keepass2DatabaseInterface::slot_createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds)
{
}

void Keepass2DatabaseInterface::slot_changePassKey(QString password, QString keyFile)
{
}

void Keepass2DatabaseInterface::slot_loadMasterGroups(bool registerListModel)
{
    Q_ASSERT(m_Database);

    QList<Group*> masterGroups = m_Database->rootGroup()->children();
    for (int i = 0; i < masterGroups.count(); i++) {
        Group* masterGroup = masterGroups.at(i);
        qDebug() << "Mastergroup " << i << ": " << masterGroup->name();
        qDebug() << "Expanded: " << masterGroup->isExpanded();

        int numberOfSubgroups = masterGroup->children().count();
        int numberOfEntries = masterGroup->entries().count();

        int listModelId = 0; // root group has list model ID 0
        bool ok;
        int masterGroupId = masterGroup->uuid().toByteArray().toInt(&ok, 16);
        if (registerListModel) {
            // save modelId and master group only if needed
            // i.e. save model list id for master group page and don't do it for list models used in dialogs
            if (ok) {
                m_groups_modelId.insertMulti(listModelId, masterGroupId);
                qDebug() << "QByteArray: " << masterGroup->uuid().toByteArray();
                qDebug() << "to Int: " << masterGroupId;
            } else {
                qDebug() << "Error: UUID conversation was not successfull!";
// TODO: add error handling
//                emit masterGroupsLoaded(RE_ERR_UUID_HANDLING);
            }
        }
        emit appendItemToListModel(masterGroup->name(),                           // group name
                                   QString("Subgroups: %1 | Entries: %2 | %3")
                                   .arg(numberOfSubgroups)
                                   .arg(numberOfEntries)
                                   .arg(masterGroup->notes()),                     // subtitle
                                   masterGroupId,                                  // item id
                                   GROUP,                                          // item type
                                   0,                                              // item level (0 = root, 1 = first level, etc.
                                   listModelId);                                   // list model of root group
    }
    emit masterGroupsLoaded(RE_OK);
}

void Keepass2DatabaseInterface::slot_loadGroupsAndEntries(int groupId)
{
}

void Keepass2DatabaseInterface::slot_loadEntry(int entryId)
{
}

void Keepass2DatabaseInterface::slot_loadGroup(int groupId)
{
}

void Keepass2DatabaseInterface::slot_saveGroup(int groupId, QString title)
{
}

void Keepass2DatabaseInterface::slot_unregisterListModel(int modelId)
{
    // delete all groups and entries which are associated with given modelId
    m_groups_modelId.remove(modelId);
    m_entries_modelId.remove(modelId);
}

void Keepass2DatabaseInterface::slot_createNewGroup(QString title, quint32 iconId, int parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_saveEntry(int entryId,
                                        QString title,
                                        QString url,
                                        QString username,
                                        QString password,
                                        QString comment)
{
    Q_ASSERT(m_Database);
    Q_ASSERT(entryId);
}

void Keepass2DatabaseInterface::slot_createNewEntry(QString title,
                                             QString url,
                                             QString username,
                                             QString password,
                                             QString comment,
                                             int parentGroupId)
{
}

void Keepass2DatabaseInterface::slot_deleteGroup(int groupId)
{
}

//void Keepass2DatabaseInterface::updateGrandParentGroupInListModel(IGroupHandle* parentGroup)
//{
//}

void Keepass2DatabaseInterface::slot_deleteEntry(int entryId)
{
}

void Keepass2DatabaseInterface::slot_moveEntry(int entryId, int newGroupId)
{
}

void Keepass2DatabaseInterface::slot_moveGroup(int groupId, int newParentGroupId)
{
}

void Keepass2DatabaseInterface::slot_searchEntries(QString searchString, int rootGroupId)
{
}

//inline QString Keepass2DatabaseInterface::getUserAndPassword(IEntryHandle* entry)
//{
//}

void Keepass2DatabaseInterface::slot_changeKeyTransfRounds(int value)
{
}

void Keepass2DatabaseInterface::slot_changeCryptAlgorithm(int value)
{
}
