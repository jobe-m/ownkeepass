/*
  Copyright (C) 2003-2008 Dominik Reichl <dominik.reichl@t-online.de>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "arcfour.h"

void CArcFour::setKey(quint8* key, uint length){
	RawKey = key;
	RawKeyLength = length;
}

void CArcFour::encrypt(const quint8* src, quint8* dst, uint length){
	quint8 S[256];
	quint32 w;
	
	for(w = 0; w < 256; ++w)
		S[w] = static_cast<quint8>(w); // Fill linearly

	const quint8 btBufDep = static_cast<quint8>((length & 0xFF) << 1);

	quint8 i = 0, j = 0, t;
	quint32 k = 0;
	for(w = 0; w < 256; ++w) // Key setup
	{
		j += S[w] + RawKey[k] + btBufDep;

		t = S[i]; S[i] = S[j]; S[j] = t; // Swap entries

		++k;
		if(k == RawKeyLength) k = 0;
	}

	i = 0; j = 0;
	for(w = 0; w < length; ++w) // Encrypt PT
	{
		++i;
		j += S[i];

		t = S[i]; S[i] = S[j]; S[j] = t; // Swap entries

		t = S[i] + S[j]; // Generate random byte
		dst[w] = src[w] ^ S[t]; // XOR with PT
	}
}
