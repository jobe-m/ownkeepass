#***************************************************************************
#**
#** Copyright (C) 2015 Marko Koschak (marko.koschak@tisno.de)
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

#QT += xml gui

# enable preprocessor to find include paths
INCLUDEPATH += $$PWD/../keepassx/src
DEPENDPATH  += $$PWD/../keepassx/src

SOURCES += \
    ../common/src/keepassPlugin/keepassx/src/core/Database.cpp \
    ../common/src/keepassPlugin/keepassx/src/core/Uuid.cpp

HEADERS += \
    ../common/src/keepassPlugin/keepassx/src/core/Database.h \
    ../common/src/keepassPlugin/keepassx/src/core/Uuid.h \
    ../common/src/keepassPlugin/keepassx/src/core/Group.h \
    ../common/src/keepassPlugin/keepassx/src/core/Metadata.h \
    ../common/src/keepassPlugin/keepassx/src/core/Tools.h \
    ../common/src/keepassPlugin/keepassx/src/keys/CompositeKey.h \
    ../common/src/keepassPlugin/keepassx/src/keys/Key.h \
    ../common/src/keepassPlugin/keepassx/src/crypto/Random.h \
    ../common/src/keepassPlugin/keepassx/src/format/KeePass2.h \

#    ../common/src/keepassPlugin/keepassx/src/core/ \
