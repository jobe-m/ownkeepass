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

#ifndef KEYTRANSFROUNDS_H
#define KEYTRANSFROUNDS_H

#include <QObject>
#include "KdbInterface.h"
#include "PropertyInterface.h"

namespace kpxPublic {

class KeyTransfRounds : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int keyTransfRounds READ keyTransfRounds WRITE setKeyTransfRounds NOTIFY keyTransfRoundsChanged)

public:
    KeyTransfRounds(QObject* parent = 0)
        : QObject(parent),
          m_value(50000) // default property value for KeyTransfRounds
    {
        // connect signals to backend worker thread, where the serious stuff is done without blocking the foreground UI thread
        Q_ASSERT(connect(this, SIGNAL(sendSignal(int)),
                         kpxPrivate::KdbInterface::getWorker()->getKeyTransfRounds(), SLOT(slot(int))));
        Q_ASSERT(connect(kpxPrivate::KdbInterface::getWorker()->getKeyTransfRounds(), SIGNAL(sendSignal(int)),
                         this, SLOT(slot(int))));
    }
    virtual ~KeyTransfRounds() {}

    void setKeyTransfRounds(const int value) {
        emit sendSignal(value);
    }
    int keyTransfRounds() const {
        return m_value;
    }

signals:
    // signals to backend database worker thread
    void sendSignal(int value);

public slots:
    // signals from backend database worker thread
    void slot(int value) {
        if (value != m_value) {
            m_value = value;
            emit keyTransfRoundsChanged();
        }
    }

private:
    int m_value;
};
}

namespace kpxPrivate {

// Implementation of Key Transformation Rounds property for backend database
class KeyTransfRounds : public IntPropertyInterface
{
public:
    KeyTransfRounds(KdbInterfaceWorker* dbWorker, QObject* parent = 0)
        : IntPropertyInterface(dbWorker, parent) {}

public slots:
    void slot(int value) {
// TODO set keyTransfRounds in database and return it via emit sendSignal
    }
};
}
#endif
