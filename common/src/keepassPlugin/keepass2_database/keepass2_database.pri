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

QT += gui concurrent core

# KeepassX 2 uses libgcrypt and libz
LIBS += -lgcrypt -lz

# enable preprocessor to find include paths
INCLUDEPATH += $$PWD/../keepass2_database/keepassx/src $$PWD/inc
DEPENDPATH  += $$PWD/../keepass2_database/keepassx/src

SOURCES += \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Database.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Uuid.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Entry.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Group.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Tools.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Metadata.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/AutoTypeAssociations.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntryAttachments.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntryAttributes.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/TimeInfo.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/DatabaseIcons.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/FilePath.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Endian.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/PasswordGenerator.cpp \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/CompositeKey.cpp \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/Random.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/CryptoHash.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipher.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipherGcrypt.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipherSalsa20.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/salsa20/salsa20.c \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/Crypto.cpp \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2Reader.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2XmlReader.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2RandomStream.cpp \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/StoreDataStream.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/SymmetricCipherStream.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/LayeredStream.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/HashedBlockStream.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/qtiocompressor.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/PasswordKey.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/FileKey.cpp \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntrySearcher.cpp \
    $$PWD/keepassx/src/format/KeePass2Writer.cpp \
    $$PWD/keepassx/src/format/KeePass2XmlWriter.cpp


HEADERS += \
    ../common/src/keepassPlugin/keepass2_database/inc/config-keepassx.h \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Database.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Uuid.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Group.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Entry.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Tools.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Metadata.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/AutoTypeAssociations.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntryAttachments.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntryAttributes.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Global.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/TimeInfo.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/DatabaseIcons.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/FilePath.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/Endian.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/PasswordGenerator.h \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/CompositeKey.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/CompositeKey_p.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/Key.h \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/Random.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/CryptoHash.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipher.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipherGcrypt.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/SymmetricCipherSalsa20.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/salsa20/ecrypt-config.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/salsa20/ecrypt-machine.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/salsa20/ecrypt-portable.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/salsa20/ecrypt-sync.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/crypto/Crypto.h \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2Reader.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2XmlReader.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/format/KeePass2RandomStream.h \
\
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/StoreDataStream.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/SymmetricCipherStream.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/LayeredStream.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/HashedBlockStream.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/qtiocompressor.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/streams/QtIOCompressor \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/PasswordKey.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/keys/FileKey.h \
    ../common/src/keepassPlugin/keepass2_database/keepassx/src/core/EntrySearcher.h \
    $$PWD/keepassx/src/format/KeePass2Writer.h \
    $$PWD/keepassx/src/format/KeePass2XmlWriter.h
