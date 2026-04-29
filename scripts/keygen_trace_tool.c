#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "sign.h"
#include "params.h"
#include "rng.h"

static void outhex(const char* n,const uint8_t* b,size_t l){ printf("%s=",n); for(size_t i=0;i<l;i++) printf("%02x",b[i]); printf("\n"); }
int main(void){
 uint8_t entropy[48], seedbuf[2*SEEDBYTES+CRHBYTES], pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES];
 for(size_t i=0;i<48;i++) entropy[i]=(uint8_t)i;
 randombytes_init(entropy,NULL,256);
 randombytes(seedbuf,sizeof(seedbuf));
 outhex("randombytes_seedbuf",seedbuf,sizeof(seedbuf));
 if(crypto_sign_keypair(pk,sk)!=0) return 1;
 outhex("packed_pk",pk,sizeof(pk));
 outhex("packed_sk",sk,sizeof(sk));
 printf("CRYPTO_ALGNAME=%s\n",CRYPTO_ALGNAME);
 return 0;
}
