/***************************************************************************
 *   Copyright (C) 2005 by Tarek Saidi                                     *
 *   tarek@linux                                                           *
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


#include "UrlLabel.h"

LinkLabel::LinkLabel(QWidget *parent,const QString& text, int x, int y,Qt::WFlags f) : QLabel(parent,f){
	QFont font(parentWidget()->font());
	font.setUnderline(true);
	setFont(font);
	QPalette palette;
	palette.setColor(foregroundRole(),QColor(20,20,255));
	setPalette(palette);
	setCursor(Qt::PointingHandCursor);
	setText(text);
	setPos(x,y);
}

LinkLabel::~LinkLabel(){
}

QString LinkLabel::url(){
	if(URL!=QString())
		return URL;
	else if(text().contains("@"))
		return QString("mailto:")+text();
	else
		return text();
}

void LinkLabel::mouseReleaseEvent(QMouseEvent* event){
	if(event->button()==Qt::LeftButton){
		emit clicked();
		openBrowser(url());
	}
}

void LinkLabel::setPos(int x,int y){
	QFontMetrics fm(font());
	setGeometry(x,y,fm.width(text()),fm.height());
}

void LinkLabel::setText(const QString& text){
	QLabel::setText(text);
	setPos(geometry().x(), geometry().y());
}
