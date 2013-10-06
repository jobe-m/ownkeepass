/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of KeepassMe.
**
** KeepassMe is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** KeepassMe is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with KeepassMe.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#ifndef KDBGROUP_H
#define KDBGROUP_H

#include <QObject>

namespace kpxPublic {

class KdbGroup : public QObject
{
    Q_OBJECT

public:
    Q_ENUMS(eResult)
    enum eResult {
        RE_OK = 0,                  // no error
        RE_SAVE_ERROR,              // error saving ...

        RE_LAST
    };

public:
    Q_PROPERTY(int groupId READ getGroupId WRITE setGroupId STORED true SCRIPTABLE true)

public:
    Q_INVOKABLE void loadGroupData();
    Q_INVOKABLE void createNewGroup(QString title, int parentGroupId);
    Q_INVOKABLE void saveGroupData(QString title);
    Q_INVOKABLE void deleteGroup();

signals:
    // signal to QML
    void groupDataLoaded(QString title);
    void groupDataSaved(int result);
    void newGroupCreated(int result, int newGroupId);
    void groupDeleted(int result);

    // signal to global interface object of the keepass database
    void loadGroupFromKdbDatabase(int groupId);
    void saveGroupToKdbDatabase(int groupId, QString title);
    void createNewGroupInKdbDatabase(QString title, quint32 iconId, int parentGroupId);
    void deleteGroupFromKdbDatabase(int groupId);

public:
    KdbGroup(QObject *parent = 0);
    virtual ~KdbGroup() {}

    int getGroupId();
    void setGroupId(int groupId);

private:
    int m_groupId;
};

}
#endif // KDBGROUP_H
