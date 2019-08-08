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

# KeepassXC uses libargon2, libgcrypt, lsodium and libz
LIBS += -largon2 -lgcrypt -lsodium -lz

SRC_DIR += $$PWD/keepassxc/src

# enable preprocessor to find include paths
INCLUDEPATH += $$SRC_DIR $$SRC_DIR/zxcvbn $$PWD/inc
DEPENDPATH  += $$SRC_DIR

SOURCES += \
    $$SRC_DIR/core/Base32.cpp \
    $$SRC_DIR/core/Config.cpp \
    $$SRC_DIR/core/Compare.cpp \
    $$SRC_DIR/core/Clock.cpp \
    $$SRC_DIR/core/Tools.cpp \
    $$SRC_DIR/core/CustomData.cpp \
    $$SRC_DIR/core/Database.cpp \
    $$SRC_DIR/core/Entry.cpp \
    $$SRC_DIR/core/Group.cpp \
    $$SRC_DIR/core/Metadata.cpp \
    $$SRC_DIR/core/AutoTypeAssociations.cpp \
    $$SRC_DIR/core/EntryAttachments.cpp \
    $$SRC_DIR/core/EntryAttributes.cpp \
    $$SRC_DIR/core/TimeInfo.cpp \
    $$SRC_DIR/core/DatabaseIcons.cpp \
    $$SRC_DIR/core/FilePath.cpp \
    $$SRC_DIR/zxcvbn/zxcvbn.c \
    $$SRC_DIR/core/PasswordGenerator.cpp \
\
    $$SRC_DIR/keys/CompositeKey.cpp \
\
    $$SRC_DIR/crypto/kdf/Kdf.cpp \
    $$SRC_DIR/crypto/kdf/AesKdf.cpp \
    $$SRC_DIR/crypto/kdf/Argon2Kdf.cpp \
    $$SRC_DIR/crypto/Random.cpp \
    $$SRC_DIR/crypto/Crypto.cpp \
    $$SRC_DIR/crypto/CryptoHash.cpp \
    $$SRC_DIR/crypto/SymmetricCipher.cpp \
    $$SRC_DIR/crypto/SymmetricCipherGcrypt.cpp \
\
    $$SRC_DIR/format/KeePass2.cpp \
    $$SRC_DIR/format/KeePass2Reader.cpp \
    $$SRC_DIR/format/KeePass2RandomStream.cpp \
    $$SRC_DIR/format/KdbxReader.cpp \
    $$SRC_DIR/format/Kdbx3Reader.cpp \
    $$SRC_DIR/format/Kdbx4Reader.cpp \
    $$SRC_DIR/format/KdbxXmlReader.cpp \
\
    $$SRC_DIR/totp/totp.cpp \
    $$SRC_DIR/streams/StoreDataStream.cpp \
    $$SRC_DIR/streams/SymmetricCipherStream.cpp \
    $$SRC_DIR/streams/LayeredStream.cpp \
    $$SRC_DIR/streams/HashedBlockStream.cpp \
    $$SRC_DIR/streams/HmacBlockStream.cpp \
    $$SRC_DIR/streams/qtiocompressor.cpp \
    $$SRC_DIR/keys/PasswordKey.cpp \
    $$SRC_DIR/keys/FileKey.cpp \
    $$SRC_DIR/core/EntrySearcher.cpp \
\
    $$SRC_DIR/format/KeePass2Writer.cpp \
    $$SRC_DIR/format/KdbxWriter.cpp \
    $$SRC_DIR/format/Kdbx3Writer.cpp \
    $$SRC_DIR/format/Kdbx4Writer.cpp \
    $$SRC_DIR/format/KdbxXmlWriter.cpp \


HEADERS += \
    ../common/src/keepassPlugin/keepass2_database/inc/config-keepassx.h \
    ../common/src/keepassPlugin/keepass2_database/inc/git-info.h \
\
    $$SRC_DIR/core/Base32.h \
    $$SRC_DIR/core/Config.h \
    $$SRC_DIR/core/Compare.h \
    $$SRC_DIR/core/Clock.h \
    $$SRC_DIR/core/Tools.h \
    $$SRC_DIR/core/CustomData.h \
    $$SRC_DIR/core/Database.h \
    $$SRC_DIR/core/Group.h \
    $$SRC_DIR/core/Entry.h \
    $$SRC_DIR/core/Metadata.h \
    $$SRC_DIR/core/AutoTypeAssociations.h \
    $$SRC_DIR/core/EntryAttachments.h \
    $$SRC_DIR/core/EntryAttributes.h \
    $$SRC_DIR/core/Global.h \
    $$SRC_DIR/core/TimeInfo.h \
    $$SRC_DIR/core/DatabaseIcons.h \
    $$SRC_DIR/core/FilePath.h \
    $$SRC_DIR/zxcvbn/zxcvbn.h \
    $$SRC_DIR/core/PasswordGenerator.h \
\
    $$SRC_DIR/keys/CompositeKey.h \
    $$SRC_DIR/keys/Key.h \
\
    $$SRC_DIR/crypto/kdf/Kdf.h \
    $$SRC_DIR/crypto/kdf/Kdf_p.h \
    $$SRC_DIR/crypto/kdf/AesKdf.h \
    $$SRC_DIR/crypto/kdf/Argon2Kdf.h \
    $$SRC_DIR/crypto/argon2/argon2.h \
    $$SRC_DIR/crypto/Random.h \
    $$SRC_DIR/crypto/Crypto.h \
    $$SRC_DIR/crypto/CryptoHash.h \
    $$SRC_DIR/crypto/SymmetricCipher.h \
    $$SRC_DIR/crypto/SymmetricCipherGcrypt.h \
\
    $$SRC_DIR/format/KeePass2.h \
    $$SRC_DIR/format/KeePass2Reader.h \
    $$SRC_DIR/format/KeePass2RandomStream.h \
    $$SRC_DIR/format/KdbxReader.h \
    $$SRC_DIR/format/Kdbx3Reader.h \
    $$SRC_DIR/format/Kdbx4Reader.h \
    $$SRC_DIR/format/KdbxXmlReader.h \
\
    $$SRC_DIR/totp/totp.cpp \
    $$SRC_DIR/streams/StoreDataStream.h \
    $$SRC_DIR/streams/SymmetricCipherStream.h \
    $$SRC_DIR/streams/LayeredStream.h \
    $$SRC_DIR/streams/HashedBlockStream.h \
    $$SRC_DIR/streams/HmacBlockStream.h \
    $$SRC_DIR/streams/qtiocompressor.h \
    $$SRC_DIR/streams/QtIOCompressor \
    $$SRC_DIR/keys/PasswordKey.h \
    $$SRC_DIR/keys/FileKey.h \
    $$SRC_DIR/core/EntrySearcher.h \
\
    $$SRC_DIR/format/KeePass2Writer.h \
    $$SRC_DIR/format/KdbxWriter.h \
    $$SRC_DIR/format/Kdbx3Writer.h \
    $$SRC_DIR/format/Kdbx4Writer.h \
    $$SRC_DIR/format/KdbxXmlWriter.h \
