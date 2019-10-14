/***************************************************************************
**
** Copyright (C) 2012 - 2019 Marko Koschak (marko.koschak@tisno.de)
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

#ifndef KDBDATABASE_H
#define KDBDATABASE_H

#include <QObject>
#include <QFile>

namespace kpxPublic {

class KdbDatabase : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(int keyTransfRounds READ keyTransfRounds WRITE setKeyTransfRounds NOTIFY keyTransfRoundsChanged)
    Q_PROPERTY(int cryptAlgorithm READ cryptAlgorithm WRITE setCryptAlgorithm NOTIFY cryptAlgorithmChanged)
    Q_PROPERTY(int keyDerivationFunction READ keyDerivationFunction WRITE setKeyDerivationFunction NOTIFY keyDerivationFunctionChanged)
    Q_PROPERTY(bool showUserNamePasswordsInListView READ showUserNamePasswordsInListView WRITE setShowUserNamePasswordsInListView STORED true SCRIPTABLE true)
    Q_PROPERTY(bool sortAlphabeticallyInListView READ sortAlphabeticallyInListView WRITE setSortAlphabeticallyInListView STORED true SCRIPTABLE true)
    Q_PROPERTY(bool readOnly READ readOnly NOTIFY readOnlyChanged)

public: // QtQuick 1.1 needs here a public keyword otherwise if does not find the next function ???
    Q_INVOKABLE void open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readOnly);
    Q_INVOKABLE void create(const QString& dbFilePath, const QString &keyFilePath, const QString& password);
    Q_INVOKABLE void close();
    Q_INVOKABLE void changePassword(const QString& password, const QString &keyFile);
    Q_INVOKABLE void saveSettings();

public:
    KdbDatabase(QObject* parent=0);
    virtual ~KdbDatabase() {}

    int keyTransfRounds() const { return m_keyTransfRounds; }
    void setKeyTransfRounds(const int value) { m_keyTransfRounds = value; }
    int cryptAlgorithm() const { return m_cryptAlgorithm; }
    void setCryptAlgorithm(const int value) { m_cryptAlgorithm = value; }
    int keyDerivationFunction() const { return m_keyDerivationFunction; }
    void setKeyDerivationFunction(const int value) { m_keyDerivationFunction = value; }
    bool showUserNamePasswordsInListView() const { return m_showUserNamePasswordsInListView; }
    void setShowUserNamePasswordsInListView(bool value) { m_showUserNamePasswordsInListView = value; emit setting_showUserNamePasswordsInListView(value); }
    bool sortAlphabeticallyInListView() const { return m_sortAlphabeticallyInListView; }
    void setSortAlphabeticallyInListView(const bool value) { m_sortAlphabeticallyInListView = value; emit setting_sortAlphabeticallyInListView(value); }
    bool readOnly() const { return m_readOnly; }

signals:
    // signals to DatabaseClient backend thread
    void openDatabase(QString filePath, QString password, QString keyfile, bool readOnly);
    void createNewDatabase(QString filePath, QString password, QString keyfile, int cryptAlgorithm, int keyTransfRounds);
    void closeDatabase();
    void changeDatabasePassword(QString password, QString keyFile);
    void changeDatabaseSettings(int cryptAlgo, int kdf, int rounds);
    void setting_showUserNamePasswordsInListView(bool value);
    void setting_sortAlphabeticallyInListView(bool value);

    // signals to QML
    void databaseOpened(int result, QString errorMsg);
    void newDatabaseCreated();
    void databaseClosed();
    void databasePasswordChanged();
    void keyTransfRoundsChanged();
    void cryptAlgorithmChanged();
    void keyDerivationFunctionChanged();
    void errorOccured(int result, QString errorMsg);
    void readOnlyChanged();
    void typeChanged();

private slots:
    // signals from DatabaseClient backend thread
    void slot_databaseSettingsChanged(int cryptAlgo, int kdf, int rounds);
    void slot_databaseClosed();
    void slot_databaseOpened(int result, QString errorMsg);

private:
    // The following properties are read from backend and therefore there are slots for it
    int m_keyTransfRounds;
    int m_cryptAlgorithm;
    int m_keyDerivationFunction;
    // Settings are simply passed over to the backend thread
    bool m_showUserNamePasswordsInListView;
    bool m_sortAlphabeticallyInListView;

    bool m_readOnly;

    Q_DISABLE_COPY(KdbDatabase)
};

}
#endif // KDBDATABASE_H
