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

#ifndef OWNKEEPASSSETTINGS_H
#define OWNKEEPASSSETTINGS_H

#include <QObject>
#include <QAbstractListModel>
#include "setting.h"
#include "RecentDatabaseListModel.h"
#include "OwnKeepassHelper.h"

namespace settingsPublic {

const QString OWN_KEEPASS_VERSION(PROGRAMVERSION); // get version from yaml/spec file

class OwnKeepassSettings : public QObject
{
    Q_OBJECT

public:
    Q_ENUMS(eLanguages)
    enum eLanguages {
        LANG_SYSTEM_DEFAULT = 0,
        LANG_EN_GB,
        LANG_SV_SE,
        LANG_FI_FI,
        LANG_DE_DE,
        LANG_CS_CZ,
        LANG_CA,
        LANG_NL_NL,
        LANG_ES,
        LANG_FR_FR,
        LANG_IT,
        LANG_RU,
        LANG_DA,
        LANG_PL_PL,
        LANG_INVALID
    };

public:
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(bool simpleMode READ simpleMode WRITE setSimpleMode NOTIFY simpleModeChanged)
    Q_PROPERTY(int defaultCryptAlgorithm READ defaultCryptAlgorithm WRITE setDefaultCryptAlgorithm NOTIFY defaultCryptAlgorithmChanged)
    Q_PROPERTY(int defaultKeyTransfRounds READ defaultKeyTransfRounds WRITE setDefaultKeyTransfRounds NOTIFY defaultKeyTransfRoundsChanged)
    Q_PROPERTY(int locktime READ locktime WRITE setLocktime NOTIFY locktimeChanged)
    Q_PROPERTY(bool showUserNamePasswordInListView READ showUserNamePasswordInListView WRITE setShowUserNamePasswordInListView NOTIFY showUserNamePasswordInListViewChanged)
    Q_PROPERTY(bool showSearchBar READ showSearchBar WRITE setShowSearchBar NOTIFY showSearchBarChanged)
    Q_PROPERTY(bool focusSearchBarOnStartup READ focusSearchBarOnStartup WRITE setFocusSearchBarOnStartup NOTIFY focusSearchBarOnStartupChanged)
    Q_PROPERTY(bool showUserNamePasswordOnCover READ showUserNamePasswordOnCover WRITE setShowUserNamePasswordOnCover NOTIFY showUserNamePasswordOnCoverChanged)
    Q_PROPERTY(bool lockDatabaseFromCover READ lockDatabaseFromCover WRITE setLockDatabaseFromCover NOTIFY lockDatabaseFromCoverChanged)
    Q_PROPERTY(bool copyNpasteFromCover READ copyNpasteFromCover WRITE setCopyNpasteFromCover NOTIFY copyNpasteFromCoverChanged)
    Q_PROPERTY(bool loadLastDb READ loadLastDb WRITE setLoadLastDb NOTIFY loadLastDbChanged)
    Q_PROPERTY(int pwGenLength READ pwGenLength WRITE setPwGenLength NOTIFY pwGenLengthChanged)
    Q_PROPERTY(bool pwGenLowerLetters READ pwGenLowerLetters WRITE setPwGenLowerLetters NOTIFY pwGenLowerLettersChanged)
    Q_PROPERTY(bool pwGenUpperLetters READ pwGenUpperLetters WRITE setPwGenUpperLetters NOTIFY pwGenUpperLettersChanged)
    Q_PROPERTY(bool pwGenNumbers READ pwGenNumbers WRITE setPwGenNumbers NOTIFY pwGenNumbersChanged)
    Q_PROPERTY(bool pwGenSpecialChars READ pwGenSpecialChars WRITE setPwGenSpecialChars NOTIFY pwGenSpecialCharsChanged)
    Q_PROPERTY(bool pwGenExcludeLookAlike READ pwGenExcludeLookAlike WRITE setPwGenExcludeLookAlike NOTIFY pwGenExcludeLookAlikeChanged)
    Q_PROPERTY(bool pwGenCharFromEveryGroup READ pwGenCharFromEveryGroup WRITE setPwGenCharFromEveryGroup NOTIFY pwGenCharFromEveryGroupChanged)
    Q_PROPERTY(int clearClipboard READ clearClipboard WRITE setClearClipboard NOTIFY clearClipboardChanged)
    Q_PROPERTY(int language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool fastUnlock READ fastUnlock WRITE setFastUnlock NOTIFY fastUnlockChanged)
    Q_PROPERTY(int fastUnlockRetryCount READ fastUnlockRetryCount WRITE setFastUnlockRetryCount NOTIFY fastUnlockRetryCountChanged)

    Q_INVOKABLE void addRecentDatabase(QString uiName,
                                       QString uiPath,
                                       int dbLocation,
                                       QString dbFilePath,
                                       bool useKeyFile,
                                       int keyFileLocation,
                                       QString keyFilePath);
    Q_INVOKABLE void checkLoadLastDatabase();
    Q_INVOKABLE void checkDatabaseInSimpleMode();

public:
    OwnKeepassSettings(const QString filePath, OwnKeepassHelper *helper, QObject *parent = 0);
    virtual ~OwnKeepassSettings();

