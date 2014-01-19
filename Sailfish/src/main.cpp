/***************************************************************************
**
** Copyright (C) 2013 - 2014 Marko Koschak (marko.koschak@tisno.de)
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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QString>
#include <QDebug>
#include <QGuiApplication>
#include <QQuickView>
#include <QScopedPointer>
#include <QStandardPaths>
#include <QtQml>
#include <sailfishapp.h>

#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "KdbEntry.h"
#include "KdbGroup.h"
#include "private/KdbInterface.h"
#include "OwnKeepassHelper.h"
#include "OwnKeepassSettings.h"
#include "RecentDatabaseListModel.h"

int main(int argc, char *argv[])
{
    const QString orgName("tisno.de");
    const QString appName("harbour-ownkeepass");
    const QString settingsFilePath(QStandardPaths::standardLocations(QStandardPaths::ConfigLocation)[0] +
                                   "/" + appName + "/settings.ini");
    // These are the predefined locations where the user can save the Keepass database and key file
    const QString jollaPhoneDocumentsPath(QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation)[0]);
    const QString sdCardPath("/run/user/100000/media/sdcard");
    const QString androidStoragePath("/data/sdcard");

    // SailfishApp::main() will display "qml/harbour-ownkeepass.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    app->setOrganizationName(orgName);
    app->setApplicationName(appName);

    // @uri harbour.ownkeepass
    const char* uri("harbour.ownkeepass");
    // make the following classes available in QML
// TODO make KdbDatabase a context property
    qmlRegisterType<kpxPublic::KdbDatabase>(uri, 1, 0, "KdbDatabase");
    qmlRegisterType<kpxPublic::KdbListModel>(uri, 1, 0, "KdbListModel");
    qmlRegisterType<kpxPublic::KdbEntry>(uri, 1, 0, "KdbEntry");
    qmlRegisterType<kpxPublic::KdbGroup>(uri, 1, 0, "KdbGroup");

    // Make some simple properties available in QML
    view->rootContext()->setContextProperty("jollaPhoneDocumentsPath", jollaPhoneDocumentsPath);
    view->rootContext()->setContextProperty("sdCardPath", sdCardPath);
    view->rootContext()->setContextProperty("androidStoragePath", androidStoragePath);

    // Setup some class as context properties and make them accessible in QML
    QScopedPointer<OwnKeepassHelper> helper(new OwnKeepassHelper());
    view->rootContext()->setContextProperty("OwnKeepassHelper", helper.data());
    QScopedPointer<settingsPublic::OwnKeepassSettings> okpSettings(new settingsPublic::OwnKeepassSettings(settingsFilePath));
    view->rootContext()->setContextProperty("OwnKeepassSettings", okpSettings.data());
    QScopedPointer<settingsPublic::RecentDatabaseListModel> recentDbListModel(new settingsPublic::RecentDatabaseListModel());
    view->rootContext()->setContextProperty("RecentDatabaseListModel", recentDbListModel.data());

    // Set main QML file and go ahead
    view->setSource(SailfishApp::pathTo("qml/Main.qml"));
    view->show();

    return app->exec();
}
