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
    src/keepassPlugin/databaseInterface/private/KdbInterface.cpp \
    src/keepassPlugin/databaseInterface/private/KdbInterfaceWorker.cpp \
    src/keepassPlugin/databaseInterface/KdbDatabase.cpp \
    src/keepassPlugin/databaseInterface/KdbListModel.cpp \
    src/keepassPlugin/databaseInterface/KdbEntry.cpp \
    src/keepassPlugin/databaseInterface/KdbGroup.cpp

HEADERS += \
    src/keepassPlugin/databaseInterface/private/KdbInterface.h \
    src/keepassPlugin/databaseInterface/private/KdbInterfaceWorker.h \
    src/keepassPlugin/databaseInterface/KdbDatabase.h \
    src/keepassPlugin/databaseInterface/KdbListModel.h \
    src/keepassPlugin/databaseInterface/KdbEntry.h \
    src/keepassPlugin/databaseInterface/KdbGroup.h
