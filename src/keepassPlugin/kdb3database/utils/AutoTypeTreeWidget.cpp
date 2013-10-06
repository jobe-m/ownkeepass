/***************************************************************************
 *   Copyright (C) 2005-2008 by Tarek Saidi                                *
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

#include "lib/AutoTypeTreeWidget.h"

void AutoTypeTreeWidget::mouseMoveEvent(QMouseEvent* event){
	QTreeWidgetItem* item = itemAt(event->pos());
	if(item){
		setCurrentItem(item);
		setCursor(Qt::PointingHandCursor);
	}
	else {
		unsetCursor();
	}
}

void AutoTypeTreeWidget::keyPressEvent(QKeyEvent* event){
	if(event->key()==Qt::Key_Return || event->key()==Qt::Key_Enter){
		emit returnPressed(currentItem());
		event->accept();
	}
	else {
		QTreeWidget::keyPressEvent(event);
	}
}
