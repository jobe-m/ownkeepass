/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
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

#include <QGuiApplication>
#include <QQuickView>
#include <QtQml/qqml.h>

#include "sailfishapplication.h"

#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "KdbEntry.h"
#include "KdbGroup.h"
#include "private/KdbInterface.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(Sailfish::createApplication(argc, argv));
    app.data()->setOrganizationName("jobe-m");
    app.data()->setApplicationName("ownKeepass");

    // @uri KeepassPlugin
    const char* uri("KeepassPlugin");
    // make the following classes available in QML
    qmlRegisterType<kpxPublic::KdbDatabase>(uri, 1, 0, "KdbDatabase");
    qmlRegisterType<kpxPublic::KdbListModel>(uri, 1, 0, "KdbListModel");
    qmlRegisterType<kpxPublic::KdbEntry>(uri, 1, 0, "KdbEntry");
    qmlRegisterType<kpxPublic::KdbGroup>(uri, 1, 0, "KdbGroup");

    QScopedPointer<QQuickView> view(Sailfish::createView("Main.qml"));
    Sailfish::showView(view.data());
    
    return app->exec();
}
