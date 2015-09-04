/***************************************************************************
 *   Copyright (C) 2005 by Tarek Saidi                                     *
 *   mail@tarek-saidi.de                                                   *
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

#include "random.h"
#include "crypto/yarrow.h"

#include <sys/types.h>
#include <unistd.h>

//#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	#include <QFile>
//#elif defined(Q_WS_WIN)
//	#include <windows.h>
//	#include <wincrypt.h>
//	#include <QSysInfo>
//#endif

#include <QCryptographicHash>
#include <QCursor>
#include <QDataStream>
#include <QTime>

void initStdRand();
bool getNativeEntropy(quint8* buffer, int length);

void getEntropy(quint8* buffer, int length){
	if (!getNativeEntropy(buffer, length)) {
		qWarning("Entropy collection failed, using fallback");
		initStdRand();
		for(int i=0;i<length;i++){
			((quint8*)buffer)[i] = (quint8) (qrand()%256);
		}
	}
}

quint32 randint(quint32 limit){
	quint32 rand;
	randomize(&rand, 4);
	return (rand % limit);
}

quint32 randintRange(quint32 min, quint32 max){
	return min + randint(max-min+1);
}

//#if defined(Q_WS_X11) || defined(Q_WS_MAC)

extern bool getNativeEntropy(quint8* buffer, int length) {
	QFile dev_urandom("/dev/urandom");
	if (!dev_urandom.open(QIODevice::ReadOnly|QIODevice::Unbuffered))
		return false;
	return (dev_urandom.read((char*)buffer,length) == length);
}

//#elif defined(Q_WS_WIN)

//extern bool getNativeEntropy(quint8* buffer, int length) {
//	HCRYPTPROV handle;
//	if (!CryptAcquireContext(&handle, 0, 0,  PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
//		return false;
	
//	CryptGenRandom(handle, length, buffer);
//	CryptReleaseContext(handle, 0);
	
//	return true;
//}

//#endif

extern void initStdRand(){
	static bool initalized = false;
	if (initalized)
		return;
	
	QByteArray buffer;
	QDataStream stream(&buffer, QIODevice::WriteOnly);
	
	stream << QCursor::pos();
	stream << QDateTime::currentDateTime().toTime_t();
	stream << QTime::currentTime().msec();
#ifdef Q_WS_WIN
	stream << (quint32) GetCurrentProcessId();
#else
	stream << getpid();
#endif
	/* On a modern OS code, stack and heap base are randomized */
	quint64 code_value = (quint64)initStdRand;
	stream << code_value;
	stream << (quint64)&code_value;
	
	QByteArray hash = QCryptographicHash::hash(buffer, QCryptographicHash::Sha1);
	
	qsrand( *((uint*) hash.data()) );
	initalized = true;
}
