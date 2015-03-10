############################################################################
#
# Copyright (C) 2013 - 2015 Marko Koschak (marko.koschak@tisno.de)
# All rights reserved.
#
# This file is part of ownKeepass.
#
# ownKeepass is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# ownKeepass is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

# Sources of the keepass QML plugins
include(../common/src/keepassPlugin/kdb3database/kdb3database.pri)
include(../common/src/keepassPlugin/databaseInterface/databaseInterface.pri)
include(../common/src/fileBrowserPlugin/fileBrowserPlugin.pri)

# Get release version from .spec file and paste it further to c++ through a define
isEmpty(VERSION) {
    GIT_TAG = $$system(git describe --tags --abbrev=0)
    GIT_VERSION = $$find(GIT_TAG, ^\\d+(\\.\\d+)?(\\.\\d+)?$)
    isEmpty(GIT_VERSION) {
        # Taking git tag as fallback but this shouldn't really happen
        warning("Can't find a valid git tag version, got: $$GIT_TAG")
        GIT_VERSION = 0.0.0
    }
    !isEmpty(GIT_VERSION): VERSION = $$GIT_VERSION
}
DEFINES += PROGRAMVERSION=\\\"$$VERSION\\\"

# Following define is a trick to load the desired precompiled version of a plugin
# Depending if compiling for emulator or the real device
linux-g++-32 {
    message("Loading libs for emulator")
    ARCH_LIBS=i486_x86
}

linux-g++ {
    message("Loading libs for jolla device")
    ARCH_LIBS=armv7hl
}

# The name of the app
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-ownkeepass

# adding common QML files, QML imports, C++ libs and image files for the app
common_files.files += \
    ../common/images/entryicons \
    ../common/images/covericons \
    ../common/images/wallicons
password_generator_qmldir.files += \
    ../common/qml/imports/PasswordGenerator/qmldir
password_generator_lib.files += \
    ../common/qml/imports/PasswordGenerator/$$ARCH_LIBS/libPasswordGenerator.so \
    ../common/qml/imports/PasswordGenerator/$$ARCH_LIBS/libgcrypt.so.11 \
    ../common/qml/imports/PasswordGenerator/$$ARCH_LIBS/libgpg-error.so.0

common_files.path = /usr/share/$${TARGET}
password_generator_qmldir.path = /usr/share/$${TARGET}/lib/harbour/ownkeepass/PasswordGenerator
password_generator_lib.path = /usr/share/$${TARGET}/lib

INSTALLS += \
    common_files \
    password_generator_lib \
    password_generator_qmldir

# adding standard installation paths for a sailfish OS app
CONFIG += sailfishapp

INCLUDEPATH += ../common/src/settings \
    ../common/src

# C++ sources
SOURCES += src/main.cpp \
    ../common/src/settings/setting.cpp \
    ../common/src/settings/RecentDatabaseListModel.cpp \
    ../common/src/settings/OwnKeepassSettings.cpp \
    ../common/src/OwnKeepassHelper.cpp

# C++ headers
HEADERS += \
    ../common/src/settings/setting.h \
    ../common/src/settings/RecentDatabaseListModel.h \
    ../common/src/settings/OwnKeepassSettings.h \
    ../common/src/OwnKeepassHelper.h

OTHER_FILES += \
    ../README.md \
    ../LICENSE \
    qml/common/ViewSearchPlaceholder.qml \
    qml/common/Tracer.qml \
    qml/common/SilicaLabel.qml \
    qml/common/SilicaCoverPlaceholder.qml \
    qml/common/QueryDialog.qml \
    qml/common/PageHeaderExtended.qml \
    qml/common/InfoPopup.qml \
    qml/content/ShowEntryDetailsPage.qml \
    qml/content/SelectDatabasePage.qml \
    qml/content/QueryPasswordDialog.qml \
    qml/content/KdbListItem.qml \
    qml/help/HelpPage.qml \
    qml/content/GroupsAndEntriesPage.qml \
    qml/content/ChangeLogPage.qml \
    qml/content/EditSettingsDialog.qml \
    qml/content/EditGroupDetailsDialog.qml \
    qml/content/EditEntryDetailsDialog.qml \
    qml/content/EditDatabaseSettingsDialog.qml \
    qml/content/DatabaseMenu.qml \
    qml/content/ApplicationMenu.qml \
    qml/content/AboutPage.qml \
    qml/cover/CoverPage.qml \
    qml/scripts/Global.js \
    qml/common/SilicaViewPlaceholder.qml \
    rpm/harbour-ownkeepass.yaml \
    harbour-ownkeepass.desktop \
    rpm/harbour-ownkeepass.spec \
    qml/Main.qml \
    qml/content/MainPage.qml \
    qml/help/HelpMainPage.qml \
    qml/help/HelpCreateNewDatabase.qml \
    qml/help/HelpOpenNewDatabase.qml \
    qml/help/HelpOpenRecentDatabase.qml \
    qml/help/HelpDatabaseSettings.qml \
    qml/help/HelpSettings.qml \
    qml/help/HelpMasterGroupsPage.qml \
    qml/help/HelpSubGroupsPage.qml \
    qml/content/PasswordGeneratorDialog.qml \
    qml/content/LicensePage.qml \
    qml/content/ChangeLogPage.qml \
    qml/content/LockPage.qml \
    qml/common/FileSystemDialog.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-ownkeepass-ca.ts \
    translations/harbour-ownkeepass-zh_CN.ts \
    translations/harbour-ownkeepass-cs_CZ.ts \
    translations/harbour-ownkeepass-da.ts \
    translations/harbour-ownkeepass-nl_NL.ts \
    # en_GB is default language
    translations/harbour-ownkeepass-fi_FI.ts \
    translations/harbour-ownkeepass-fr_FR.ts \
    translations/harbour-ownkeepass-de_DE.ts \
    translations/harbour-ownkeepass-it.ts \
#    translations/harbour-ownkeepass-pl_PL.ts
    translations/harbour-ownkeepass-ru.ts \
    translations/harbour-ownkeepass-es.ts \
    translations/harbour-ownkeepass-sv_SE.ts
#    translations/harbour-ownkeepass-uk_UA.ts
