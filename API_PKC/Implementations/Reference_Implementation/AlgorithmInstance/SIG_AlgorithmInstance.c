#include <stddef.h>
#include <string.h>

#include "SIG_AlgorithmInstance.h"
#include "params.h"
#include "sign.h"

unsigned long long sig_get_pk_len_bytes(void) { return CRYPTO_PUBLICKEYBYTES; }
unsigned long long sig_get_sk_len_bytes(void) { return CRYPTO_SECRETKEYBYTES; }
unsigned long long sig_get_sn_len_bytes(void) { return CRYPTO_BYTES; }

int sig_keygen(
    unsigned char *pk, unsigned long long *pk_len_bytes,
    unsigned char *sk, unsigned long long *sk_len_bytes)
{
    int rc = crypto_sign_keypair(pk, sk);
    if (rc != 0) {
        return rc;
    }
    *pk_len_bytes = CRYPTO_PUBLICKEYBYTES;
    *sk_len_bytes = CRYPTO_SECRETKEYBYTES;
    return 0;
}

int sig_sign(
    unsigned char *sk, unsigned long long sk_len_bytes,
    unsigned char *m, unsigned long long m_len_bytes,
    unsigned char *sn, unsigned long long *sn_len_bytes)
{
    (void)sk_len_bytes;
    return crypto_sign_signature(sn, (size_t *)sn_len_bytes, m, m_len_bytes, NULL, 0, sk);
}

int sig_verify(
    unsigned char *pk, unsigned long long pk_len_bytes,
    unsigned char *sn, unsigned long long sn_len_bytes,
    unsigned char *m, unsigned long long m_len_bytes)
{
    (void)pk_len_bytes;
    return crypto_sign_verify(sn, sn_len_bytes, m, m_len_bytes, NULL, 0, pk);
}
