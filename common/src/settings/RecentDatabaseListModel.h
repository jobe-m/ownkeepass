/***************************************************************************
**
** Copyright (C) 2014 - 2019 Marko Koschak (marko.koschak@tisno.de)
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

#ifndef RECENTDATABASELISTMODEL_H
#define RECENTDATABASELISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>

namespace settingsPrivate {

static const int baseRole = Qt::UserRole + 1;

class DatabaseItem
{
public:
    DatabaseItem(QString uiName, QString uiPath, int dbLocation, QString dbFilePath, bool useKeyFile, int keyFileLocation, QString keyFilePath, int databaseType)
        : m_ui_name(uiName),
          m_ui_path(uiPath),
          m_database_location(dbLocation),
          m_database_file_path(dbFilePath),
          m_use_key_file(useKeyFile),
          m_key_location(keyFileLocation),
          m_key_file_path(keyFilePath),
          m_database_type(databaseType)
    {}
    virtual ~DatabaseItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    QString m_ui_name;
    QString m_ui_path;
    int m_database_location;
    QString m_database_file_path;
    bool m_use_key_file;
    int m_key_location;
    QString m_key_file_path;
    int m_database_type;
};

class RecentDatabaseListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_ENUMS(eLocationType)
    enum eLocationType {
        DOCUMENTS_ON_PHONE = 0,
        SD_CARD = 1,
        ANDROID_STORAGE = 2,
        SAILBOX = 3
    };

    Q_ENUMS(eResult)
    enum eResult {
        RE_OK = 0,                  // no error
        RE_DB_LOAD_ERROR,           // error loading ...
        RE_LAST
    };

    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY modelDataChanged)

public:
    Q_INVOKABLE void deleteItem(int index);
    Q_INVOKABLE void addRecent(QString uiName,
                               QString uiPath,
                               int dbLocation,
                               QString dbFilePath,
                               bool useKeyFile,
                               int keyFileLocation,
                               QString keyFilePath,
                               int databaseType);

public:
    RecentDatabaseListModel(int lengthOfListModel, QObject *parent = 0);
    virtual ~RecentDatabaseListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    void clear();
    bool isEmpty();

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return DatabaseItem::createRoles(); }
signals:
    // signal for property
    void modelDataChanged();

private:
    QList<DatabaseItem> m_items;
    int m_lengthOfListModel;
};

// inline implementations
inline QVariant DatabaseItem::get(const int role) const
{
    switch (role) {
    case baseRole:
        return m_ui_name;
    case baseRole + 1:
        return m_ui_path;
    case baseRole + 2:
        return m_database_location;
    case baseRole + 3:
        return m_database_file_path;
    case baseRole + 4:
        return m_use_key_file;
    case baseRole + 5:
        return m_key_location;
    case baseRole + 6:
        return m_key_file_path;
    case baseRole + 7:
        return m_database_type;
    }
    return QVariant();
}

inline QHash<int, QByteArray> DatabaseItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "uiName";
    roles[baseRole + 1] = "uiPath";
    roles[baseRole + 2] = "databaseLocation";
    roles[baseRole + 3] = "databaseFilePath";
    roles[baseRole + 4] = "useKeyFile";
    roles[baseRole + 5] = "keyFileLocation";
    roles[baseRole + 6] = "keyFilePath";
    roles[baseRole + 7] = "databaseType";
    return roles;
}

} // kpxPublic

#endif // RECENTDATABASELISTMODEL_H
