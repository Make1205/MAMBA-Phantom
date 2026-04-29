#include "keypair_scalar_compat.h"
#include "sign.h"
#include "symmetric.h"
#include "packing.h"
#include "polyvec.h"
#include "poly.h"
#include "rounding.h"
#include "randombytes.h"

static int32_t montgomery_reduce_local(int64_t a){int32_t t=(int32_t)a*QINV; t=(a-(int64_t)t*Q)>>32; return t;}
static int32_t fqmul_local(int32_t a,int32_t b){return montgomery_reduce_local((int64_t)a*b);}

static const int32_t zetas[N] = {
0,25847,-2608894,-518909,237124,-777960,-876248,466468,1826347,2353451,
-359251,831313,1460465,-1285669,-681931,-3318210,-1430225,-451100,1312455,
3306115,-1962642,-1279661,1917081,-2546312,-1374803,1500165,777191,2235880,
3406031,-542412,-2831860,-1671176,-1846953,-2584293,-372427,594136,-3776993,
-2013608,2432395,2454455,-164721,-1957272,3369112,185531,717303,-3183426,
162844,1616392,3014001,810149,1652634,-3694233,-1799107,-3038916,3523897,
3866901,269760,2213111,-975884,1717735,472078,-426683,1723600,-1803090,
1910376,-1667432,-1104333,-260646,-3833893,-2939036,-2235985,-420899,-2286327,
183443,-976891,1612842,-3545687,-554416,3919660,-48306,-1362209,3937738,
1400424,-846154,1976782
};

static void ntt_scalar(int32_t a[N]) { unsigned int len,start,j,k=1; int32_t zeta,t;
 for(len=128; len>0; len>>=1) for(start=0; start<N; start=j+len){ zeta=zetas[k++]; for(j=start;j<start+len;j++){ t=fqmul_local(zeta,a[j+len]); a[j+len]=a[j]-t; a[j]=a[j]+t; } } }

static void invntt_scalar(int32_t a[N]) { unsigned int start,len,j,k=256; int32_t t,zeta; const int32_t f=41978;
 for(len=1; len<256; len<<=1) for(start=0; start<N; start=j+len){ zeta=-zetas[--k]; for(j=start;j<start+len;j++){ t=a[j]; a[j]=t+a[j+len]; a[j+len]=t-a[j+len]; a[j+len]=fqmul_local(zeta,a[j+len]); } }
 for(j=0;j<N;j++) a[j]=fqmul_local(a[j],f);
}

static void polyvecl_ntt_scalar(polyvecl *v){for(unsigned i=0;i<L;i++) ntt_scalar(v->vec[i].coeffs);} 
static void polyveck_invntt_scalar(polyveck *v){for(unsigned i=0;i<K;i++) invntt_scalar(v->vec[i].coeffs);} 

static void sample_uniform_poly_stream(poly *a, stream128_state *state) {unsigned int off=0;int ctr;uint8_t buf[POLY_UNIFORM_NBLOCKS*STREAM128_BLOCKBYTES + 2];
  stream128_squeezeblocks(buf, POLY_UNIFORM_NBLOCKS, state); ctr = rej_uniform(a->coeffs, N, buf, POLY_UNIFORM_NBLOCKS*STREAM128_BLOCKBYTES);
  while(ctr < N) { off = POLY_UNIFORM_NBLOCKS*STREAM128_BLOCKBYTES % 3; for(unsigned i=0;i<off;i++) buf[i] = buf[POLY_UNIFORM_NBLOCKS*STREAM128_BLOCKBYTES-off+i];
    stream128_squeezeblocks(buf+off, 1, state); ctr += rej_uniform(a->coeffs + ctr, N - ctr, buf, off + STREAM128_BLOCKBYTES);} }

static void expand_pub_scalar(polyvecl mat[K], polyveck *dpk, const uint8_t rho[SEEDBYTES]) {
  stream128_state state; for(unsigned i=0;i<K;i++) for(unsigned j=0;j<L;j++){
    shake128_absorb(&state, rho, SEEDBYTES); shake128_absorb(&state, (const uint8_t *)&i, 1); shake128_absorb(&state, (const uint8_t *)&j, 1); shake128_finalize(&state);
    sample_uniform_poly_stream(&mat[i].vec[j], &state); }
  for(unsigned i=0;i<K;i++) for(unsigned j=0;j<N;j++){ int32_t c=0; for(unsigned p=0;p<L;p++) c += mat[i].vec[p].coeffs[j]; dpk->vec[i].coeffs[j]=c % Q; if(dpk->vec[i].coeffs[j]<0) dpk->vec[i].coeffs[j]+=Q; }
}

static void t_quantize_scalar(polyveck *tbar, const polyveck *t, const polyveck *dpk) { for(unsigned i=0;i<K;i++) for(unsigned j=0;j<N;j++){ int32_t u=t->vec[i].coeffs[j]+dpk->vec[i].coeffs[j]; u%=Q; if(u<0) u+=Q; tbar->vec[i].coeffs[j]=(int32_t)(((int64_t)u*PPK+(Q/2))/Q)&(PPK-1);} }

int crypto_sign_keypair_scalar_compat(uint8_t *pk, uint8_t *sk) {
  uint8_t seedbuf[SEEDBYTES + CRHBYTES], tr[TRBYTES]; const uint8_t *rho,*rhoprime; polyvecl mat[K], s1, s1hat; polyveck t, dpk, tbar;
  randombytes(seedbuf, SEEDBYTES); seedbuf[SEEDBYTES]=K; seedbuf[SEEDBYTES+1]=L; shake256(seedbuf, SEEDBYTES+CRHBYTES, seedbuf, SEEDBYTES+2);
  rho=seedbuf; rhoprime=rho+SEEDBYTES; expand_pub_scalar(mat,&dpk,rho); polyvecl_uniform_eta(&s1,rhoprime,0);
  s1hat=s1; polyvecl_ntt_scalar(&s1hat); polyvec_matrix_pointwise_montgomery(&t, mat, &s1hat); polyveck_reduce(&t); polyveck_invntt_scalar(&t); polyveck_reduce(&t);
  t_quantize_scalar(&tbar,&t,&dpk); pack_pk(pk,rho,&tbar); shake256(tr,TRBYTES,pk,CRYPTO_PUBLICKEYBYTES); pack_sk(sk,rho,tr,&s1); return 0;
}
