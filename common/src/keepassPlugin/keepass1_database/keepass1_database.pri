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

QT += xml gui

INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

SOURCES += \
    ../common/src/keepassPlugin/keepass1_database/config/KpxConfig.cpp \
    ../common/src/keepassPlugin/keepass1_database/database/Database.cpp \
    ../common/src/keepassPlugin/keepass1_database/database/Kdb3Database.cpp \
    ../common/src/keepassPlugin/keepass1_database/utils/SecString.cpp \
    ../common/src/keepassPlugin/keepass1_database/utils/tools.cpp \
    ../common/src/keepassPlugin/keepass1_database/utils/random.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/aescrypt.c \
    ../common/src/keepassPlugin/keepass1_database/crypto/aeskey.c \
    ../common/src/keepassPlugin/keepass1_database/crypto/aes_modes.c \
    ../common/src/keepassPlugin/keepass1_database/crypto/aestab.c \
    ../common/src/keepassPlugin/keepass1_database/crypto/arcfour.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/blowfish.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/sha256.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/twoclass.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/twofish.cpp \
    ../common/src/keepassPlugin/keepass1_database/crypto/yarrow.cpp

HEADERS += \
    ../common/src/keepassPlugin/keepass1_database/config/KpxConfig.h \
    ../common/src/keepassPlugin/keepass1_database/config/keepassx.h \
    ../common/src/keepassPlugin/keepass1_database/database/Database.h \
    ../common/src/keepassPlugin/keepass1_database/database/Kdb3Database.h \
    ../common/src/keepassPlugin/keepass1_database/utils/SecString.h \
    ../common/src/keepassPlugin/keepass1_database/utils/tools.h \
    ../common/src/keepassPlugin/keepass1_database/utils/random.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aes.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aescpp.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aes_endian.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aes_types.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aesopt.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/aestab.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/arcfour.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/blowfish.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/sha256.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/twoclass.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/twofish.h \
    ../common/src/keepassPlugin/keepass1_database/crypto/yarrow.h \
    ../common/src/keepassPlugin/keepass1_database/plugins/interfaces/IIconTheme.h
