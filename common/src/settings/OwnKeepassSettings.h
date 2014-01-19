#ifndef OWNKEEPASSSETTINGS_H
#define OWNKEEPASSSETTINGS_H

#include <QObject>
#include "setting.h"

namespace settingsPublic {

class OwnKeepassSettings : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString version READ version WRITE setVersion)
    Q_PROPERTY(int defaultCryptoAlgorithm READ defaultCryptoAlgorithm WRITE setDefaultCryptoAlgorithm NOTIFY defaultCryptoAlgorithmChanged)
    Q_PROPERTY(int defaultKeyTransfRounds READ defaultKeyTransfRounds WRITE setDefaultKeyTransfRounds NOTIFY defaultKeyTransfRoundsChanged)
    Q_PROPERTY(int locktime READ locktime WRITE setLocktime NOTIFY locktimeChanged)
    Q_PROPERTY(int showUserNamePasswordInListView READ showUserNamePasswordInListView WRITE setShowUserNamePasswordInListView NOTIFY showUserNamePasswordInListViewChanged)
    Q_PROPERTY(int showUserNamePasswordOnCover READ showUserNamePasswordOnCover WRITE setShowUserNamePasswordOnCover NOTIFY showUserNamePasswordOnCoverChanged)
    Q_PROPERTY(int lockDatabaseFromCover READ lockDatabaseFromCover WRITE setLockDatabaseFromCover NOTIFY lockDatabaseFromCoverChanged)
    Q_PROPERTY(int copyNpasteFromCover READ copyNpasteFromCover WRITE setCopyNpasteFromCover NOTIFY copyNpasteFromCoverChanged)
    Q_PROPERTY(int loadLastDb READ loadLastDb WRITE setLoadLastDb NOTIFY loadLastDbChanged)

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();

public:
    OwnKeepassSettings(const QString filePath, QObject *parent = 0);
    virtual ~OwnKeepassSettings() {}

    QString version() const { return m_version; }
    void setVersion(const QString value) { m_version = value; }
    int defaultCryptoAlgorithm() const { return m_defaultCryptAlgorithm; }
    void setDefaultCryptoAlgorithm(const int value) { m_defaultCryptAlgorithm = value; }
    int defaultKeyTransfRounds() const { return m_defaultKeyTransfRounds; }
    void setDefaultKeyTransfRounds(const int value) { m_defaultKeyTransfRounds = value; }
    int locktime() const { return m_locktime; }
    void setLocktime(const int value) { m_locktime = value; }
    int showUserNamePasswordInListView() const { return m_showUserNamePasswordInListView; }
    void setShowUserNamePasswordInListView(const int value) { m_showUserNamePasswordInListView = value; }
    int showUserNamePasswordOnCover() const { return m_showUserNamePasswordOnCover; }
    void setShowUserNamePasswordOnCover(const int value) { m_showUserNamePasswordOnCover = value; }
    int lockDatabaseFromCover() const { return m_lockDatabaseFromCover; }
    void setLockDatabaseFromCover(const int value) { m_lockDatabaseFromCover = value; }
    int copyNpasteFromCover() const { return m_copyNpasteFromCover; }
    void setCopyNpasteFromCover(const int value) { m_copyNpasteFromCover = value; }
    int loadLastDb() const { return m_loadLastDb; }
    void setLoadLastDb(const int value) { m_loadLastDb = value; }

private:
    // Settings version
    // This is used to check if settings from some older ownKeepass version are available
    // If yes they might need to be merged into new version
    QString m_previousVersion; // this is to internally detect if the settings.ini file has an older version than the application
    QString m_version;
    // Default encryption: AES/Rijndael = 0, Twofish = 1
    int m_defaultCryptAlgorithm;
    int m_defaultKeyTransfRounds;
    int m_locktime;  // min = 0, max = 10, default = 3
    // 0: false
    // 1: true
    int m_showUserNamePasswordInListView;
    int m_showUserNamePasswordOnCover;
    int m_lockDatabaseFromCover;
    int m_copyNpasteFromCover;
    // Load as default
    // 0: false: do not auto load last opened database
    // 1: true: load last database on startup automatically
    int m_loadLastDb;

    Settings m_settings;
};

} // namespace
#endif // OWNKEEPASSSETTINGS_H
