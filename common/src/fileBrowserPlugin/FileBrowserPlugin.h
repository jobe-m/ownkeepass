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

#ifndef FILEBROWSERPLUGIN_H
#define FILEBROWSERPLUGIN_H

#include <QAbstractListModel>
#include <QStringList>
#include <QDir>

namespace fileBrowserPlugin {

static const int baseRole = Qt::UserRole + 1;

class FileBrowserItem
{
public:
    FileBrowserItem(int location, QString file, QString icon, QString path, bool valid)
        : m_location(location),
          m_file(file),
          m_icon(icon),
          m_path(path),
          m_valid(valid)
    {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    int m_location;
    QString m_file;
    QString m_icon;
    QString m_path;
    bool m_valid;
};

inline QVariant FileBrowserItem::get(const int role) const
{
    switch (role) {
    case baseRole:
        return m_location;
    case baseRole + 1:
        return m_file;
    case baseRole + 2:
        return m_icon;
    case baseRole + 3:
        return m_path;
    case baseRole + 4:
        return m_valid;
    }
    return QVariant();
}

inline QHash<int, QByteArray> FileBrowserItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "location";
    roles[baseRole + 1] = "file";
    roles[baseRole + 2] = "icon";
    roles[baseRole + 3] = "path";
    roles[baseRole + 4] = "valid";
    return roles;
}

}

class FileBrowserListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_PROPERTY(QString breadcrumPath READ breadcrumPath NOTIFY breadcrumPathChanged)
    Q_PROPERTY(bool showDirsOnly READ showDirsOnly WRITE setShowDirsOnly NOTIFY showDirsOnlyChanged)
    Q_PROPERTY(bool validDir READ validDir NOTIFY validDirChanged)
    Q_PROPERTY(bool showHiddenFiles READ showHiddenFiles WRITE setShowHiddenFiles NOTIFY showHiddenFilesChanged)
    Q_INVOKABLE void clear();
    Q_INVOKABLE void loadFilePath(QString path);
    Q_INVOKABLE void cd(QString path);

public:
    FileBrowserListModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return fileBrowserPlugin::FileBrowserItem::createRoles(); }

    QString breadcrumPath() const { return m_breadcrum_path; }
    bool showDirsOnly() const { return m_showDirsOnly; }
    void setShowDirsOnly(const bool value) { m_showDirsOnly = value; }
    bool validDir() const { return m_valid_dir; }
    void setShowHiddenFiles(const bool value);
    bool showHiddenFiles() const { return m_showHiddenFiles; }

signals:
    // Signal to QML
    void showErrorBanner();
    void breadcrumPathChanged();
    void showDirsOnlyChanged();
    void validDirChanged();
    void showHiddenFilesChanged();

private:
    bool sdCardExists();
    QString getSdCardPath();
    QStringList mountPoints() const;
    QStringList sdCardPartitions();
    void appendRootElements();
    void listDir();

private:
    QList<fileBrowserPlugin::FileBrowserItem> m_items;
    QDir m_dir;

    QString m_breadcrum_path;
    bool m_showDirsOnly;
    bool m_valid_dir;
    bool m_showHiddenFiles;
};

#endif // FILEBROWSERPLUGIN_H
