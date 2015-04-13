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

#ifndef _LINKLABEL_H_
#define _LINKLABEL_H_

class LinkLabel : public QLabel{
	Q_OBJECT
	
	public:
		LinkLabel(QWidget *parent,const QString& text=QString::null, int x=0, int y=0,Qt::WFlags f=0);
		~LinkLabel();
		void setPos(int x,int y);
		QString url();

	public slots:
		virtual void setText(const QString&);

	signals:
		void clicked();

	protected:
		virtual void mouseReleaseEvent(QMouseEvent* event);

	private:
		QString URL;

};

#endif
