/***************************************************************************
 *   The yarrow pseudo-randomness genrator                                 *
 *   extracted from nettle, the low-level cryptographics library           *
 *                                                                         *
 *   Copyright (C) 2007 Tarek Saidi <tarek.saidi@arcor.de>                 * 
 *   Copyright (C) 2001 Niels Müler                                        *
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

 
#ifndef NETTLE_YARROW_COMPAT_H_INCLUDED
#define NETTLE_YARROW_COMPAT_H_INCLUDED

#include "aes.h"
#include "sha256.h"

/* Name mangling */
#define yarrow256_init nettle_yarrow256_init
#define yarrow256_seed nettle_yarrow256_seed
#define yarrow256_update nettle_yarrow256_update
#define yarrow256_random nettle_yarrow256_random
#define yarrow256_is_seeded nettle_yarrow256_is_seeded
#define yarrow256_needed_sources nettle_yarrow256_needed_sources
#define yarrow256_force_reseed nettle_yarrow256_force_reseed
#define yarrow_key_event_init nettle_yarrow_key_event_init
#define yarrow_key_event_estimate nettle_yarrow_key_event_estimate

enum yarrow_pool_id { YARROW_FAST = 0, YARROW_SLOW = 1 };

struct yarrow_source
{
  /* Indexed by yarrow_pool_id */
  quint32 estimate[2];
  
  /* The pool next sample should go to. */
  enum yarrow_pool_id next;
};


#define YARROW256_SEED_FILE_SIZE (2 * AES_BLOCK_SIZE)

/* Yarrow-256, based on SHA-256 and AES-256 */
struct yarrow256_ctx
{
  /* Indexed by yarrow_pool_id */
  sha256_context pools[2];

  quint8 seed_file[YARROW256_SEED_FILE_SIZE];
  
  int seeded;

  /* The current key and counter block */
  aes_encrypt_ctx key;
  quint8 counter[AES_BLOCK_SIZE];

  /* The entropy sources */
  unsigned nsources;
  struct yarrow_source *sources;
};

void
yarrow256_init(struct yarrow256_ctx *ctx,
	       unsigned nsources,
	       struct yarrow_source *sources);

void
yarrow256_seed(struct yarrow256_ctx *ctx,
	       unsigned length,
	       const quint8 *seed_file);

/* Returns 1 on reseed */
int
yarrow256_update(struct yarrow256_ctx *ctx,
		 unsigned source, unsigned entropy,
		 unsigned length, const quint8 *data);

void
yarrow256_random(struct yarrow256_ctx *ctx, unsigned length, quint8 *dst);

int
yarrow256_is_seeded(struct yarrow256_ctx *ctx);

unsigned
yarrow256_needed_sources(struct yarrow256_ctx *ctx);

void
yarrow256_force_reseed(struct yarrow256_ctx *ctx);


/* Key event estimator */
#define YARROW_KEY_EVENT_BUFFER 16

struct yarrow_key_event_ctx
{
  /* Counter for initial priming of the state */
  unsigned index;
  unsigned chars[YARROW_KEY_EVENT_BUFFER];
  unsigned previous;
};

void
yarrow_key_event_init(struct yarrow_key_event_ctx *ctx);

unsigned
yarrow_key_event_estimate(struct yarrow_key_event_ctx *ctx,
			  unsigned key, unsigned time);
			  
			  
/* merged code from macros.h: */

/* Reads a 32-bit integer, in network, big-endian, byte order */
#define READ_UINT32(p)				\
(  (((quint32) (p)[0]) << 24)			\
 | (((quint32) (p)[1]) << 16)			\
 | (((quint32) (p)[2]) << 8)			\
 |  ((quint32) (p)[3]))

#define WRITE_UINT32(p, i)			\
do {						\
  (p)[0] = ((i) >> 24) & 0xff;			\
  (p)[1] = ((i) >> 16) & 0xff;			\
  (p)[2] = ((i) >> 8) & 0xff;			\
  (p)[3] = (i) & 0xff;				\
} while(0)

/* Analogous macros, for 24 and 16 bit numbers */
#define READ_UINT24(p)				\
(  (((quint32) (p)[0]) << 16)			\
 | (((quint32) (p)[1]) << 8)			\
 |  ((quint32) (p)[2]))

#define WRITE_UINT24(p, i)			\
do {						\
  (p)[0] = ((i) >> 16) & 0xff;			\
  (p)[1] = ((i) >> 8) & 0xff;			\
  (p)[2] = (i) & 0xff;				\
} while(0)

#define READ_UINT16(p)				\
(  (((quint32) (p)[0]) << 8)			\
 |  ((quint32) (p)[1]))

#define WRITE_UINT16(p, i)			\
do {						\
  (p)[0] = ((i) >> 8) & 0xff;			\
  (p)[1] = (i) & 0xff;				\
} while(0)

/* And the other, little-endian, byteorder */
#define LE_READ_UINT32(p)			\
(  (((quint32) (p)[3]) << 24)			\
 | (((quint32) (p)[2]) << 16)			\
 | (((quint32) (p)[1]) << 8)			\
 |  ((quint32) (p)[0]))

#define LE_WRITE_UINT32(p, i)			\
do {						\
  (p)[3] = ((i) >> 24) & 0xff;			\
  (p)[2] = ((i) >> 16) & 0xff;			\
  (p)[1] = ((i) >> 8) & 0xff;			\
  (p)[0] = (i) & 0xff;				\
} while(0)

/* Macro to make it easier to loop over several blocks. */
#define FOR_BLOCKS(length, dst, src, blocksize)	\
  assert( !((length) % (blocksize)));           \
  for (; (length); ((length) -= (blocksize),	\
		  (dst) += (blocksize),		\
		  (src) += (blocksize)) )

void initYarrow();
void yarrowUpdateWeak(unsigned source, unsigned entropy, unsigned length, const quint8 *data);
void yarrowUpdateStrong(unsigned source, unsigned entropy, unsigned length, const quint8 *data);
void randomize(void* buffer, unsigned int length);
void reseedStrongPool(quint8* buffer1,int l1,quint8* buffer2,int l2);

  
#endif /* NETTLE_YARROW_COMPAT_H_INCLUDED */
