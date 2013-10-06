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
#ifndef _SECSTRING_H_
#define _SECSTRING_H_

#include <QByteArray>
#include <QString>

#include "crypto/arcfour.h"

class SecData;

//! QString based class with in-memory encryption of its content.
/*!
This class can hold a QString object in an encrypted buffer. To get access to the string it is neccassary to unlock the SecString object.
 */
class SecString{

friend class SecData;

public:
	SecString();
	~SecString();
	/*! Sets the content of the object.
		The SecString is locked after this operation.
		\param Source The string which should be set as content of the SecString.
		\param DelSrc Set this parameter TRUE if you want that SecString overwrites an deletes the source string.*/
	void setString(QString& Source, bool DelSrc=false);
	/*! Locks the string.
		That means that the unencrypted string will be overwritten and deleted and only the encrypted buffer remains.
		It is forbidden to call the function string() when the SecString is locked.*/
	void lock();
	void unlock();
	const QString& string();
	operator QString();
	int length();
	
	static void overwrite(unsigned char* str,int len);
	static void overwrite(QString& str);
	static void generateSessionKey();
	static void deleteSessionKey();
	
private:
	static CArcFour RC4;
	static quint8* sessionkey;
	bool locked;
	QByteArray crypt;
	QString plain;

};

class SecData{
	public:
		SecData(int len);
		~SecData();
		void lock();
		void unlock();
		void copyData(quint8* src);
		void copyData(SecData& secData);
		quint8* operator*();
	
	private:
		quint8* data;
		int length;
		bool locked;
};


#endif
