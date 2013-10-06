 /**************************************************************************
 *   Implementation of the Blowfish chiper                                 *
 *   Derived from Libgcrypt                                                * 
 *                                                                         *
 *   Copyright (C) 1998, 2001, 2002 Free Software Foundation, Inc.         *
 *   Copyright (C) 2003, 2004 by Michael Buesch <mbuesch@freenet.de>       *
 *   Copyright (C) 2007 by Tarek Saidi <tarek.saidi@arcor.de>              *
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

#ifndef BLOWFISH_H
#define BLOWFISH_H

#include <qglobal.h>
//#include <stdint.h>
#include <string>
using std::string;

#define BLOWFISH_BLOCKSIZE	8
#define BLOWFISH_ROUNDS		16
#define CIPHER_ALGO_BLOWFISH	4	/* blowfish 128 bit key */

#define uint8_t quint8
#define uint16_t quint16
#define uint32_t quint32
#ifndef byte
#define byte quint8
#endif

/** blowfish encryption algorithm.
  * Derived from libgcrypt-1.1.12
  */

class Blowfish
{
	struct BLOWFISH_context
	{
		uint32_t s0[256];
		uint32_t s1[256];
		uint32_t s2[256];
		uint32_t s3[256];
		uint32_t p[BLOWFISH_ROUNDS+2];
	};

public:
	Blowfish();

	/** set key to encrypt. if return == 1, it is a weak key. */
	int bf_setkey( byte *key, unsigned int keylen );
	/** encrypt inbuf and return it in outbuf.
	  * inbuf and outbuf have to be: buf % 8 == 0
	  * You may check this with getPaddedLen() and pad with NULL.
	  */
	int bf_encrypt( byte *outbuf, byte *inbuf, unsigned int inbuf_len );
	/** decrypt inbuf and return it in outbuf.
	  * inbuf and outbuf have to be: buf % 8 == 0
	  * You may check this with getPaddedLen() and pad with NULL.
	  */
	int bf_decrypt( byte *outbuf, byte *inbuf, unsigned int inbuf_len );
	/** returns the length, the sting has to be padded to */
	static unsigned int getPaddedLen(unsigned int inLen)
			{ return ((8 - (inLen % 8)) + inLen); }
	/** pad up to 8 bytes. */
	static void padNull(string *buf);
	/** remove padded data */
	static bool unpadNull(string *buf);

protected:
#if BLOWFISH_ROUNDS != 16
	uint32_t function_F( uint32_t x)
	{
		uint16_t a, b, c, d;
	#ifdef KEEPASS_BIG_ENDIAN
		a = ((byte *) & x)[0];
		b = ((byte *) & x)[1];
		c = ((byte *) & x)[2];
		d = ((byte *) & x)[3];
	#else
		a = ((byte *) & x)[3];
		b = ((byte *) & x)[2];
		c = ((byte *) & x)[1];
		d = ((byte *) & x)[0];
	#endif
		return ((bc.s0[a] + bc.s1[b]) ^ bc.s2[c]) + bc.s3[d];
	}
#endif
	void R(uint32_t &l, uint32_t &r, uint32_t i, uint32_t *p,
	       uint32_t *s0, uint32_t *s1, uint32_t *s2, uint32_t *s3)
	{
		l ^= p[i];
	#ifdef KEEPASS_BIG_ENDIAN
		r ^= (( s0[((byte*)&l)[0]] + s1[((byte*)&l)[1]])
			^ s2[((byte*)&l)[2]]) + s3[((byte*)&l)[3]];
	#else
		r ^= (( s0[((byte*)&l)[3]] + s1[((byte*)&l)[2]])
			^ s2[((byte*)&l)[1]]) + s3[((byte*)&l)[0]];
	#endif
	}
	void encrypt_block(byte *outbuf, byte *inbuf);
	void decrypt_block(byte *outbuf, byte *inbuf);
	void burn_stack(int bytes);
	void do_encrypt(uint32_t *ret_xl, uint32_t *ret_xr);
	void do_decrypt(uint32_t *ret_xl, uint32_t *ret_xr);
	void do_encrypt_block(byte *outbuf, byte *inbuf);
	void do_decrypt_block(byte *outbuf, byte *inbuf);
	int do_bf_setkey(byte *key, unsigned int keylen);

protected:
	struct BLOWFISH_context bc;
};

#endif
