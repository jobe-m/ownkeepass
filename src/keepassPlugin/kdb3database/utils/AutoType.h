/***************************************************************************
 *   Copyright (C) 2005-2008 by Tarek Saidi, Felix Geyer                   *
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

#ifndef _AUTOTYPE_H_
#define _AUTOTYPE_H_

class KeepassMainWindow;
void initAutoType(KeepassMainWindow* mainWin);

class AutoType{
	public:
		virtual void perform(IEntryHandle* entry, bool hideWindow=true, int nr=0, bool wasLocked=false) = 0;
};

#ifdef GLOBAL_AUTOTYPE
struct Shortcut{
	bool ctrl, shift, alt, altgr, win;
	quint32 key;
};

class AutoTypeGlobal : public AutoType{
	public:
		virtual void performGlobal() = 0;
		inline const Shortcut& getShortcut() { return shortcut; };
		virtual bool registerGlobalShortcut(const Shortcut& s) = 0;
		virtual void unregisterGlobalShortcut() = 0;
		virtual QStringList getAllWindowTitles() = 0;
	
	protected:
		Shortcut shortcut;
};
#endif

#ifdef GLOBAL_AUTOTYPE
extern AutoTypeGlobal* autoType;
#else
extern AutoType* autoType;
#endif

#endif
