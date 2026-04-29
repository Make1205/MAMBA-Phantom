#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "sign.h"
#include "params.h"
#include "rng.h"

static void hexout(const char *k, const uint8_t *b, size_t n){
  printf("%s=", k);
  for(size_t i=0;i<n;i++) printf("%02x", b[i]);
  printf("\n");
}

int main(void){
  uint8_t entropy[48], msg[32], pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES], sig[CRYPTO_BYTES], sm[32+CRYPTO_BYTES], openm[32+CRYPTO_BYTES];
  size_t siglen=0, smlen=0, mlen=0;
  memset(entropy,0,sizeof(entropy));
  for(size_t i=0;i<sizeof(entropy);i++) entropy[i]=(uint8_t)i;
  for(size_t i=0;i<sizeof(msg);i++) msg[i]=(uint8_t)(0xA0+i);
  randombytes_init(entropy,NULL,256);
  if(crypto_sign_keypair(pk,sk)!=0) return 2;
  if(crypto_sign_signature(sig,&siglen,msg,sizeof(msg),NULL,0,sk)!=0) return 3;
  if(crypto_sign(sm,&smlen,msg,sizeof(msg),NULL,0,sk)!=0) return 4;
  int vr = crypto_sign_verify(sig,siglen,msg,sizeof(msg),NULL,0,pk);
  int orc = crypto_sign_open(openm,&mlen,sm,smlen,NULL,0,pk);
  printf("CRYPTO_ALGNAME=%s\nN=%d\nK=%d\nL=%d\n",CRYPTO_ALGNAME,N,K,L);
  hexout("seed", entropy, sizeof(entropy));
  hexout("msg", msg, sizeof(msg));
  hexout("pk", pk, sizeof(pk));
  hexout("sk", sk, sizeof(sk));
  hexout("sig", sig, siglen);
  hexout("sm", sm, smlen);
  printf("verify_result=%d\nopen_result=%d\n", vr, orc);
  return 0;
}
