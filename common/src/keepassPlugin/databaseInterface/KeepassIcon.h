/***************************************************************************
**
** Copyright (C) 2016 Marko Koschak (marko.koschak@tisno.de)
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
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#ifndef KEEPASSICON_H
#define KEEPASSICON_H

#include <QQuickImageProvider>
#include <QImage>
#include <QAbstractListModel>
#include "ownKeepassGlobal.h"

using namespace ownKeepassPublic; // for using baseRole

namespace kpxPublic {

class KeepassIcon : public QQuickImageProvider
{
public:
    KeepassIcon()
        : QQuickImageProvider(QQuickImageProvider::Image, QQuickImageProvider::ForceAsynchronousImageLoading)
    {}

    QImage requestImage(const QString &uuid, QSize *size, const QSize &requestedSize);
};

class IconBackground : public QQuickImageProvider
{
public:
    IconBackground()
        : QQuickImageProvider(QQuickImageProvider::Image, QQuickImageProvider::ForceAsynchronousImageLoading)
    {}

    QImage requestImage(const QString &uuid, QSize *size, const QSize &requestedSize);
};

class IconItem
{
public:
    IconItem(QString uuid, int type)
        : m_uuid(uuid),
          m_type(type)
    {
        static int itemCount = 0;
        m_index = itemCount;
        itemCount++;
    }
    virtual ~IconItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    QString m_uuid;  // Contains file name of standard icon or uuid of custom database icon
    int     m_index; // Number of icon
    int     m_type;  // Identifies if this icon is a KEEPASS_ICON or a CUSTOM_DATABASE_ICON or a OWNKEEPASS_ICON_PACK - this is used for sections in the list view
};

class IconListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY isEmptyChanged)

public:
    /// This function needs to be called from QML side to initialize the list model with data from Keepass and the database.
    /// \param keepassIconType is one of LOAD_KEEPASS_ENTRY_ICONS, LOAD_KEEPASS_GROUP_ICONS. For any other value no Keepass icons will be added to the list model.
    Q_INVOKABLE void initListModel(int keepassIconType);
    Q_INVOKABLE void clearListModel();

public:
    Q_ENUMS(eIconType)
    Q_ENUMS(eLoadStandardIcons)

    enum eIconType {
        KEEPASS_ICON = 0,
        CUSTOM_DATABASE_ICON,
        OWNKEEPASS_ICON_PACK
    };

    enum eLoadStandardIcons {
        LOAD_KEEPASS_ENTRY_ICONS = 0,
        LOAD_KEEPASS_GROUP_ICONS,
        LOAD_CUSTOM_DATABASE_ICONS,
        LOAD_OWNKEEPASS_ICON_PACK_ICONS
    };

    IconListModel(QObject *parent = 0);
    virtual ~IconListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    void clear();
    bool isEmpty();

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return IconItem::createRoles(); }

signals:
    // signals to QML
    void iconListModelLoaded(int result,
                             QString errorMsg);
    void modelDataChanged();

    // signals to database client
    void loadCustomIcons();
    void unregisterFromDatabaseClient(QString modelId);

    // signals for properties
    void isEmptyChanged();

public slots:
    // signal from database client
    void slot_appendCustomIconToListModel(QString uuid);
    void slot_deleteCustomIconfromListModel(QString uuid);
    void slot_disconnectFromDatabaseClient();

private:
    bool connectToDatabaseClient();
    void disconnectFromDatabaseClient();

private:
    QList<IconItem> m_items;
    // List model is for password entries (false) or password groups (true) - this affects only the 68 standard icons
    bool m_group_icons;

    // identifies if this object is conntected to a loaded keepass database
    bool m_connected;
};

// inline implementations
inline QVariant IconItem::get(const int role) const
{
    switch (role) {
    case baseRole:
        return m_uuid;
    case baseRole + 1:
        return m_index;
    case baseRole + 2:
        return m_type;
    }
    return QVariant();
}

inline QHash<int, QByteArray> IconItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "uuid";
    roles[baseRole + 1] = "index";
    roles[baseRole + 2] = "type";
    return roles;
}

}
#endif // KDBCUSTOMICON_H
