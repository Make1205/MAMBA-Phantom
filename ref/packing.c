#include "params.h"
#include "packing.h"
#include "polyvec.h"
#include "poly.h"

static void polytbar_pack(uint8_t *r, const poly *a) {
  unsigned int i;
  uint32_t bitbuf = 0;
  unsigned int bitcnt = 0;

  for(i = 0; i < N; ++i) {
    uint32_t v = (uint32_t)a->coeffs[i];
    bitbuf |= v << bitcnt;
    bitcnt += TPK;
    while(bitcnt >= 8) {
      *r++ = (uint8_t)(bitbuf & 0xFF);
      bitbuf >>= 8;
      bitcnt -= 8;
    }
  }
}

static void polytbar_unpack(poly *a, const uint8_t *r) {
  unsigned int i;
  uint32_t bitbuf = 0;
  unsigned int bitcnt = 0;

  for(i = 0; i < N; ++i) {
    while(bitcnt < TPK) {
      bitbuf |= ((uint32_t)(*r++)) << bitcnt;
      bitcnt += 8;
    }
    a->coeffs[i] = bitbuf & (PPK - 1);
    bitbuf >>= TPK;
    bitcnt -= TPK;
  }
}

void pack_pk(uint8_t pk[CRYPTO_PUBLICKEYBYTES],
             const uint8_t rho[SEEDBYTES],
             const polyveck *tbar)
{
  unsigned int i;

  for(i = 0; i < SEEDBYTES; ++i)
    pk[i] = rho[i];
  pk += SEEDBYTES;

  for(i = 0; i < K; ++i)
    polytbar_pack(pk + i*POLYTBAR_PACKEDBYTES, &tbar->vec[i]);
}

void unpack_pk(uint8_t rho[SEEDBYTES],
               polyveck *tbar,
               const uint8_t pk[CRYPTO_PUBLICKEYBYTES])
{
  unsigned int i;

  for(i = 0; i < SEEDBYTES; ++i)
    rho[i] = pk[i];
  pk += SEEDBYTES;

  for(i = 0; i < K; ++i)
    polytbar_unpack(&tbar->vec[i], pk + i*POLYTBAR_PACKEDBYTES);
}

void pack_sk(uint8_t sk[CRYPTO_SECRETKEYBYTES],
             const uint8_t rho[SEEDBYTES],
             const uint8_t tr[TRBYTES],
             const polyvecl *s1)
{
  unsigned int i;

  for(i = 0; i < SEEDBYTES; ++i)
    sk[i] = rho[i];
  sk += SEEDBYTES;

  for(i = 0; i < TRBYTES; ++i)
    sk[i] = tr[i];
  sk += TRBYTES;

  for(i = 0; i < L; ++i)
    polyeta_pack(sk + i*POLYETA_PACKEDBYTES, &s1->vec[i]);
}

void unpack_sk(uint8_t rho[SEEDBYTES],
               uint8_t tr[TRBYTES],
               polyvecl *s1,
               const uint8_t sk[CRYPTO_SECRETKEYBYTES])
{
  unsigned int i;

  for(i = 0; i < SEEDBYTES; ++i)
    rho[i] = sk[i];
  sk += SEEDBYTES;

  for(i = 0; i < TRBYTES; ++i)
    tr[i] = sk[i];
  sk += TRBYTES;

  for(i=0; i < L; ++i)
    polyeta_unpack(&s1->vec[i], sk + i*POLYETA_PACKEDBYTES);
}

void pack_sig(uint8_t sig[CRYPTO_BYTES],
              const uint8_t c[CTILDEBYTES],
              const polyvecl *z,
              const polyveck *h)
{
  unsigned int i, j, k;

  for(i=0; i < CTILDEBYTES; ++i)
    sig[i] = c[i];
  sig += CTILDEBYTES;

  for(i = 0; i < L; ++i)
    polyz_pack(sig + i*POLYZ_PACKEDBYTES, &z->vec[i]);
  sig += L*POLYZ_PACKEDBYTES;

  for(i = 0; i < OMEGA + K; ++i)
    sig[i] = 0;

  k = 0;
  for(i = 0; i < K; ++i) {
    for(j = 0; j < N; ++j)
      if(h->vec[i].coeffs[j] != 0)
        sig[k++] = j;

    sig[OMEGA + i] = k;
  }
}

int unpack_sig(uint8_t c[CTILDEBYTES],
               polyvecl *z,
               polyveck *h,
               const uint8_t sig[CRYPTO_BYTES])
{
  unsigned int i, j, k;

  for(i = 0; i < CTILDEBYTES; ++i)
    c[i] = sig[i];
  sig += CTILDEBYTES;

  for(i = 0; i < L; ++i)
    polyz_unpack(&z->vec[i], sig + i*POLYZ_PACKEDBYTES);
  sig += L*POLYZ_PACKEDBYTES;

  k = 0;
  for(i = 0; i < K; ++i) {
    for(j = 0; j < N; ++j)
      h->vec[i].coeffs[j] = 0;

    if(sig[OMEGA + i] < k || sig[OMEGA + i] > OMEGA)
      return 1;

    for(j = k; j < sig[OMEGA + i]; ++j) {
      if(j > k && sig[j] <= sig[j-1]) return 1;
      h->vec[i].coeffs[sig[j]] = 1;
    }

    k = sig[OMEGA + i];
  }

  for(j = k; j < OMEGA; ++j)
    if(sig[j])
      return 1;

  return 0;
}
