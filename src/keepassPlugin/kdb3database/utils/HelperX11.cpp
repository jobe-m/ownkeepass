/***************************************************************************
 *   Copyright (C) 2005-2006 by Tarek Saidi, Felix Geyer                   *
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

#include "HelperX11.h"
#include <QX11Info>

#ifdef GLOBAL_AUTOTYPE
#include "AutoTypeGlobalX11.h"

uint HelperX11::getShortcutModifierMask(const Shortcut& s){
	AutoTypeGlobalX11* autoTypeGlobal = static_cast<AutoTypeGlobalX11*>(autoType);
	
	uint mod = 0;
	if (s.ctrl) mod |= ControlMask;
	if (s.shift) mod |= ShiftMask;
	if (s.alt) mod |= autoTypeGlobal->maskAlt();
	if (s.altgr) mod |= autoTypeGlobal->maskAltGr();
	if (s.win) mod |= autoTypeGlobal->maskMeta();
	
	return mod;
}
#endif

unsigned int HelperX11::keyboardModifiers(Display* d){
	Window root, child;
	int root_x, root_y, x, y;
	unsigned int mask;
	XQueryPointer(d, RootWindow(d, DefaultScreen(d)), &root, &child, &root_x, &root_y, &x, &y, &mask);
	return mask;
}

void HelperX11:: startCatchErrors(){
	Q_ASSERT(!catchErrors);
	catchErrors = true;
	pErrorOccurred = false;
	oldHandler = XSetErrorHandler(x11ErrorHandler);
}

void HelperX11::stopCatchErrors(){
	Q_ASSERT(catchErrors);
	XSync(QX11Info::display(), false);
	XSetErrorHandler(oldHandler);
	catchErrors = false;
}

int HelperX11::x11ErrorHandler(Display* display, XErrorEvent* error){
	Q_UNUSED(display)
	Q_UNUSED(error)
	if (catchErrors)
		pErrorOccurred = true;
	return 1;
}

int (*HelperX11::oldHandler) (Display*, XErrorEvent*) = NULL;
bool HelperX11::catchErrors = false;
bool HelperX11::pErrorOccurred = false;

KeySym HelperX11::getKeysym(const QChar& c){
	ushort unicode = c.unicode();
	
	/* first check for Latin-1 characters (1:1 mapping) */
	if ((unicode >= 0x0020 && unicode <= 0x007e) ||
			(unicode >= 0x00a0 && unicode <= 0x00ff))
		return unicode;
	else if (unicode >= 0x0100)
		return unicode|0x01000000;
	else
		return NoSymbol;
}
