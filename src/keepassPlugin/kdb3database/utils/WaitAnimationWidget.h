/***************************************************************************
 *   Copyright (C) 2005-2006 by Tarek Saidi                                *
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


class WaitAnimationWidget:public QWidget{
	Q_OBJECT
	public:
		WaitAnimationWidget(QWidget* parent);
		~WaitAnimationWidget();
		void setSpeed(int rpm){speed=rpm;}
		void setRefreshRate(int fps);
		void start();
		void stop();
	private slots:
		void refreshAnimation();
	private:
		virtual void paintEvent(QPaintEvent* event);
		virtual void resizeEvent(QResizeEvent* event);
		QTimer timer;
		int speed;
		float CurAngle;
		float DiffAngle;
		float CircSizes[6];
		QPointF CircPositions[6];
};
