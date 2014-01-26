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

#ifndef OWNKEEPASSSETTINGS_H
#define OWNKEEPASSSETTINGS_H

#include <QObject>
#include <QAbstractListModel>
#include "setting.h"
#include "RecentDatabaseListModel.h"

namespace settingsPublic {

const QString OWN_KEEPASS_VERSION("0.9.7");

class OwnKeepassSettings : public QObject
{
    Q_OBJECT

public:
//    Q_PROPERTY(QAbstractListModel* recentDatabaseModel READ recentDatabaseModel NOTIFY recentDatabaseModelChanged)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(bool simpleMode READ simpleMode WRITE setSimpleMode NOTIFY simpleModeChanged)
    Q_PROPERTY(int defaultCryptAlgorithm READ defaultCryptAlgorithm WRITE setDefaultCryptAlgorithm NOTIFY defaultCryptAlgorithmChanged)
    Q_PROPERTY(int defaultKeyTransfRounds READ defaultKeyTransfRounds WRITE setDefaultKeyTransfRounds NOTIFY defaultKeyTransfRoundsChanged)
    Q_PROPERTY(int locktime READ locktime WRITE setLocktime NOTIFY locktimeChanged)
    Q_PROPERTY(bool showUserNamePasswordInListView READ showUserNamePasswordInListView WRITE setShowUserNamePasswordInListView NOTIFY showUserNamePasswordInListViewChanged)
    Q_PROPERTY(bool showUserNamePasswordOnCover READ showUserNamePasswordOnCover WRITE setShowUserNamePasswordOnCover NOTIFY showUserNamePasswordOnCoverChanged)
    Q_PROPERTY(bool lockDatabaseFromCover READ lockDatabaseFromCover WRITE setLockDatabaseFromCover NOTIFY lockDatabaseFromCoverChanged)
    Q_PROPERTY(bool copyNpasteFromCover READ copyNpasteFromCover WRITE setCopyNpasteFromCover NOTIFY copyNpasteFromCoverChanged)
    Q_PROPERTY(bool loadLastDb READ loadLastDb WRITE setLoadLastDb NOTIFY loadLastDbChanged)

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void addRecentDatabase(QString uiName,
                                       QString uiPath,
                                       int dbLocation,
                                       QString dbFilePath,
                                       bool useKeyFile,
                                       int keyFileLocation,
                                       QString keyFilePath);
    Q_INVOKABLE void checkLoadLastDatabase();

public:
    OwnKeepassSettings(const QString filePath, QObject *parent = 0);
    virtual ~OwnKeepassSettings();

    QAbstractListModel* recentDatabaseModel() const { return (QAbstractListModel*)m_recentDatabaseModel.data(); }
    QString version() const { return m_version; }
    bool simpleMode() const { return m_simpleMode; }
    void setSimpleMode(const bool value) { m_simpleMode = value;}
    int defaultCryptAlgorithm() const { return m_defaultCryptAlgorithm; }
    void setDefaultCryptAlgorithm(const int value) { m_defaultCryptAlgorithm = value; }
    int defaultKeyTransfRounds() const { return m_defaultKeyTransfRounds; }
    void setDefaultKeyTransfRounds(const int value) { m_defaultKeyTransfRounds = value; }
    int locktime() const { return m_locktime; }
    void setLocktime(const int value) { m_locktime = value; }
    bool showUserNamePasswordInListView() const { return m_showUserNamePasswordInListView; }
    void setShowUserNamePasswordInListView(const bool value) { m_showUserNamePasswordInListView = value; }
    bool showUserNamePasswordOnCover() const { return m_showUserNamePasswordOnCover; }
    void setShowUserNamePasswordOnCover(const bool value) { m_showUserNamePasswordOnCover = value; }
    bool lockDatabaseFromCover() const { return m_lockDatabaseFromCover; }
    void setLockDatabaseFromCover(const bool value) { m_lockDatabaseFromCover = value; }
    bool copyNpasteFromCover() const { return m_copyNpasteFromCover; }
    void setCopyNpasteFromCover(const bool value) { m_copyNpasteFromCover = value; }
    bool loadLastDb() const { return m_loadLastDb; }
    void setLoadLastDb(const bool value);

signals:
    // signal for property
    void recentDatabaseModelChanged();
    void versionChanged();
    void simpleModeChanged();
    void defaultCryptAlgorithmChanged();
    void defaultKeyTransfRoundsChanged();
    void locktimeChanged();
    void showUserNamePasswordInListViewChanged();
    void showUserNamePasswordOnCoverChanged();
    void lockDatabaseFromCoverChanged();
    void copyNpasteFromCoverChanged();
    void loadLastDbChanged();
    void loadLastDatabase(int dbLocation,
                          QString dbFilePath,
                          bool useKeyFile,
                          int keyFileLocation,
                          QString keyFilePath);

private:
    QScopedPointer<settingsPrivate::RecentDatabaseListModel> m_recentDatabaseModel;

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
    // false
    // true
    bool m_showUserNamePasswordInListView;
    bool m_showUserNamePasswordOnCover;
    bool m_lockDatabaseFromCover;
    bool m_copyNpasteFromCover;

    // false: do not auto load last opened database
    // true: load last database on startup automatically
    bool m_loadLastDb;
    QList<QVariantMap> m_recentDatabaseList;
    int m_recentDatabaseListLength;

    Settings* m_settings;
};

} // namespace
#endif // OWNKEEPASSSETTINGS_H
