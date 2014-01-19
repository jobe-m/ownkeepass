#include "OwnKeepassSettings.h"

using namespace settingsPublic;

const QString OWN_KEEPASS_VERSION("0.9.5");

OwnKeepassSettings::OwnKeepassSettings(const QString filePath, QObject *parent):
    QObject(parent),
    m_previousVersion(""),
    m_version(OWN_KEEPASS_VERSION),
    m_defaultCryptAlgorithm(0),
    m_defaultKeyTransfRounds(5000),
    m_locktime(3),
    m_showUserNamePasswordInListView(0),
    m_showUserNamePasswordOnCover(1),
    m_lockDatabaseFromCover(1),
    m_copyNpasteFromCover(1),
    m_loadLastDb(0),
    m_settings(filePath)
{}

void OwnKeepassSettings::saveSettings() {
    m_settings.setValue("version", m_version);
    m_settings.setValue("version", QString::number(m_defaultCryptAlgorithm));
    m_settings.getValue("defaultKeyTransfRounds", QString::number(m_defaultKeyTransfRounds));
    m_settings.getValue("locktime", QString::number(m_locktime));
    m_settings.getValue("showUserNamePasswordInListView", QString::number(m_showUserNamePasswordInListView));
    m_settings.getValue("showUserNamePasswordOnCover", QString::number(m_showUserNamePasswordOnCover));
    m_settings.getValue("lockDatabaseFromCover", QString::number(m_lockDatabaseFromCover));
    m_settings.getValue("copyNpasteFromCover", QString::number(m_copyNpasteFromCover));
    m_settings.getValue("loadLastDb", QString::number(m_loadLastDb));
}

void OwnKeepassSettings::loadSettings() {
    m_previousVersion = settings.getValue("version", m_version);
    // take over until some conversation of values is needed
    m_version = m_previousVersion;
    m_defaultCryptAlgorithm          = (m_settings.getValue("defaultCryptAlgorithm", QString::number(m_defaultCryptAlgorithm))).toInt();
    m_defaultKeyTransfRounds         = (m_settings.getValue("defaultKeyTransfRounds", QString::number(m_defaultKeyTransfRounds))).toInt();
    m_locktime                       = (m_settings.getValue("locktime", QString::number(m_locktime))).toInt();
    m_showUserNamePasswordInListView = (m_settings.getValue("showUserNamePasswordInListView", QString::number(m_showUserNamePasswordInListView))).toInt();
    m_showUserNamePasswordOnCover    = (m_settings.getValue("showUserNamePasswordOnCover", QString::number(m_showUserNamePasswordOnCover))).toInt();
    m_lockDatabaseFromCover          = (m_settings.getValue("lockDatabaseFromCover", QString::number(m_lockDatabaseFromCover))).toInt();
    m_copyNpasteFromCover            = (m_settings.getValue("copyNpasteFromCover", QString::number(m_copyNpasteFromCover))).toInt();
    m_loadLastDb                     = (m_settings.getValue("loadLastDb", QString::number(m_loadLastDb))).toInt();
}
