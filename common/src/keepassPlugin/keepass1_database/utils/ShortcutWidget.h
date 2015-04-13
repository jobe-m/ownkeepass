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

#ifndef SHORTCUT_WIDGET_H
#define SHORTCUT_WIDGET_H


#if defined(GLOBAL_AUTOTYPE) && defined(Q_WS_X11)
#include "lib/AutoType.h"
#endif

class ShortcutWidget : public QLineEdit{
	Q_OBJECT
	
	public:
		ShortcutWidget(QWidget* parent = 0);
#if defined(GLOBAL_AUTOTYPE) && defined(Q_WS_X11)
		Shortcut shortcut();
		void setShortcut(const Shortcut& s);
	
	protected:
		void keyPressEvent(QKeyEvent* event);
		void keyReleaseEvent(QKeyEvent* event);
	
	private:
		void keyEvent(QKeyEvent* event, bool release);
		void displayShortcut(quint32 key, bool release, bool ctrl, bool shift, bool alt, bool altgr, bool win);
		void setBackgroundColor(const QColor& c);
		bool lock;
		bool failed;
		Shortcut pShortcut;
#endif
};

#endif // SHORTCUT_WIDGET_H
