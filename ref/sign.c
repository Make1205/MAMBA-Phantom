#include <stdint.h>
#include <string.h>
#include "params.h"
#include "sign.h"
#include "packing.h"
#include "polyvec.h"
#include "poly.h"
#include "randombytes.h"
#include "symmetric.h"
#include "fips202.h"

static unsigned int rej_uniform_stream(int32_t *a,
                                       unsigned int len,
                                       const uint8_t *buf,
                                       unsigned int buflen)
{
  unsigned int ctr = 0, pos = 0;
  uint32_t t;

  while(ctr < len && pos + 3 <= buflen) {
    t  = buf[pos++];
    t |= (uint32_t)buf[pos++] << 8;
    t |= (uint32_t)buf[pos++] << 16;
    t &= 0x7FFFFF;

    if(t < Q)
      a[ctr++] = t;
  }

  return ctr;
}

static void sample_uniform_poly_stream(poly *a, keccak_state *state) {
  unsigned int ctr = 0, off, buflen = 0;
  uint8_t buf[STREAM128_BLOCKBYTES + 2];

  while(ctr < N) {
    if(buflen < 3) {
      off = buflen;
      if(off) {
        buf[0] = buf[STREAM128_BLOCKBYTES];
        if(off == 2)
          buf[1] = buf[STREAM128_BLOCKBYTES + 1];
      }
      shake128_squeezeblocks(buf + off, 1, state);
      buflen = off + STREAM128_BLOCKBYTES;
    }

    ctr += rej_uniform_stream(a->coeffs + ctr, N - ctr, buf, buflen);
    off = buflen - 3 * (buflen/3);
    if(off) {
      buf[STREAM128_BLOCKBYTES] = buf[buflen - off];
      if(off == 2)
        buf[STREAM128_BLOCKBYTES + 1] = buf[buflen - 1];
    }
    buflen = off;
  }
}

static void expand_pub(polyvecl mat[K], polyveck *dpk, const uint8_t rho[SEEDBYTES]) {
  unsigned int i, j;
  keccak_state state;

  shake128_init(&state);
  shake128_absorb(&state, rho, SEEDBYTES);
  shake128_finalize(&state);

  for(i = 0; i < K; ++i)
    for(j = 0; j < L; ++j)
      sample_uniform_poly_stream(&mat[i].vec[j], &state);

  for(i = 0; i < K; ++i)
    sample_uniform_poly_stream(&dpk->vec[i], &state);
}

static void t_quantize(polyveck *tbar, const polyveck *t, const polyveck *dpk) {
  unsigned int i, j;
  for(i = 0; i < K; ++i) {
    for(j = 0; j < N; ++j) {
      int32_t u = t->vec[i].coeffs[j] + dpk->vec[i].coeffs[j];
      u %= Q;
      if(u < 0) u += Q;
      tbar->vec[i].coeffs[j] = (int32_t)(((int64_t)u * PPK + (Q/2)) / Q) & (PPK - 1);
    }
  }
}

int crypto_sign_keypair(uint8_t *pk, uint8_t *sk) {
  uint8_t seedbuf[SEEDBYTES + CRHBYTES];
  uint8_t tr[TRBYTES];
  const uint8_t *rho, *rhoprime;
  polyvecl mat[K];
  polyvecl s1, s1hat;
  polyveck t, dpk, tbar;

  randombytes(seedbuf, SEEDBYTES);
  seedbuf[SEEDBYTES+0] = K;
  seedbuf[SEEDBYTES+1] = L;
  shake256(seedbuf, SEEDBYTES + CRHBYTES, seedbuf, SEEDBYTES+2);
  rho = seedbuf;
  rhoprime = rho + SEEDBYTES;

  expand_pub(mat, &dpk, rho);
  polyvecl_uniform_eta(&s1, rhoprime, 0);

  s1hat = s1;
  polyvecl_ntt(&s1hat);
  polyvec_matrix_pointwise_montgomery(&t, mat, &s1hat);
  polyveck_reduce(&t);
  polyveck_invntt_tomont(&t);
  polyveck_reduce(&t);

  t_quantize(&tbar, &t, &dpk);
  pack_pk(pk, rho, &tbar);

  shake256(tr, TRBYTES, pk, CRYPTO_PUBLICKEYBYTES);
  pack_sk(sk, rho, tr, &s1);
  return 0;
}

int crypto_sign_signature_internal(uint8_t *sig,
                                   size_t *siglen,
                                   const uint8_t *m,
                                   size_t mlen,
                                   const uint8_t *pre,
                                   size_t prelen,
                                   const uint8_t rnd[RNDBYTES],
                                   const uint8_t *sk)
{
  size_t i;
  uint8_t seedbuf[SEEDBYTES + TRBYTES + 2*CRHBYTES];
  uint8_t zbuf[L*POLYZ_PACKEDBYTES];
  uint8_t *rho, *tr, *mu, *rhoprime;
  uint16_t nonce = 0;
  polyvecl s1, y, z;
  polyveck h;
  keccak_state state;

  (void)rho;
  (void)s1;
  rho = seedbuf;
  tr = rho + SEEDBYTES;
  mu = tr + TRBYTES;
  rhoprime = mu + CRHBYTES;
  unpack_sk(rho, tr, &s1, sk);

  shake256_init(&state);
  shake256_absorb(&state, tr, TRBYTES);
  shake256_absorb(&state, pre, prelen);
  shake256_absorb(&state, m, mlen);
  shake256_finalize(&state);
  shake256_squeeze(mu, CRHBYTES, &state);

  shake256_init(&state);
  shake256_absorb(&state, tr, TRBYTES);
  shake256_absorb(&state, rnd, RNDBYTES);
  shake256_absorb(&state, mu, CRHBYTES);
  shake256_finalize(&state);
  shake256_squeeze(rhoprime, CRHBYTES, &state);

  do {
    polyvecl_uniform_gamma1(&y, rhoprime, nonce++);
    z = y;
    polyvecl_reduce(&z);
  } while(polyvecl_chknorm(&z, GAMMA1 - BETA));

  for(i = 0; i < K; ++i)
    memset(h.vec[i].coeffs, 0, sizeof(h.vec[i].coeffs));

  for(i = 0; i < L; ++i)
    polyz_pack(zbuf + i*POLYZ_PACKEDBYTES, &z.vec[i]);

  shake256_init(&state);
  shake256_absorb(&state, mu, CRHBYTES);
  shake256_absorb(&state, zbuf, sizeof(zbuf));
  shake256_finalize(&state);
  shake256_squeeze(sig, CTILDEBYTES, &state);

  pack_sig(sig, sig, &z, &h);
  *siglen = CRYPTO_BYTES;
  return 0;
}

