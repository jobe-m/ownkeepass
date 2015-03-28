############################################################################
#
# Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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

# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# Sources of the keepass QML plugins
include(../common/src/keepassPlugin/kdbxdatabase/kdbxdatabase.pri)



# The name of your application
TARGET = module_tests

CONFIG += sailfishapp

SOURCES += module_tests/src/module_tests.cpp

OTHER_FILES += module_tests/qml/module_tests.qml \
    module_tests/qml/cover/CoverPage.qml \
    module_tests/qml/pages/FirstPage.qml \
    module_tests/qml/pages/SecondPage.qml \
    module_tests/rpm/module_tests.changes.in \
    module_tests/rpm/module_tests.spec \
    module_tests/rpm/module_tests.yaml \
    module_tests/module_tests.desktop

HEADERS +=
