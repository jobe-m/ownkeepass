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

#include "crypto/arcfour.h"
#include "crypto/yarrow.h"
#include "utils/SecString.h"
#include "utils/tools1.h"

CArcFour SecString::RC4;
quint8* SecString::sessionkey;

SecString::operator QString(){
	return string();
}

SecString::SecString(){
	locked=true;
}

int SecString::length(){
	return crypt.size();
}

SecString::~SecString(){
	lock();
}

void SecString::lock(){
	locked=true;
	overwrite(plain);
	plain=QString();
}

void SecString::unlock(){
	locked = false;
	plain = QString();
	if(!crypt.length())
		return;
	const unsigned char* buffer = new unsigned char[crypt.length()];
	RC4.decrypt( (quint8*)crypt.data(), (unsigned char*)buffer, crypt.length() );
	plain = QString::fromUtf8((const char*)buffer, crypt.size());
	overwrite((unsigned char*)buffer, crypt.size());
	delete [] buffer;
}

const QString& SecString::string(){
	Q_ASSERT_X(!locked, "SecString::string()", "string is locked");
	return plain;
}

void SecString::setString(QString& str, bool DeleteSource){
	QByteArray StrData = str.toUtf8();
	int len = StrData.size();
	unsigned char* buffer = new unsigned char[len];
	RC4.encrypt((const unsigned char*)StrData.data(), buffer, len);
	crypt = QByteArray((const char*)buffer, len);
	overwrite(buffer, len);
	overwrite((unsigned char*)StrData.data(), len);
	delete [] buffer;
	if(DeleteSource){
		overwrite(str);
		str=QString();
	}
	lock();
}

void SecString::overwrite(unsigned char* str, int strlen){
	if(strlen==0 || str==NULL)
		return;
	
	for(int i=0; i<strlen; i++)
		str[i]=0;
}

void SecString::overwrite(QString& str){
	for (int i=0; i<str.length(); i++) {
		str[i] = '\0';
	}
}

void SecString::generateSessionKey(){
	sessionkey = new quint8[32];
	if (!lockPage(sessionkey, 32))
        qDebug("ERROR: Failed to lock session key page");
	randomize(sessionkey, 32);
	RC4.setKey(sessionkey, 32);
}

void SecString::deleteSessionKey() {
	overwrite(sessionkey, 32);
	unlockPage(sessionkey, 32);
	delete[] sessionkey;
}


SecData::SecData(int len) : locked(true){
	length = len;
	data = new quint8[len];
}

SecData::~SecData(){
	if (!locked){
		for (int i=0; i<length; i++)
			data[i] = 0;
	}
	delete[] data;
}

void SecData::lock(){
	Q_ASSERT(!locked);
	SecString::RC4.encrypt(data, data, length);
	locked = true;
}

void SecData::unlock(){
	Q_ASSERT(locked);
	SecString::RC4.decrypt(data, data, length);
	locked = false;
}

void SecData::copyData(quint8* src){
	locked = false;
	memcpy(data, src, length);
	lock();
}

void SecData::copyData(SecData& secData){
	secData.unlock();
	copyData(*secData);
	secData.lock();
}

quint8* SecData::operator*(){
	Q_ASSERT(!locked);
	return data;
}
