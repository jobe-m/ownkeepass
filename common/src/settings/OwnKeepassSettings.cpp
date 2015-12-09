/***************************************************************************
**
** Copyright (C) 2014 - 2015 Marko Koschak (marko.koschak@tisno.de)
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
#include "KdbDatabase.h"
#include "ownKeepassGlobal.h"

using namespace settingsPublic;
using namespace ownKeepassPublic;

#define INITIAL_VERSION "1.0.0"

OwnKeepassSettings::OwnKeepassSettings(const QString filePath, OwnKeepassHelper *helper, QObject *parent):
    QObject(parent),
    m_helper(helper),
    m_previousVersion(INITIAL_VERSION),
    m_version(OWN_KEEPASS_VERSION),
    m_defaultCryptAlgorithm(0),
    m_defaultKeyTransfRounds(50000),
    m_locktime(3),
    m_sortAlphabeticallyInListView(true),
    m_showUserNamePasswordInListView(false),
    m_showSearchBar(true),
    m_focusSearchBarOnStartup(true),
    m_showUserNamePasswordOnCover(true),
    m_lockDatabaseFromCover(true),
    m_copyNpasteFromCover(true),
    m_recentDatabaseListLength(5), // currently not yet changeable
    m_pwGenLength(12),
    m_pwGenLowerLetters(true),
    m_pwGenUpperLetters(true),
    m_pwGenNumbers(true),
    m_pwGenSpecialChars(false),
    m_pwGenExcludeLookAlike(true),
    m_pwGenCharFromEveryGroup(true),
    m_clearClipboard(10),
    m_language(0),
    m_fastUnlock(true),
    m_fastUnlockRetryCount(2),
    m_uiOrientation(0),
    m_settings(new Settings(filePath, parent)),
    m_recentDatabaseModel(new settingsPrivate::RecentDatabaseListModel(m_recentDatabaseListLength))
{
    qDebug() << "ownKeepass version: " << m_version;
    loadSettings();
}

OwnKeepassSettings::~OwnKeepassSettings()
{
    delete m_settings;
}

void OwnKeepassSettings::checkSettingsVersion()
{
    // Check previous settings file version here and notify user on new version
    m_previousVersion = (m_settings->getValue("settings/version", QVariant(m_previousVersion))).toString();
    if (m_previousVersion != m_version) {
        // Now do some legacy stuff to update settings from older ownKeepass versions

        // Check if no version number was saved, this was a bug until version 1.0.4, from version 1.0.5 the new
        // version is saved every time the app version increases
        m_settings->setValue("settings/version", QVariant(m_version));

        QRegExp rx("(\\d+).(\\d+).(\\d+)");
        if ((rx.indexIn(m_previousVersion)) == -1) {
            qDebug() << "ERROR: Cannot extract release version number";
            return;
        }
        int major = rx.cap(1).toInt();
        int minor = rx.cap(2).toInt();
        int patch = rx.cap(3).toInt();

        // Version 1.0.25 introduced a file browser and also redefined the file locations
        // Thus we need to reset the recent opened database list because the paths will not fit
        if ((major == 1) && (minor == 0) && (patch < 25)) {
            m_settings->removeArray("main/recentDatabases");
        }

        // Version 1.1.3 fixes a bug in the recent database list
        if ((major == 1) && (minor <= 1) && (patch <= 2)) {
            m_recentDatabaseList = m_settings->getArray("main/recentDatabases");
            for (int i = m_recentDatabaseList.length()-1; i >= 0 ; --i) {
                QString uiPath = m_recentDatabaseList[i]["uiPath"].toString();
                m_recentDatabaseList[i]["uiPath"] = QVariant(uiPath.right(uiPath.length() - uiPath.lastIndexOf(": ") - 2));
            }
            // save changed recent Database list
            m_settings->removeArray("main/recentDatabases");
            for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
//                qDebug() << "changed: " << i << " - " << m_recentDatabaseList[i]["uiPath"];
                m_settings->appendToArray("main/recentDatabases", m_recentDatabaseList[i]);
            }
        }

        // Version 1.1.7 introduces database type in the recent database list to support Keepass 2 database format
        if ((major == 1) && (minor <= 1) && (patch <= 6)) {
            m_recentDatabaseList = m_settings->getArray("main/recentDatabases");
            for (int i = m_recentDatabaseList.length()-1; i >= 0 ; --i) {
                m_recentDatabaseList[i]["databaseType"] = QVariant(DatabaseType::DB_TYPE_KEEPASS_1);
            }
            // save changed recent Database list
            m_settings->removeArray("main/recentDatabases");
            for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
                m_settings->appendToArray("main/recentDatabases", m_recentDatabaseList[i]);
            }
        }

        // check if ownKeepass was updated and trigger to show info banner in QML
        if (m_previousVersion != INITIAL_VERSION) {
            emit showChangeLogBanner();
        }
        // Now save new version number
        m_settings->setValue("settings/version", QVariant(m_version));
    }

    // load recent database list
    // Position 1 won't be loaded, only position 2 - 5
    m_recentDatabaseList = m_settings->getArray("main/recentDatabases");
    for (int i = m_recentDatabaseList.length()-1; i > 0 ; --i) {
        m_recentDatabaseModel->addRecent(m_recentDatabaseList[i]["uiName"].toString(),
                                         m_recentDatabaseList[i]["uiPath"].toString(),
                                         m_recentDatabaseList[i]["dbLocation"].toInt(),
                                         m_recentDatabaseList[i]["dbFilePath"].toString(),
                                         m_recentDatabaseList[i]["useKeyFile"].toBool(),
                                         m_recentDatabaseList[i]["keyFileLocation"].toInt(),
                                         m_recentDatabaseList[i]["keyFilePath"].toString(),
                                         m_recentDatabaseList[i]["databaseType"].toInt());
    }

    // Update database details on main page in QML UI after version check
    loadDatabaseDetails();
}

void OwnKeepassSettings::loadSettings() {
    m_defaultCryptAlgorithm          = (m_settings->getValue("settings/defaultCryptAlgorithm", QVariant(m_defaultCryptAlgorithm))).toInt();
    m_defaultKeyTransfRounds         = (m_settings->getValue("settings/defaultKeyTransfRounds", QVariant(m_defaultKeyTransfRounds))).toInt();
    m_locktime                       = (m_settings->getValue("settings/locktime", QVariant(m_locktime))).toInt();
    m_sortAlphabeticallyInListView   = (m_settings->getValue("settings/sortAlphabeticallyInListView", QVariant(m_sortAlphabeticallyInListView))).toBool();
    m_showUserNamePasswordInListView = (m_settings->getValue("settings/showUserNamePasswordInListView", QVariant(m_showUserNamePasswordInListView))).toBool();
    m_showSearchBar                  = (m_settings->getValue("settings/showSearchBar", QVariant(m_showSearchBar))).toBool();
    m_focusSearchBarOnStartup        = (m_settings->getValue("settings/focusSearchBarOnStartup", QVariant(m_focusSearchBarOnStartup))).toBool();
    m_showUserNamePasswordOnCover    = (m_settings->getValue("settings/showUserNamePasswordOnCover", QVariant(m_showUserNamePasswordOnCover))).toBool();
    m_lockDatabaseFromCover          = (m_settings->getValue("settings/lockDatabaseFromCover", QVariant(m_lockDatabaseFromCover))).toBool();
    m_copyNpasteFromCover            = (m_settings->getValue("settings/copyNpasteFromCover", QVariant(m_copyNpasteFromCover))).toBool();
    m_pwGenLength                    = (m_settings->getValue("pwGen/Length", QVariant(m_pwGenLength))).toInt();
    m_pwGenLowerLetters              = (m_settings->getValue("pwGen/LowerLetters", QVariant(m_pwGenLowerLetters))).toBool();
    m_pwGenUpperLetters              = (m_settings->getValue("pwGen/UpperLetters", QVariant(m_pwGenUpperLetters))).toBool();
    m_pwGenNumbers                   = (m_settings->getValue("pwGen/Numbers", QVariant(m_pwGenNumbers))).toBool();
    m_pwGenSpecialChars              = (m_settings->getValue("pwGen/SpecialChars", QVariant(m_pwGenSpecialChars))).toBool();
    m_pwGenExcludeLookAlike          = (m_settings->getValue("pwGen/ExcludeLookAlike", QVariant(m_pwGenExcludeLookAlike))).toBool();
    m_pwGenCharFromEveryGroup        = (m_settings->getValue("pwGen/CharFromEveryGroup", QVariant(m_pwGenCharFromEveryGroup))).toBool();
    m_clearClipboard                 = (m_settings->getValue("settings/clearClipboard", QVariant(m_clearClipboard))).toInt();
    m_language                       = (m_settings->getValue("settings/language", QVariant(m_language))).toInt();
    m_fastUnlock                     = (m_settings->getValue("settings/fastUnlock", QVariant(m_fastUnlock))).toBool();
    m_fastUnlockRetryCount           = (m_settings->getValue("settings/fastUnlockRetryCount", QVariant(m_fastUnlockRetryCount))).toInt();
    m_uiOrientation                  = (m_settings->getValue("settings/uiOrientation", QVariant(m_uiOrientation))).toInt();

    // emit signals for property changes
    emit defaultCryptAlgorithmChanged();
    emit defaultKeyTransfRoundsChanged();
    emit locktimeChanged();
    emit sortAlphabeticallyInListViewChanged();
    emit showUserNamePasswordInListViewChanged();
    emit showUserNamePasswordOnCoverChanged();
    emit lockDatabaseFromCoverChanged();
    emit copyNpasteFromCoverChanged();
    emit pwGenLengthChanged();
    emit pwGenLowerLettersChanged();
    emit pwGenUpperLettersChanged();
    emit pwGenNumbersChanged();
    emit pwGenSpecialCharsChanged();
    emit pwGenExcludeLookAlikeChanged();
    emit pwGenCharFromEveryGroupChanged();
    emit clearClipboardChanged();
    emit languageChanged();
    emit fastUnlockChanged();
    emit fastUnlockRetryCountChanged();
    emit uiOrientationChanged();
}

void OwnKeepassSettings::addRecentDatabase(QString uiName,
                                           QString uiPath,
                                           int dbLocation,
                                           QString dbFilePath,
                                           bool useKeyFile,
                                           int keyFileLocation,
                                           QString keyFilePath,
                                           int databaseType)
{
    // Add first item, it is not in the list because it shall not be visible in the UI
    m_recentDatabaseList = m_settings->getArray("main/recentDatabases");
    if (m_recentDatabaseList.length() > 0) {
        m_recentDatabaseModel->addRecent(m_recentDatabaseList[0]["uiName"].toString(),
                                         m_recentDatabaseList[0]["uiPath"].toString(),
                                         m_recentDatabaseList[0]["dbLocation"].toInt(),
                                         m_recentDatabaseList[0]["dbFilePath"].toString(),
                                         m_recentDatabaseList[0]["useKeyFile"].toBool(),
                                         m_recentDatabaseList[0]["keyFileLocation"].toInt(),
                                         m_recentDatabaseList[0]["keyFilePath"].toString(),
                                         m_recentDatabaseList[0]["databaseType"].toInt());
    }

    bool alreadyOnFirstPosition = false;
    // Check if the recent database is already in the list
    for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
        if (m_recentDatabaseList[i]["dbLocation"].toInt() == dbLocation &&
                m_recentDatabaseList[i]["dbFilePath"].toString() == dbFilePath) {
            // Delete it from list and re-add it below at the first position here only when it's not already on the first position
            m_recentDatabaseList.removeAt(i);
            m_recentDatabaseModel->deleteItem(i);
            if (0 == i) {
                alreadyOnFirstPosition = true;
            }
        }
    }
    // Insert recent at first position in the list model
    QMap<QString, QVariant> recentDatabase;
    recentDatabase.clear();
    recentDatabase["uiName"] = QVariant(uiName);
    recentDatabase["uiPath"] = QVariant(uiPath);
    recentDatabase["dbLocation"] = QVariant(dbLocation);
    recentDatabase["dbFilePath"] = QVariant(dbFilePath);
    recentDatabase["useKeyFile"] = QVariant(useKeyFile);
    recentDatabase["keyFileLocation"] = QVariant(keyFileLocation);
    recentDatabase["keyFilePath"] = QVariant(keyFilePath);
    recentDatabase["databaseType"] = QVariant(databaseType);
    m_recentDatabaseList.insert(0, recentDatabase);
    m_recentDatabaseModel->addRecent(uiName, uiPath, dbLocation, dbFilePath, useKeyFile, keyFileLocation, keyFilePath, databaseType);

    // Check if list is longer than predefined value in settings
    if (m_recentDatabaseList.length() > m_recentDatabaseListLength) {
        m_recentDatabaseList.removeLast();
        m_recentDatabaseModel->deleteItem(m_recentDatabaseListLength);
    }

    // save new recent Database list
    if (!alreadyOnFirstPosition) {
        m_settings->removeArray("main/recentDatabases");
        for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
//            qDebug() << "save into settings: " << i << " - " << m_recentDatabaseList[i]["uiName"];
            m_settings->appendToArray("main/recentDatabases", m_recentDatabaseList[i]);
        }
    }

    // The first item in the recent database list view shall not be shown in the UI because
    // it is the active used database which is shown separately
    m_recentDatabaseModel->deleteItem(0);
}

void OwnKeepassSettings::removeRecentDatabase(QString uiName,
                                              int dbLocation,
                                              QString dbFilePath)
{
    bool removed = false;
    // Check if the given database is in the list
    // starting from the second item which is the first of the recent database list
    for (int i = 1; i < m_recentDatabaseList.length(); ++i) {
        if (m_recentDatabaseList[i]["dbLocation"].toInt() == dbLocation &&
                m_recentDatabaseList[i]["dbFilePath"].toString() == dbFilePath) {
            // Delete it from list
            m_recentDatabaseList.removeAt(i);
            // in the list model the first item is missing because it is the current database and not in the recent database list in the UI
            m_recentDatabaseModel->deleteItem(i - 1);
            removed = true;
        }
    }
    if (removed) {
        // database was found and removed from the list so save the list now
        // save new recent Database list
        m_settings->removeArray("main/recentDatabases");
        for (int i = 0; i < m_recentDatabaseList.length(); ++i) {
            m_settings->appendToArray("main/recentDatabases", m_recentDatabaseList[i]);
        }

        emit recentDatabaseRemoved(DatabaseAccessResult::RE_OK, uiName);
    } else {
        // remove of item was not successfull
        emit recentDatabaseRemoved(DatabaseAccessResult::RE_ERR_REMOVE_RECENT_DATABASE, uiName);
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

void OwnKeepassSettings::setSortAlphabeticallyInListView(const bool value)
{
    if (value != m_sortAlphabeticallyInListView) {
        m_sortAlphabeticallyInListView = value;
        m_settings->setValue("settings/sortAlphabeticallyInListView", QVariant(m_sortAlphabeticallyInListView));
        emit sortAlphabeticallyInListViewChanged();
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

void OwnKeepassSettings::setShowSearchBar(const bool value)
{
    if (value != m_showSearchBar) {
        m_showSearchBar = value;
        m_settings->setValue("settings/showSearchBar", QVariant(m_showSearchBar));
        emit showSearchBarChanged();
    }
}

void OwnKeepassSettings::setFocusSearchBarOnStartup(const bool value)
{
    if (value != m_focusSearchBarOnStartup) {
        m_focusSearchBarOnStartup = value;
        m_settings->setValue("settings/focusSearchBarOnStartup", QVariant(m_focusSearchBarOnStartup));
        emit focusSearchBarOnStartupChanged();
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

void OwnKeepassSettings::setPwGenLength(int value)
{
    if (value != m_pwGenLength) {
        m_pwGenLength = value;
        m_settings->setValue("pwGen/Length", QVariant(m_pwGenLength));
        emit pwGenLengthChanged();
    }
}

void OwnKeepassSettings::setPwGenLowerLetters(bool value)
{
    if (value != m_pwGenLowerLetters) {
        m_pwGenLowerLetters = value;
        m_settings->setValue("pwGen/LowerLetters", QVariant(m_pwGenLowerLetters));
        emit pwGenLowerLettersChanged();
    }
}

void OwnKeepassSettings::setPwGenUpperLetters(bool value)
{
    if (value != m_pwGenUpperLetters) {
        m_pwGenUpperLetters = value;
        m_settings->setValue("pwGen/UpperLetters", QVariant(m_pwGenUpperLetters));
        emit pwGenUpperLettersChanged();
    }
}

void OwnKeepassSettings::setPwGenNumbers(bool value)
{
    if (value != m_pwGenNumbers) {
        m_pwGenNumbers = value;
        m_settings->setValue("pwGen/Numbers", QVariant(m_pwGenNumbers));
        emit pwGenNumbersChanged();
    }
}

void OwnKeepassSettings::setPwGenSpecialChars(bool value)
{
    if (value != m_pwGenSpecialChars) {
        m_pwGenSpecialChars = value;
        m_settings->setValue("pwGen/SpecialChars", QVariant(m_pwGenSpecialChars));
        emit pwGenSpecialCharsChanged();
    }
}

void OwnKeepassSettings::setPwGenExcludeLookAlike(bool value)
{
    if (value != m_pwGenExcludeLookAlike) {
        m_pwGenExcludeLookAlike = value;
        m_settings->setValue("pwGen/ExcludeLookAlike", QVariant(m_pwGenExcludeLookAlike));
        emit pwGenExcludeLookAlikeChanged();
    }
}

void OwnKeepassSettings::setPwGenCharFromEveryGroup(bool value)
{
    if (value != m_pwGenCharFromEveryGroup) {
        m_pwGenCharFromEveryGroup = value;
        m_settings->setValue("pwGen/CharFromEveryGroup", QVariant(m_pwGenCharFromEveryGroup));
        emit pwGenCharFromEveryGroupChanged();
    }
}

void OwnKeepassSettings::setClearClipboard(int value)
{
    if (value != m_clearClipboard) {
        m_clearClipboard = value;
        m_settings->setValue("settings/clearClipboard", QVariant(m_clearClipboard));
        emit clearClipboardChanged();
    }
}

void OwnKeepassSettings::setLanguage(const int value)
{
    if ((value < Language::INVALID) && (value != m_language)) {
        m_language = value;
        m_settings->setValue("settings/language", QVariant(m_language));
        emit languageChanged();
    }
}

void OwnKeepassSettings::setFastUnlock(const bool value)
{
    if (value != m_fastUnlock) {
        m_fastUnlock = value;
        m_settings->setValue("settings/fastUnlock", QVariant(m_fastUnlock));
        emit fastUnlockChanged();
    }
}

void OwnKeepassSettings::setFastUnlockRetryCount(const int value)
{
    if (value != m_fastUnlockRetryCount) {
        m_fastUnlockRetryCount = value;
        m_settings->setValue("settings/fastUnlockRetryCount", QVariant(m_fastUnlockRetryCount));
        emit fastUnlockRetryCountChanged();
    }
}

void OwnKeepassSettings::setUiOrientation(int value)
{
    if (value != m_uiOrientation) {
        m_uiOrientation = value;
        m_settings->setValue("settings/uiOrientation", QVariant(m_uiOrientation));
        emit uiOrientationChanged();
    }
}

void OwnKeepassSettings::loadDatabaseDetails()
{
    if (!m_recentDatabaseList.isEmpty()) {
        // check if last loaded database exists
        int dbLocationInt = m_recentDatabaseList[0]["dbLocation"].toInt();
        QString dbLocation(m_helper->getLocationRootPath(dbLocationInt));
        QString dbFilePath(m_recentDatabaseList[0]["dbFilePath"].toString());
        if (QFile::exists(dbLocation + "/" + dbFilePath)) {
            emit databaseDetailsLoaded(true, dbLocationInt, dbFilePath,
                    m_recentDatabaseList[0]["useKeyFile"].toBool(),
                    m_recentDatabaseList[0]["keyFileLocation"].toInt(),
                    m_recentDatabaseList[0]["keyFilePath"].toString(),
                    m_recentDatabaseList[0]["databaseType"].toInt());
            return;
        }
    } else {
        // check if default database exists
        QString dbLocation(m_helper->getLocationRootPath(1));
        // first look for Keepass 2 default database as this will be default when this database type is supported
        if (QFile::exists(dbLocation + "/Documents/ownkeepass/notes.kdbx")) {
            emit databaseDetailsLoaded(true, 1, "Documents/ownkeepass/notes.kdbx", false, 0, "", DatabaseType::DB_TYPE_KEEPASS_2);
            return;
        } else if (QFile::exists(dbLocation + "/Documents/ownkeepass/notes.kdb")) {
            emit databaseDetailsLoaded(true, 1, "Documents/ownkeepass/notes.kdb", false, 0, "", DatabaseType::DB_TYPE_KEEPASS_1);
            return;
        } else {
            // no database found
            emit databaseDetailsLoaded(false, 0, "", false, 0, "", DatabaseType::DB_TYPE_UNKNOWN);
        }
    }
}
