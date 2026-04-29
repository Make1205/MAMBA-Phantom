/*
The software is provided by the Institute of Commercial Cryptography Standards
(ICCS), and is used for algorithm submissions in the Next-generation Commercial
Cryptographic Algorithms Program (NGCC).

ICCS doesn't represent or warrant that the operation of the software will be
uninterrupted or error-free in all cases. ICCS will take no responsibility for
the use of the software or the results thereof, if the software is used for any
other purposes.
*/

#ifndef SIG_ALGORITHM_INSTANCE_H
#define SIG_ALGORITHM_INSTANCE_H

// Set "OUTPUT_BLANK_TEST_VECTORS" as 0 to generate test vector files
// Set "OUTPUT_BLANK_TEST_VECTORS" as 1 to generate blank template (default)
#define OUTPUT_BLANK_TEST_VECTORS 0

#if !defined(MAMBA_PROFILE)
#define MAMBA_PROFILE 128
#endif

#if MAMBA_PROFILE == 128
#define ALGORITHM_INSTANCE "MAMBA-Sign-128"
#elif MAMBA_PROFILE == 192
#define ALGORITHM_INSTANCE "MAMBA-Sign-192"
#elif MAMBA_PROFILE == 256
#define ALGORITHM_INSTANCE "MAMBA-Sign-256"
#elif MAMBA_PROFILE == 384
#define ALGORITHM_INSTANCE "MAMBA-Sign-384"
#elif MAMBA_PROFILE == 512
#define ALGORITHM_INSTANCE "MAMBA-Sign-512"
#else
#error "Unsupported MAMBA_PROFILE"
#endif

#ifdef __cplusplus
extern "C"
{
#endif
	unsigned long long sig_get_pk_len_bytes();
	unsigned long long sig_get_sk_len_bytes();
	unsigned long long sig_get_sn_len_bytes();

	int sig_keygen(
		unsigned char *pk, unsigned long long *pk_len_bytes,
		unsigned char *sk, unsigned long long *sk_len_bytes);

	int sig_sign(
		unsigned char *sk, unsigned long long sk_len_bytes,
		unsigned char *m, unsigned long long m_len_bytes,
		unsigned char *sn, unsigned long long *sn_len_bytes);

	int sig_verify(
		unsigned char *pk, unsigned long long pk_len_bytes,
		unsigned char *sn, unsigned long long sn_len_bytes,
		unsigned char *m, unsigned long long m_len_bytes);

#ifdef __cplusplus
}
#endif
#endif
