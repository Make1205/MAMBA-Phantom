/*
The software is provided by the Institute of Commercial Cryptography Standards
(ICCS), and is used for algorithm submissions in the Next-generation Commercial
Cryptographic Algorithms Program (NGCC).

ICCS doesn't represent or warrant that the operation of the software will be
uninterrupted or error-free in all cases. ICCS will take no responsibility for
the use of the software or the results thereof, if the software is used for any
other purposes.
*/

#include "SIG_AlgorithmInstance.h"
#include "drng.h"

#include <stddef.h>
#include <stdint.h>

#include "params.h"
#include "sign.h"

extern DRNG_ctx drng_algorithm;

unsigned long long sig_get_pk_len_bytes()
{
	return CRYPTO_PUBLICKEYBYTES;
}

unsigned long long sig_get_sk_len_bytes()
{
	return CRYPTO_SECRETKEYBYTES;
}

unsigned long long sig_get_sn_len_bytes()
{
	return CRYPTO_BYTES;
}

int sig_keygen(
	unsigned char *pk, unsigned long long *pk_len_bytes,
	unsigned char *sk, unsigned long long *sk_len_bytes)
{
	int ret = crypto_sign_keypair((uint8_t *)pk, (uint8_t *)sk);
	if (ret != 0)
		return -2;

	*pk_len_bytes = CRYPTO_PUBLICKEYBYTES;
	*sk_len_bytes = CRYPTO_SECRETKEYBYTES;
	return 0;
}

int sig_sign(
	unsigned char *sk, unsigned long long sk_len_bytes,
	unsigned char *m, unsigned long long m_len_bytes,
	unsigned char *sn, unsigned long long *sn_len_bytes)
{
	size_t siglen = 0;
	if (sk_len_bytes != CRYPTO_SECRETKEYBYTES)
		return -2;

	if (crypto_sign_signature((uint8_t *)sn, &siglen,
			(const uint8_t *)m, (size_t)m_len_bytes,
			NULL, 0, (const uint8_t *)sk) != 0)
		return -3;

	*sn_len_bytes = (unsigned long long)siglen;
	return 0;
}

int sig_verify(
	unsigned char *pk, unsigned long long pk_len_bytes,
	unsigned char *sn, unsigned long long sn_len_bytes,
	unsigned char *m, unsigned long long m_len_bytes)
{
	if (pk_len_bytes != CRYPTO_PUBLICKEYBYTES)
		return -2;

	if (crypto_sign_verify((const uint8_t *)sn, (size_t)sn_len_bytes,
			(const uint8_t *)m, (size_t)m_len_bytes,
			NULL, 0, (const uint8_t *)pk) != 0)
		return -1;

	return 0;
}
