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
{
    loadSettings();
}

void OwnKeepassSettings::saveSettings() {
    qDebug() << "saveSettings";
    m_settings.setValue("settings/version", m_version);
    m_settings.setValue("settings/version", QString::number(m_defaultCryptAlgorithm));
    m_settings.getValue("settings/defaultKeyTransfRounds", QString::number(m_defaultKeyTransfRounds));
    m_settings.getValue("settings/locktime", QString::number(m_locktime));
    m_settings.getValue("settings/showUserNamePasswordInListView", QString::number(m_showUserNamePasswordInListView));
    m_settings.getValue("settings/showUserNamePasswordOnCover", QString::number(m_showUserNamePasswordOnCover));
    m_settings.getValue("settings/lockDatabaseFromCover", QString::number(m_lockDatabaseFromCover));
    m_settings.getValue("settings/copyNpasteFromCover", QString::number(m_copyNpasteFromCover));
    m_settings.getValue("settings/loadLastDb", QString::number(m_loadLastDb));
}

void OwnKeepassSettings::loadSettings() {
    qDebug() << "loadSettings";
    m_previousVersion = (m_settings.getValue("settings/version", m_version)).toString();
    // take over until some conversation of values is needed
    m_version = m_previousVersion;
    m_defaultCryptAlgorithm          = (m_settings.getValue("settings/defaultCryptAlgorithm", QString::number(m_defaultCryptAlgorithm))).toInt();
    m_defaultKeyTransfRounds         = (m_settings.getValue("settings/defaultKeyTransfRounds", QString::number(m_defaultKeyTransfRounds))).toInt();
    m_locktime                       = (m_settings.getValue("settings/locktime", QString::number(m_locktime))).toInt();
    m_showUserNamePasswordInListView = (m_settings.getValue("settings/showUserNamePasswordInListView", QString::number(m_showUserNamePasswordInListView))).toInt();
    m_showUserNamePasswordOnCover    = (m_settings.getValue("settings/showUserNamePasswordOnCover", QString::number(m_showUserNamePasswordOnCover))).toInt();
    m_lockDatabaseFromCover          = (m_settings.getValue("settings/lockDatabaseFromCover", QString::number(m_lockDatabaseFromCover))).toInt();
    m_copyNpasteFromCover            = (m_settings.getValue("settings/copyNpasteFromCover", QString::number(m_copyNpasteFromCover))).toInt();
    m_loadLastDb                     = (m_settings.getValue("settings/loadLastDb", QString::number(m_loadLastDb))).toInt();
}