    QAbstractListModel* recentDatabaseModel() const { return (QAbstractListModel*)m_recentDatabaseModel.data(); }
    QString version() const { return m_version; }
    bool simpleMode() const { return m_simpleMode; }
    void setSimpleMode(const bool value);
    int defaultCryptAlgorithm() const { return m_defaultCryptAlgorithm; }
    void setDefaultCryptAlgorithm(const int value);
    int defaultKeyTransfRounds() const { return m_defaultKeyTransfRounds; }
    void setDefaultKeyTransfRounds(const int value);
    int locktime() const { return m_locktime; }
    void setLocktime(const int value);
    bool showUserNamePasswordInListView() const { return m_showUserNamePasswordInListView; }
    void setShowUserNamePasswordInListView(const bool value);
    bool showSearchBar() const { return m_showSearchBar; }
    void setShowSearchBar(const bool value);
    bool focusSearchBarOnStartup() const { return m_focusSearchBarOnStartup; }
    void setFocusSearchBarOnStartup(const bool value);
    bool showUserNamePasswordOnCover() const { return m_showUserNamePasswordOnCover; }
    void setShowUserNamePasswordOnCover(const bool value);
    bool lockDatabaseFromCover() const { return m_lockDatabaseFromCover; }
    void setLockDatabaseFromCover(const bool value);
    bool copyNpasteFromCover() const { return m_copyNpasteFromCover; }
    void setCopyNpasteFromCover(const bool value);
    bool loadLastDb() const { return m_loadLastDb; }
    void setLoadLastDb(const bool value);
    int pwGenLength() const { return m_pwGenLength; }
    void setPwGenLength(const int value);
    bool pwGenLowerLetters() const { return m_pwGenLowerLetters; }
    void setPwGenLowerLetters(const bool value);
    bool pwGenUpperLetters() const { return m_pwGenUpperLetters; }
    void setPwGenUpperLetters(const bool value);
    bool pwGenNumbers() const { return m_pwGenNumbers; }
    void setPwGenNumbers(const bool value);
    bool pwGenSpecialChars() const { return m_pwGenSpecialChars; }
    void setPwGenSpecialChars(const bool value);
    bool pwGenExcludeLookAlike() const { return m_pwGenExcludeLookAlike; }
    void setPwGenExcludeLookAlike(const bool value);
    bool pwGenCharFromEveryGroup() const { return m_pwGenCharFromEveryGroup; }
    void setPwGenCharFromEveryGroup(const bool value);
    int clearClipboard() const { return m_clearClipboard; }
    void setClearClipboard(const int value);
    int language() const { return m_language; }
    void setLanguage(const int value);
    bool fastUnlock() const { return m_fastUnlock; }
    void setFastUnlock(const bool value);
    int fastUnlockRetryCount() const { return m_fastUnlockRetryCount; }
    void setFastUnlockRetryCount(const int value);

    void checkSettingsVersion();

signals:
    // Signal to QML
    void showChangeLogBanner();
    void loadLastDatabase(int dbLocation,
                          QString dbFilePath,
                          bool useKeyFile,
                          int keyFileLocation,
                          QString keyFilePath);
    void databaseInSimpleMode(bool databaseExists,
                              int dbLocation,
                              QString dbFilePath,
                              bool useKeyFile,
                              int keyFileLocation,
                              QString keyFilePath);

    // Signals for property
    void recentDatabaseModelChanged();
    void versionChanged();
    void simpleModeChanged();
    void defaultCryptAlgorithmChanged();
    void defaultKeyTransfRoundsChanged();
    void locktimeChanged();
    void showUserNamePasswordInListViewChanged();
    void showSearchBarChanged();
    void focusSearchBarOnStartupChanged();
    void showUserNamePasswordOnCoverChanged();
    void lockDatabaseFromCoverChanged();
    void copyNpasteFromCoverChanged();
    void loadLastDbChanged();
    void pwGenLengthChanged();
    void pwGenLowerLettersChanged();
    void pwGenUpperLettersChanged();
    void pwGenNumbersChanged();
    void pwGenSpecialCharsChanged();
    void pwGenExcludeLookAlikeChanged();
    void pwGenCharFromEveryGroupChanged();
    void clearClipboardChanged();
    void languageChanged();
    void fastUnlockChanged();
    void fastUnlockRetryCountChanged();

private:
    void loadSettings();

private:
    QScopedPointer<settingsPrivate::RecentDatabaseListModel> m_recentDatabaseModel;
    OwnKeepassHelper *m_helper; // owned by parent

    // Settings version
    // This is used to check if settings from some older ownKeepass version are available
    // If yes they might need to be merged into new version
    QString m_previousVersion; // this is to internally detect if the settings.ini file has an older version than the application
    QString m_version;
    bool m_simpleMode;
    // Default encryption: AES/Rijndael = 0, Twofish = 1
    int m_defaultCryptAlgorithm;
    int m_defaultKeyTransfRounds;
    int m_locktime;  // min = 0, max = 10, default = 3
    bool m_showUserNamePasswordInListView;
    bool m_showSearchBar;
    bool m_focusSearchBarOnStartup;
    bool m_showUserNamePasswordOnCover;
    bool m_lockDatabaseFromCover;
    bool m_copyNpasteFromCover;

    // false: do not auto load last opened database
    // true: load last database on startup automatically
    bool m_loadLastDb;
    QList<QVariantMap> m_recentDatabaseList;
    int m_recentDatabaseListLength;

    // settings for password generator
    int m_pwGenLength;
    bool m_pwGenLowerLetters;
    bool m_pwGenUpperLetters;
    bool m_pwGenNumbers;
    bool m_pwGenSpecialChars;
    bool m_pwGenExcludeLookAlike;
    bool m_pwGenCharFromEveryGroup;

    int m_clearClipboard;
    int m_language;
    bool m_fastUnlock;
    int m_fastUnlockRetryCount;

    Settings* m_settings;
};

} // namespace
#endif // OWNKEEPASSSETTINGS_H
