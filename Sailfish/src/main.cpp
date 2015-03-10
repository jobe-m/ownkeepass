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
#include "FileBrowserPlugin.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-ownkeepass.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    const QString orgName("tisno.de");
    const QString appName("harbour-ownkeepass");
    const QString settingsFilePath(QStandardPaths::standardLocations(QStandardPaths::ConfigLocation)[0] +
                                   "/" + appName + "/settings.ini");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    app->setOrganizationName(orgName);
    app->setApplicationName(appName);

    // @uri harbour.ownkeepass.KeepassX1
    const char* uri("harbour.ownkeepass.KeepassX1");
    // make the following classes available in QML
    qmlRegisterType<kpxPublic::KdbDatabase>(uri, 1, 0, "KdbDatabase");
    qmlRegisterType<kpxPublic::KdbListModel>(uri, 1, 0, "KdbListModel");
    qmlRegisterType<kpxPublic::KdbEntry>(uri, 1, 0, "KdbEntry");
    qmlRegisterType<kpxPublic::KdbGroup>(uri, 1, 0, "KdbGroup");
    qmlRegisterType<FileBrowserListModel>(uri, 1, 0, "FileBrowserListModel");

    // Setup some class as context properties and make them accessible in QML
    QScopedPointer<OwnKeepassHelper> helper(new OwnKeepassHelper());
    view->rootContext()->setContextProperty("ownKeepassHelper", helper.data());
    QScopedPointer<settingsPublic::OwnKeepassSettings> okpSettings(new settingsPublic::OwnKeepassSettings(settingsFilePath, helper.data()));
    view->rootContext()->setContextProperty("ownKeepassSettings", okpSettings.data());
    view->rootContext()->setContextProperty("recentDatabaseModel", okpSettings->recentDatabaseModel());

    // Check if user has set language explicitly to be used in the app
    QString locale = QLocale::system().name();
    view->rootContext()->setContextProperty("DebugLocale",QVariant(locale));
    QTranslator translator;
    if (settingsPublic::OwnKeepassSettings::LANG_SYSTEM_DEFAULT != okpSettings->language()) {
        switch (okpSettings->language()) {
        // LANG_CA
        case settingsPublic::OwnKeepassSettings::LANG_CA:
            translator.load("harbour-ownkeepass-ca.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_ZH_CN
        case settingsPublic::OwnKeepassSettings::LANG_ZH_CN:
            translator.load("harbour-ownkeepass-zh_CN.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_CS_CZ
        case settingsPublic::OwnKeepassSettings::LANG_CS_CZ:
            translator.load("harbour-ownkeepass-cs_CZ.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_DA
        case settingsPublic::OwnKeepassSettings::LANG_DA:
            translator.load("harbour-ownkeepass-da.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_NL_NL
        case settingsPublic::OwnKeepassSettings::LANG_NL_NL:
            translator.load("harbour-ownkeepass-nl_NL.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_EN_GB - using default ts file
        // LANG_FI_FI
        case settingsPublic::OwnKeepassSettings::LANG_FI_FI:
            translator.load("harbour-ownkeepass-fi_FI.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_FR_FR
        case settingsPublic::OwnKeepassSettings::LANG_FR_FR:
            translator.load("harbour-ownkeepass-fr_FR.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_DE_DE
        case settingsPublic::OwnKeepassSettings::LANG_DE_DE:
            translator.load("harbour-ownkeepass-de_DE.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_IT
        case settingsPublic::OwnKeepassSettings::LANG_IT:
            translator.load("harbour-ownkeepass-it.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_PL_PL
//        case settingsPublic::OwnKeepassSettings::LANG_PL_PL:  -- not yet started
//            translator.load("harbour-ownkeepass-pl_PL.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
//            break;
        // LANG_RU
        case settingsPublic::OwnKeepassSettings::LANG_RU:
            translator.load("harbour-ownkeepass-ru.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_ES
        case settingsPublic::OwnKeepassSettings::LANG_ES:
            translator.load("harbour-ownkeepass-es.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_SV_SE
        case settingsPublic::OwnKeepassSettings::LANG_SV_SE:
            translator.load("harbour-ownkeepass-sv_SE.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        // LANG_UK_UA
//        case settingsPublic::OwnKeepassSettings::LANG_UK_UA: -- not yet started
//            translator.load("harbour-ownkeepass-uk_UA.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
//            break;
        default:
            translator.load("harbour-ownkeepass.qm", SailfishApp::pathTo(QString("translations")).toLocalFile());
            break;
        }
        // install translator for specific language
        // otherwise the system language will be set by SailfishApp
        app->installTranslator(&translator);
    }

    // enable access to qml import libs
    view->engine()->addImportPath(SailfishApp::pathTo("lib/").toLocalFile());

    // Set main QML file and go ahead
    view->setSource(SailfishApp::pathTo("qml/Main.qml"));
    view->show();

    // Check settings version after QML is loaded because it might want to show an info popup in QML
    okpSettings->checkSettingsVersion();

    return app->exec();
}
