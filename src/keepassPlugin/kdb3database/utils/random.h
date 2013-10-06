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
#ifndef RANDOM_H_
#define RANDOM_H_

#ifndef quint8
typedef unsigned char quint8;
#endif

#ifndef quint32
typedef unsigned int quint32;
#endif

#ifdef __cplusplus
extern "C" {
#endif

void getEntropy(quint8* buffer, int length);
quint32 randint(quint32 limit); // generate random number: 0 <= n < limit

#ifdef __cplusplus
}
#endif

quint32 randintRange(quint32 min, quint32 max); // generate random number: min <= n <= max

#endif
