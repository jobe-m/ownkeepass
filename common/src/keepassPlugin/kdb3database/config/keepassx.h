/***************************************************************************
 *   Copyright (C) 2005-2008 by Tarek Saidi                                *
 *   tarek.saidi@arcor.de                                                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; version 2 of the License.               *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifndef KEEPASSX_H_
#define KEEPASSX_H_

// global defines

#define APP_DISPLAY_NAME    "KeePassX"
#define APP_CODE_NAME       "keepassx"
#define APP_SHORT_FUNC      "Password Manager"
#define APP_LONG_FUNC       "Cross Platform Password Manager"
#define APP_VERSION         "0.4.3"

#define BUILTIN_ICONS 69

#define KEEPASS_LITTLE_ENDIAN
//#define KEEPASS_BIG_ENDIAN

// often used, stable header files for pch


#ifdef __cplusplus

//#include <cstdlib>
//#include <cmath>

//#include <QApplication>
//#include <QBitArray>
//#include <QByteArray>
//#include <QCheckBox>
//#include <QColor>
//#include <QComboBox>
//#include <QDateTime>
//#include <QDialog>
//#include <QDir>
//#include <QDomElement>
//#include <QFile>
//#include <QHash>
//#include <QIcon>
//#include <QImage>
//#include <QLabel>
//#include <QLineEdit>
//#include <QList>
//#include <QMenu>
//#include <QMessageBox>
//#include <QPainter>
//#include <QPaintEvent>
#include <QPixmap>
//#include <QPushButton>
//#include <QSettings>
#include <QString>
//#include <QStringList>
//#include <QTextCodec>
//#include <QTimer>
//#include <QTreeWidget>
//#include <QUrl>

//#include "crypto/aescpp.h"
//#include "crypto/yarrow.h"
//#include "lib/bookmarks.h"
//#include "lib/FileDialogs.h"
//#include "lib/SecString.h"
//#include "lib/tools.h"
//#include "lib/UrlLabel.h"
//#include "Database.h"
#include "KpxConfig.h"

#include "plugins/interfaces/IIconTheme.h"

//extern QString PluginLoadError;
extern IIconTheme* IconLoader;
extern KpxConfig *config;
//extern QString AppDir;
extern QString HomeDir;
extern QString DataDir;
//extern bool TrActive;
//extern QString DetailViewTemplate;
extern QPixmap *EntryIcons;
//extern bool EventOccurred;
//extern bool EventOccurredBlock;

#endif //__cplusplus
#endif //KEEPASS_X_
