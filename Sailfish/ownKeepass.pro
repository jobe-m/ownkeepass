#***************************************************************************
#**
#** Copyright (C) 2013 - 2014 Marko Koschak (marko.koschak@tisno.de)
#** All rights reserved.
#**
#** This file is part of ownKeepass.
#**
#** ownKeepass is free software: you can redistribute it and/or modify
#** it under the terms of the GNU General Public License as published by
#** the Free Software Foundation, either version 2 of the License, or
#** (at your option) any later version.
#**
#** ownKeepass is distributed in the hope that it will be useful,
#** but WITHOUT ANY WARRANTY; without even the implied warranty of
#** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#** GNU General Public License for more details.
#**
#** You should have received a copy of the GNU General Public License
#** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
#**
#***************************************************************************

# the sources of the keepass QML plugins
include(../common/src/keepassPlugin/kdb3database/kdb3database.pri)
include(../common/src/keepassPlugin/databaseInterface/databaseInterface.pri)

# The name of the app
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-ownkeepass

# adding common qml and image files for the app
common_qml_and_image_files.files += \
    ../common/images/entryicons \
    ../common/images/covericons \
    ../common/images/wallicons
common_qml_and_image_files.path = /usr/share/$${TARGET}
INSTALLS += common_qml_and_image_files

# adding standard installation paths for a sailfish OS app
CONFIG += sailfishapp

# C++ sources
SOURCES += src/main.cpp

OTHER_FILES += \
    ../README.md \
    ../LICENSE \
    harbour-ownkeepass.desktop \
    qml/harbour-ownkeepass.qml \
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
    qml/content/MainPageSimple.qml \
    qml/content/MainPage.qml \
    qml/content/KdbListItem.qml \
    qml/content/HelpPage.qml \
    qml/content/GroupsAndEntriesPage.qml \
    qml/content/FileBrowserPage.qml \
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
    rpm/harbour-ownkeepass.spec \
    rpm/harbour-ownkeepass.yaml
