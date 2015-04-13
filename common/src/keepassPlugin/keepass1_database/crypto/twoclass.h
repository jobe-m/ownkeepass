/***************************************************************************
 *   Copyright (C) 2005-2007 Tarek Saidi <tarek.saidi@arcor.de>            * 
 *   Copyright (c) 2003,2004 Dominik Reichl <dominik.reichl@t-online.de>   *
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


#ifndef ___TWOFISH_CLASS_H___
#define ___TWOFISH_CLASS_H___

#include "twofish.h"

class CTwofish
{
public:
	CTwofish();
	virtual ~CTwofish();

	bool init(quint8 *pKey, unsigned long uKeyLen, quint8 *initVector = NULL);

	int padEncrypt(quint8 *pInput, int nInputOctets, quint8 *pOutBuffer);
	int padDecrypt(quint8 *pInput, int nInputOctets, quint8 *pOutBuffer);

private:
	Twofish_key m_key;
	quint8 m_pInitVector[16];
};

#endif
