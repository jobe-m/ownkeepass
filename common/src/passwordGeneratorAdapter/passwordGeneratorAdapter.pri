#***************************************************************************
#**
#** Copyright (C) 2013 - 2016 Marko Koschak (marko.koschak@tisno.de)
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

#QT += qml quick
# password generator uses libgcrypt
#LIBS += -lgcrypt
#INCLUDEPATH += ../../../src

# for optimizing string construction
DEFINES *= QT_USE_QSTRINGBUILDER

INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

SOURCES += \
#    ../../../src/core/PasswordGenerator.cpp \
    ../common/src/passwordGeneratorAdapter/PasswordGeneratorAdapter.cpp
#    ../../../src/crypto/Random.cpp \
#    ../../../src/crypto/Crypto.cpp

HEADERS += \
#    ../../../src/core/PasswordGenerator.h \
    ../common/src/passwordGeneratorAdapter/PasswordGeneratorAdapter.h
#    ../../../src/core/Global.h \
#    ../../../src/crypto/Random.h \
#    ../../../src/crypto/Crypto.h
