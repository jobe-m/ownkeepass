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

namespace kpxPublic {

class KeepassIcon : public QQuickImageProvider
{
public:
    KeepassIcon()
        : QQuickImageProvider(QQuickImageProvider::Image, QQuickImageProvider::ForceAsynchronousImageLoading)
    {}

    QImage requestImage(const QString &uuid, QSize *size, const QSize &requestedSize);
};

static const int baseRole = Qt::UserRole + 1;

class IconItem
{
public:
    IconItem(QString uuid, type)
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
    int     m_type;  // Identifies if this icon is a standard icon or a custom database icon - this is used for sections in the list view
};

class IconListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY isEmptyChanged)

public:
    Q_INVOKABLE void initListModel(int loadStandardIcons);
    Q_INVOKABLE void clearListModel();

public:
    IconListModel(QObject *parent = 0);
    virtual ~IconListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    void clear();
    bool isEmpty();

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return KdbItem::createRoles(); }

signals:
    // signals to QML
    void modelDataChanged();

    // signals to database client
    void loadCustomIcons();

    // signals for properties
    void isEmptyChanged();

public slots:
    // signal from database client
    void slot_appendCustomIcon(QString uuid);
    void slot_deleteCustomIcon(QString uuid);

private:
    QList<IconItem> m_items;
    // List model is for password entries (false) or password groups (true) - this affects only the 68 standard icons
    bool m_group_icons;
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
    rotes[baseRole + 2] = "type";
    return roles;
}

}
#endif // KDBCUSTOMICON_H
