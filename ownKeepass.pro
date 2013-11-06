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

# the main sources of the application
include(src/Sailfish/main.pri)

# the sources of the keepass QML plugins
include(src/keepassPlugin/kdb3database/kdb3database.pri)
include(src/keepassPlugin/databaseInterface/databaseInterface.pri)

# the QML sources for the application
include(qml/Sailfish/UI.pri)

# Please do not modify the following line.
include(src/Sailfish/sailfishapplication/sailfishapplication.pri)

OTHER_FILES += \
    README.md \
    rpm/ownKeepass.yaml \
    rpm/ownKeepass.spec
