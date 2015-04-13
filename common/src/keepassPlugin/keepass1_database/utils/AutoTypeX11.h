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

#ifndef _AUTOTYPEX11_H_
#define _AUTOTYPEX11_H_

#include "AutoType.h"

#include <X11/Xutil.h>

enum AutoTypeActionType{
	TypeKey, Delay
};

struct AutoTypeAction{
	AutoTypeAction(AutoTypeActionType t, KeySym d);
	AutoTypeActionType type;
	KeySym data;
};

class AutoTypeX11 : public AutoType {
	public:
		AutoTypeX11(KeepassMainWindow* mainWin);
		void perform(IEntryHandle* entry, bool hideWindow=true, int nr=0, bool wasLocked=false);
		virtual void updateKeymap();
	
	protected:
		void sleepTime(int msec);
		inline void sleepKeyStrokeDelay(){ sleepTime(config->autoTypeKeyStrokeDelay()); };
		void templateToKeysyms(const QString& Template, QList<AutoTypeAction>& KeySymList,IEntryHandle* entry);
		void stringToKeysyms(const QString& string,QList<AutoTypeAction>& KeySymList);
		
		int AddKeysym(KeySym keysym, bool top);
		void AddModifier(KeySym keysym);
		void ReadKeymap();
		void SendKeyPressedEvent(KeySym keysym, unsigned int shift);
		void SendEvent(XKeyEvent *event);
		static int MyErrorHandler(Display *my_dpy, XErrorEvent *event);
		Window getFocusWindow();
		
		KeepassMainWindow* mainWin;
		Display* dpy;
		
		KeySym *keysym_table;
		int min_keycode, max_keycode;
		int keysym_per_keycode;
		int alt_mask;
		int meta_mask;
		int altgr_mask;
		KeySym altgr_keysym;
		bool reReadKeymap;
		Window focusWindow;
	
	private:
		bool inAutoType;
};

#endif // _AUTOTYPEX11_H_