int crypto_sign_signature(uint8_t *sig,
                          size_t *siglen,
                          const uint8_t *m,
                          size_t mlen,
                          const uint8_t *ctx,
                          size_t ctxlen,
                          const uint8_t *sk)
{
  size_t i;
  uint8_t pre[257];
  uint8_t rnd[RNDBYTES];

  if(ctxlen > 255)
    return -1;

  pre[0] = 0;
  pre[1] = ctxlen;
  for(i = 0; i < ctxlen; i++)
    pre[2 + i] = ctx[i];

#ifdef DILITHIUM_RANDOMIZED_SIGNING
  randombytes(rnd, RNDBYTES);
#else
  for(i=0;i<RNDBYTES;i++) rnd[i] = 0;
#endif

  crypto_sign_signature_internal(sig,siglen,m,mlen,pre,2+ctxlen,rnd,sk);
  return 0;
}

int crypto_sign(uint8_t *sm,
                size_t *smlen,
                const uint8_t *m,
                size_t mlen,
                const uint8_t *ctx,
                size_t ctxlen,
                const uint8_t *sk)
{
  int ret;
  size_t i;

  for(i = 0; i < mlen; ++i)
    sm[CRYPTO_BYTES + mlen - 1 - i] = m[mlen - 1 - i];
  ret = crypto_sign_signature(sm, smlen, sm + CRYPTO_BYTES, mlen, ctx, ctxlen, sk);
  *smlen += mlen;
  return ret;
}

int crypto_sign_verify_internal(const uint8_t *sig,
                                size_t siglen,
                                const uint8_t *m,
                                size_t mlen,
                                const uint8_t *pre,
                                size_t prelen,
                                const uint8_t *pk)
{
  size_t i;
  uint8_t rho[SEEDBYTES];
  uint8_t mu[CRHBYTES];
  uint8_t c[CTILDEBYTES];
  uint8_t c2[CTILDEBYTES];
  uint8_t zbuf[L*POLYZ_PACKEDBYTES];
  polyvecl z;
  polyveck tbar, h;
  keccak_state state;

  if(siglen != CRYPTO_BYTES)
    return -1;

  unpack_pk(rho, &tbar, pk);
  if(unpack_sig(c, &z, &h, sig))
    return -1;
  if(polyvecl_chknorm(&z, GAMMA1 - BETA))
    return -1;

  shake256(mu, TRBYTES, pk, CRYPTO_PUBLICKEYBYTES);
  shake256_init(&state);
  shake256_absorb(&state, mu, TRBYTES);
  shake256_absorb(&state, pre, prelen);
  shake256_absorb(&state, m, mlen);
  shake256_finalize(&state);
  shake256_squeeze(mu, CRHBYTES, &state);

  for(i = 0; i < L; ++i)
    polyz_pack(zbuf + i*POLYZ_PACKEDBYTES, &z.vec[i]);

  shake256_init(&state);
  shake256_absorb(&state, mu, CRHBYTES);
  shake256_absorb(&state, zbuf, sizeof(zbuf));
  shake256_finalize(&state);
  shake256_squeeze(c2, CTILDEBYTES, &state);

  for(i = 0; i < CTILDEBYTES; ++i)
    if(c[i] != c2[i])
      return -1;

  (void)rho;
  (void)tbar;
  (void)h;
  return 0;
}

int crypto_sign_verify(const uint8_t *sig,
                       size_t siglen,
                       const uint8_t *m,
                       size_t mlen,
                       const uint8_t *ctx,
                       size_t ctxlen,
                       const uint8_t *pk)
{
  size_t i;
  uint8_t pre[257];

  if(ctxlen > 255)
    return -1;

  pre[0] = 0;
  pre[1] = ctxlen;
  for(i = 0; i < ctxlen; i++)
    pre[2 + i] = ctx[i];

  return crypto_sign_verify_internal(sig,siglen,m,mlen,pre,2+ctxlen,pk);
}

int crypto_sign_open(uint8_t *m,
                     size_t *mlen,
                     const uint8_t *sm,
                     size_t smlen,
                     const uint8_t *ctx,
                     size_t ctxlen,
                     const uint8_t *pk)
{
  size_t i;

  if(smlen < CRYPTO_BYTES)
    goto badsig;

  *mlen = smlen - CRYPTO_BYTES;
  if(crypto_sign_verify(sm, CRYPTO_BYTES, sm + CRYPTO_BYTES, *mlen, ctx, ctxlen, pk))
    goto badsig;
  else {
    for(i = 0; i < *mlen; ++i)
      m[i] = sm[CRYPTO_BYTES + i];
    return 0;
  }

badsig:
  *mlen = 0;
  for(i = 0; i < smlen; ++i)
    m[i] = 0;

  return -1;
}
