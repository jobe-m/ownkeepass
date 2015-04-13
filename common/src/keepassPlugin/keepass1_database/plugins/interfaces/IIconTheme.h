/***************************************************************************
 *   Copyright (C) 2007 by Tarek Saidi                                     *
 *   tarek.saidi@arcor.de                                                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; Version 2 of the license only.	   *
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
#include <QString>
#include <QStringList>
#include <QIcon> // <Qt/qicon.h> (Qt4)

#ifndef _I_ICON_THEME_H_
#define _I_ICON_THEME_H_

class IIconTheme{
	public:
		virtual ~IIconTheme(){}
        virtual QIcon getIcon(const QString& name)=0;
};
Q_DECLARE_INTERFACE(IIconTheme,"org.KeePassX.IconThemeInterface/0.2.3")
		
#endif
