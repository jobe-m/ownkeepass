/***************************************************************************
 *   Copyright (C) 2005-2007 by Tarek Saidi                                *
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

#include <QCoreApplication>
#include <QLocale>
#include "crypto/yarrow.h"
#include "Database_keepassx1.h"

KpxUuid::KpxUuid() : Data(16,0){
}

KpxUuid::KpxUuid(const void* src){
	fromRaw(src);
}

void KpxUuid::generate(){
	char uuid[16];
	randomize(uuid,16);
	quint32 Secs=QDateTime::currentDateTime().toTime_t();
	quint16 mSecs=QTime::currentTime().msec();
	mSecs=(mSecs & 0x3FF) | (*((quint16*)(uuid+4)) & 0xFC00); //msec has only 10 Bits, filling the rest with random data
	memcpy((void*)uuid,&Secs,4);
	memcpy((void*)(uuid+4),&mSecs,2);
	Data=QByteArray(uuid,16);
}

QString KpxUuid::toString()const{
	QString hex;
	Q_ASSERT(Data.length()==16);
	for(int i=0;i<16;i++){
		QString HexByte;
		HexByte.setNum((unsigned char)*(Data.data()+i),16);
		if(HexByte.length()<2)HexByte="0"+HexByte;
		hex+=HexByte;
	}
	return QString("{%1-%2-%3-%4-%5}")
			.arg(hex.mid(0,8))
			.arg(hex.mid(8,4))
			.arg(hex.mid(12,4))
			.arg(hex.mid(16,4))
			.arg(hex.mid(20,12));
}

void KpxUuid::toRaw(void* dst)const{
	memcpy(dst,Data.data(),16);
}

void KpxUuid::fromRaw(const void* src){
	Data=QByteArray((char*)src,16);
}

bool KpxUuid::operator==(const KpxUuid& other)const{
	return other.Data==Data;
}

bool KpxUuid::operator!=(const KpxUuid& other)const{
	return other.Data!=Data;
}



QString KpxDateTime::toString(Qt::DateFormat format) const{
	if (*this==Date_Never)
		return QCoreApplication::translate("Database","Never");
	else if (format==Qt::SystemLocaleDate){
		QString strFormat = QLocale::system().dateFormat(QLocale::ShortFormat);
		if (!strFormat.contains("dd")) strFormat.replace("d", "dd");
		if (!strFormat.contains("MM")) strFormat.replace("M", "MM");
		if (!strFormat.contains("yyyy")) strFormat.replace("yy", "yyyy");
		if (!strFormat.contains("hh")) strFormat.replace("h", "hh");
		if (!strFormat.contains("HH")) strFormat.replace("H", "HH");
		if (!strFormat.contains("mm")) strFormat.replace("m", "mm");
		if (!strFormat.contains("ss")) strFormat.replace("s", "ss");
		return date().toString(strFormat);
	}
	else
		return QDateTime::toString(format);
}

QString KpxDateTime::dateToString(Qt::DateFormat format) const{
	if (*this==Date_Never)
		return QCoreApplication::translate("Database","Never");
	else if (format==Qt::SystemLocaleDate){
		QString strFormat = QLocale::system().dateFormat(QLocale::ShortFormat);
		if (!strFormat.contains("dd")) strFormat.replace("d", "dd");
		if (!strFormat.contains("MM")) strFormat.replace("M", "MM");
		if (!strFormat.contains("yyyy")) strFormat.replace("yy", "yyyy");
		return date().toString(strFormat);
	}
	else
		return date().toString(format);
}


KpxDateTime KpxDateTime::fromString(const QString& string,Qt::DateFormat format){
	if(string.toLower()=="never")
		return Date_Never;
	else return QDateTime::fromString(string,format);	
}

CEntry::CEntry(){
	Image=0;
	GroupId=0;
	Creation=QDateTime::currentDateTime();
	LastMod=QDateTime::currentDateTime();
	LastAccess=QDateTime::currentDateTime();
	Expire=QDateTime(QDate(2999,12,28),QTime(23,59,59)); //Never
	Binary=QByteArray();
}

bool KpxDateTime::operator<(const QDateTime& other){
	if(*this!=Date_Never && other!=Date_Never)return ((QDateTime)(*this)<other);
	if(*this==Date_Never && other==Date_Never)return false;
	if(*this==Date_Never)return false;
	if(other==Date_Never)return true;
	
	return false;
}


CGroup::CGroup(){
	Image=0;
	IsExpanded=false;
}


