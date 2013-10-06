/***************************************************************************
 *   Copyright (C) 2005-2008 by Felix Geyer                                *
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

#ifndef HELPERX11_H
#define HELPERX11_H

#define XK_MISCELLANY
#define XK_XKB_KEYS
#define XK_3270
#define XK_CURRENCY

#include "AutoType.h"
#include <QChar>
#include <X11/extensions/XTest.h>
#include <X11/keysymdef.h>

class HelperX11{
	public:
		static KeySym getKeysym(const QChar& c);
#ifdef GLOBAL_AUTOTYPE
		static uint getShortcutModifierMask(const Shortcut& s);
#endif
		static unsigned int keyboardModifiers(Display* d);
		
		static void startCatchErrors();
		static void stopCatchErrors();
		inline static bool errorOccurred() { return pErrorOccurred; };
	
	private:
		static int x11ErrorHandler(Display* display, XErrorEvent* error);
		static int (*oldHandler) (Display*, XErrorEvent*);
		static bool catchErrors;
		static bool pErrorOccurred;
};

#endif // HELPERX11_H
