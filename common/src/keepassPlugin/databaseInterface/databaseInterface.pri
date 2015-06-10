#***************************************************************************
#**
#** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
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

# for optimizing string construction
DEFINES *= QT_USE_QSTRINGBUILDER

INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

SOURCES += \
    ../common/src/keepassPlugin/databaseInterface/KdbDatabase.cpp \
    ../common/src/keepassPlugin/databaseInterface/KdbListModel.cpp \
    ../common/src/keepassPlugin/databaseInterface/KdbEntry.cpp \
    ../common/src/keepassPlugin/databaseInterface/KdbGroup.cpp \
    ../common/src/keepassPlugin/databaseInterface/private/DatabaseClient.cpp \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass1DatabaseFactory.cpp \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass2DatabaseFactory.cpp \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass1DatabaseInterface.cpp \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass2DatabaseInterface.cpp \

HEADERS += \
    ../common/src/keepassPlugin/databaseInterface/KdbDatabase.h \
    ../common/src/keepassPlugin/databaseInterface/KdbListModel.h \
    ../common/src/keepassPlugin/databaseInterface/KdbEntry.h \
    ../common/src/keepassPlugin/databaseInterface/KdbGroup.h \
    ../common/src/keepassPlugin/databaseInterface/private/DatabaseClient.h \
    ../common/src/keepassPlugin/databaseInterface/private/AbstractDatabaseFactory.h \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass1DatabaseFactory.h \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass2DatabaseFactory.h \
    ../common/src/keepassPlugin/databaseInterface/private/AbstractDatabaseInterface.h \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass1DatabaseInterface.h \
    ../common/src/keepassPlugin/databaseInterface/private/Keepass2DatabaseInterface.h \

