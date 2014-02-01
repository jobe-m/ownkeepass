/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
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

#include <QDebug>
#include "OwnKeepassSettings.h"

using namespace settingsPublic;

OwnKeepassSettings::OwnKeepassSettings(const QString filePath, QObject *parent):
    QObject(parent),
    m_recentDatabaseModel(new settingsPrivate::RecentDatabaseListModel(m_recentDatabaseListLength)),
    m_previousVersion("0"),
    m_version(OWN_KEEPASS_VERSION),
    m_simpleMode(false),
    m_defaultCryptAlgorithm(0),
    m_defaultKeyTransfRounds(5000),
    m_locktime(3),
    m_showUserNamePasswordInListView(false),
    m_showUserNamePasswordOnCover(true),
    m_lockDatabaseFromCover(true),
    m_copyNpasteFromCover(true),
    m_loadLastDb(false),
//    m_settings(new Settings(filePath, parent)),
    m_recentDatabaseListLength(5) // currently not yet changeable
{
    m_settings = new Settings(filePath, parent);
    loadSettings();
}

OwnKeepassSettings::~OwnKeepassSettings()
{
    delete m_settings;
}

void OwnKeepassSettings::loadSettings() {
    m_previousVersion                = (m_settings->getValue("settings/version", QVariant(m_version))).toString();
    m_simpleMode                     = (m_settings->getValue("settings/simpleMode", QVariant(m_simpleMode))).toBool();
    m_defaultCryptAlgorithm          = (m_settings->getValue("settings/defaultCryptAlgorithm", QVariant(m_defaultCryptAlgorithm))).toInt();
    m_defaultKeyTransfRounds         = (m_settings->getValue("settings/defaultKeyTransfRounds", QVariant(m_defaultKeyTransfRounds))).toInt();
    m_locktime                       = (m_settings->getValue("settings/locktime", QVariant(m_locktime))).toInt();
    m_showUserNamePasswordInListView = (m_settings->getValue("settings/showUserNamePasswordInListView", QVariant(m_showUserNamePasswordInListView))).toBool();
    m_showUserNamePasswordOnCover    = (m_settings->getValue("settings/showUserNamePasswordOnCover", QVariant(m_showUserNamePasswordOnCover))).toBool();
    m_lockDatabaseFromCover          = (m_settings->getValue("settings/lockDatabaseFromCover", QVariant(m_lockDatabaseFromCover))).toBool();
    m_copyNpasteFromCover            = (m_settings->getValue("settings/copyNpasteFromCover", QVariant(m_copyNpasteFromCover))).toBool();

    // emit signals for property changes
    emit simpleModeChanged();
    emit defaultCryptAlgorithmChanged();
    emit defaultKeyTransfRoundsChanged();
    emit locktimeChanged();
    emit showUserNamePasswordInListViewChanged();
    emit showUserNamePasswordOnCoverChanged();
    emit lockDatabaseFromCoverChanged();
    emit copyNpasteFromCoverChanged();

    // Check previous settings file version here and
    // save new settings Format if needed
    if (m_previousVersion != m_version) {
        // save new version number
        m_settings->setValue("settings/version", QVariant(m_version));
    }

    // load recent database list if we are in expert mode
    m_recentDatabaseList = m_settings->getArray("main/recentDatabases");
    if (!m_simpleMode) {
        for (int i = m_recentDatabaseList.length()-1; i >= 0 ; --i) {
            m_recentDatabaseModel->addRecent(m_recentDatabaseList[i]["uiName"].toString(),
                    m_recentDatabaseList[i]["uiPath"].toString(),
                    m_recentDatabaseList[i]["dbLocation"].toInt(),
                    m_recentDatabaseList[i]["dbFilePath"].toString(),
                    m_recentDatabaseList[i]["useKeyFile"].toBool(),
                    m_recentDatabaseList[i]["keyFileLocation"].toInt(),
                    m_recentDatabaseList[i]["keyFilePath"].toString());
        }
    }

    m_loadLastDb = (m_settings->getValue("main/loadLastDb", QVariant(m_loadLastDb))).toBool();
}

