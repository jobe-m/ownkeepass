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

#include "WaitAnimationWidget.h"

WaitAnimationWidget::WaitAnimationWidget(QWidget* parent):QWidget(parent){
	speed=60;
	setRefreshRate(25);
	CurAngle=0;
	for(int i=0;i<6;i++){
		float diff=CurAngle-i*0.16666667f;
		if(diff>0.5f)
			diff=1.0f-diff;
		if(diff<-0.5f)
			diff=1.0f+diff;
		CircSizes[i]=1.0+exp(-14.0f*diff*diff);
	}
	connect(&timer,SIGNAL(timeout()),this,SLOT(refreshAnimation()));
}

WaitAnimationWidget::~WaitAnimationWidget(){
	timer.stop();
}

void WaitAnimationWidget::start(){
	timer.start();
}

void WaitAnimationWidget::stop(){
	timer.stop();
	repaint();
}

void WaitAnimationWidget::setRefreshRate(int fps){
	DiffAngle=1.0f/((60.0f/(float)speed)*(float)fps);
	timer.setInterval((int) ((1.0f/(float)fps)*1000.0f));
}

void WaitAnimationWidget::refreshAnimation(){
	CurAngle+=DiffAngle;
	if(CurAngle>1.0f)CurAngle-=1.0f;
	for(int i=0;i<6;i++){
		float diff=CurAngle-i*0.16666667f;
		if(diff>0.5f)
			diff=1.0f-diff;
		if(diff<-0.5f)
			diff=1.0f+diff;
		CircSizes[i]=1.0+exp(-14.0f*diff*diff);
	}
	repaint();
}

void WaitAnimationWidget::paintEvent(QPaintEvent* event){
	Q_UNUSED(event);
	if(timer.isActive()){
		QPainter painter(this);
		painter.setRenderHints(QPainter::Antialiasing,true);
		painter.setBrush(Qt::black);
		painter.setPen(Qt::black);
		for(int i=0;i<6;i++){
			float d=CircSizes[i]*5.0;
			QRectF rect(CircPositions[i].x()-d/2,CircPositions[i].y()-d/2,d,d);
			painter.drawEllipse(rect);
		}
	}
}

void WaitAnimationWidget::resizeEvent(QResizeEvent* event){
	Q_UNUSED(event);
	float r;
	if(width()>height())
		r=height()/2;
	else
		r=width()/2;
	for(int i=0;i<6;i++){
		CircPositions[i].setX((r-10)*cos(-2.0*3.14159265*(0.16666667*i))+r);
		CircPositions[i].setY((r-10)*sin(-2.0*3.14159265*(0.16666667*i))+r);
	}
}
