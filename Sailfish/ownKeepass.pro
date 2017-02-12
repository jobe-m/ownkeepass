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
include(../common/src/keepassPlugin/keepass1_database/keepass1_database.pri)
include(../common/src/keepassPlugin/keepass2_database/keepass2_database.pri)
include(../common/src/keepassPlugin/databaseInterface/databaseInterface.pri)
include(../common/src/fileBrowserPlugin/fileBrowserPlugin.pri)
include(../common/src/passwordGeneratorAdapter/passwordGeneratorAdapter.pri)

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

# Following define is a trick to load the appropriate libraries of libgcrypt and libgpg-error depending
#   if compiled for emulator/jolla tablet (i486) or jolla phone (armv7hl)
#
# BE AWARE this only works on (Ubuntu) Linux, on Mac OS X and Windows you might need to specify ARCH_LIBS directly
# Loading wrong architecture of libs into the rpm package will result in a not working app!
#
linux-g++-32 {
    message(Loading libs for emulator / jolla tablet (i486))
    ARCH_LIBS=i486_x86
}
linux-g++ {
    message(Loading libs for jolla phone (arm))
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
common_files.path   = /usr/share/$${TARGET}
common_files.files += \
    ../common/images/covericons \
    ../common/images/wallicons
password_generator_lib.path   = /usr/share/$${TARGET}/lib
password_generator_lib.files += \
    ../common/libs/$$ARCH_LIBS/libgcrypt.so.11 \
    ../common/libs/$$ARCH_LIBS/libgpg-error.so.0

# process all application icon sizes
icon_file_86x86.path    = /usr/share/icons/hicolor/86x86/apps
icon_file_86x86.files   = icons/86x86/$${TARGET}.png
icon_file_108x108.path  = /usr/share/icons/hicolor/108x108/apps
icon_file_108x108.files = icons/108x108/$${TARGET}.png
icon_file_128x128.path  = /usr/share/icons/hicolor/128x128/apps
icon_file_128x128.files = icons/128x128/$${TARGET}.png
icon_file_256x256.path  = /usr/share/icons/hicolor/256x256/apps
icon_file_256x256.files = icons/256x256/$${TARGET}.png

# icons are put into resources
#QMAKE_RESOURCE_FLAGS += -no-compress
RESOURCES = ../common/images/icons.qrc

INSTALLS += \
    common_files \
    password_generator_lib \
    icon_file_86x86 \
    icon_file_108x108 \
    icon_file_128x128 \
    icon_file_256x256

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
    ../common/src/OwnKeepassHelper.h \
    ../common/src/ownKeepassGlobal.h

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
    qml/help/HelpMasterGroupsPage.qml \
    qml/help/HelpSubGroupsPage.qml \
    qml/content/PasswordGeneratorDialog.qml \
    qml/content/LicensePage.qml \
    qml/content/ChangeLogPage.qml \
    qml/content/LockPage.qml \
    qml/common/FileSystemDialog.qml \
    qml/content/MovePasswordEntryDialog.qml \
    qml/common/SilicaMenuLabel.qml \
    qml/components/MainPageMoreDetails.qml \
    qml/common/PasswordFieldCombo.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-ownkeepass-ca.ts \
    translations/harbour-ownkeepass-zh_CN.ts \
    translations/harbour-ownkeepass-cs_CZ.ts \
    translations/harbour-ownkeepass-da.ts \
    translations/harbour-ownkeepass-nl_NL.ts \
    translations/harbour-ownkeepass-en.ts \
    translations/harbour-ownkeepass-fi_FI.ts \
    translations/harbour-ownkeepass-fr_FR.ts \
    translations/harbour-ownkeepass-de_DE.ts \
    translations/harbour-ownkeepass-it.ts \
    translations/harbour-ownkeepass-nb_NO.ts \
    #translations/harbour-ownkeepass-pl_PL.ts \
    translations/harbour-ownkeepass-ru.ts \
    translations/harbour-ownkeepass-es.ts \
    translations/harbour-ownkeepass-sv_SE.ts \
    #translations/harbour-ownkeepass-uk_UA.ts \
    translations/harbour-ownkeepass-el.ts \
    translations/harbour-ownkeepass-ja_JP.ts \
    translations/harbour-ownkeepass-hu_HU.ts \
    translations/harbour-ownkeepass-gl.ts

DISTFILES += \
    qml/content/EditItemIconDialog.qml