void OwnKeepassSettings::addRecentDatabase(QString uiName,
                                           QString uiPath,
                                           int dbLocation,
                                           QString dbFilePath,
                                           bool useKeyFile,
                                           int keyFileLocation,
                                           QString keyFilePath)
{
    bool alreadyOnFirstPosition = false;
    // check if the recent database is already in the list
    for(int i = 0; i < m_recentDatabaseList.length(); ++i) {
        if (m_recentDatabaseList[i]["uiName"].toString() == uiName && m_recentDatabaseList[i]["uiPath"].toString() == uiPath) {
            if (i == 0) {
                // already at first position in the list
                alreadyOnFirstPosition = true;
                break;
            } else {
                // Delete it from list and re-add it at the first position here only when it's not already on the first position
                m_recentDatabaseList.removeAt(i);
                // In non simple mode we have recent list on main page
                if (!m_simpleMode) m_recentDatabaseModel->deleteItem(i);
            }
        }
    }
    // Insert recent at first position in the list model
    if (!alreadyOnFirstPosition) {
        QMap<QString, QVariant> recentDatabase;
        recentDatabase.clear();
        recentDatabase["uiName"] = QVariant(uiName);
        recentDatabase["uiPath"] = QVariant(uiPath);
        recentDatabase["dbLocation"] = QVariant(dbLocation);
        recentDatabase["dbFilePath"] = QVariant(dbFilePath);
        recentDatabase["useKeyFile"] = QVariant(useKeyFile);
        recentDatabase["keyFileLocation"] = QVariant(keyFileLocation);
        recentDatabase["keyFilePath"] = QVariant(keyFilePath);
        m_recentDatabaseList.insert(0, recentDatabase);
        // In non simple mode we have recent list on main page
        if (!m_simpleMode) m_recentDatabaseModel->addRecent(uiName, uiPath, dbLocation, dbFilePath, useKeyFile, keyFileLocation, keyFilePath);
    }

    // Check if list is longer than predefined value in settings
    if (m_recentDatabaseList.length() > m_recentDatabaseListLength) {
        m_recentDatabaseList.removeLast();
        // In non simple mode we have recent list on main page
        if (!m_simpleMode) m_recentDatabaseModel->deleteItem(m_recentDatabaseListLength);
    }

    // save new recent Database list
    if (!alreadyOnFirstPosition) {
        m_settings->removeArray("main/recentDatabases");
        for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
            qDebug() << "save into settings: " << i << " - " << m_recentDatabaseList[i]["uiName"];
            m_settings->appendToArray("main/recentDatabases", m_recentDatabaseList[i]);
        }
    }
}

void OwnKeepassSettings::setSimpleMode(const bool value)
{
    if (value != m_simpleMode) {
        m_simpleMode = value;
        m_settings->setValue("settings/simpleMode", QVariant(m_simpleMode));
        emit simpleModeChanged();
    }
}

void OwnKeepassSettings::setDefaultCryptAlgorithm(const int value)
{
    if (value != m_defaultCryptAlgorithm) {
        m_defaultCryptAlgorithm = value;
        m_settings->setValue("settings/defaultCryptAlgorithm", QVariant(m_defaultCryptAlgorithm));
        emit defaultCryptAlgorithmChanged();
    }
}

void OwnKeepassSettings::setDefaultKeyTransfRounds(const int value)
{
    if (value != m_defaultKeyTransfRounds) {
        m_defaultKeyTransfRounds = value;
        m_settings->setValue("settings/defaultKeyTransfRounds", QVariant(m_defaultKeyTransfRounds));
        emit defaultKeyTransfRoundsChanged();
    }
}

void OwnKeepassSettings::setLocktime(const int value)
{
    if (value != m_locktime) {
        m_locktime = value;
        m_settings->setValue("settings/locktime", QVariant(m_locktime));
        emit locktimeChanged();
    }
}

void OwnKeepassSettings::setShowUserNamePasswordInListView(const bool value)
{
    if (value != m_showUserNamePasswordInListView) {
        m_showUserNamePasswordInListView = value;
        m_settings->setValue("settings/showUserNamePasswordInListView", QVariant(m_showUserNamePasswordInListView));
        emit showUserNamePasswordInListViewChanged();
    }
}

void OwnKeepassSettings::setShowUserNamePasswordOnCover(const bool value)
{
    if (value != m_showUserNamePasswordOnCover) {
        m_showUserNamePasswordOnCover = value;
        m_settings->setValue("settings/showUserNamePasswordOnCover", QVariant(m_showUserNamePasswordOnCover));
        emit showUserNamePasswordOnCoverChanged();
    }
}

void OwnKeepassSettings::setLockDatabaseFromCover(const bool value)
{
    if (value != m_lockDatabaseFromCover) {
        m_lockDatabaseFromCover = value;
        m_settings->setValue("settings/lockDatabaseFromCover", QVariant(m_lockDatabaseFromCover));
        emit lockDatabaseFromCoverChanged();
    }
}

void OwnKeepassSettings::setCopyNpasteFromCover(const bool value)
{
    if (value != m_copyNpasteFromCover) {
        m_copyNpasteFromCover = value;
        m_settings->setValue("settings/copyNpasteFromCover", QVariant(m_copyNpasteFromCover));
        emit copyNpasteFromCoverChanged();
    }
}

void OwnKeepassSettings::setLoadLastDb(bool value)
{
    if (value != m_loadLastDb) {
        m_loadLastDb = value;
        m_settings->setValue("main/loadLastDb", QVariant(m_loadLastDb));
        emit loadLastDbChanged();
    }
}

void OwnKeepassSettings::checkLoadLastDatabase()
{
    // check if we need to load last database - if yes send signal to QML side to handle that
    if (m_loadLastDb && !m_recentDatabaseList.isEmpty()) {
        emit loadLastDatabase(m_recentDatabaseList[0]["dbLocation"].toInt(),
                m_recentDatabaseList[0]["dbFilePath"].toString(),
                m_recentDatabaseList[0]["useKeyFile"].toBool(),
                m_recentDatabaseList[0]["keyFileLocation"].toInt(),
                m_recentDatabaseList[0]["keyFilePath"].toString());
    }
}
