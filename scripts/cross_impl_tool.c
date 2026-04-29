#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "sign.h"
#include "params.h"

static int read_file(const char *path, uint8_t *buf, size_t len) {
  FILE *f = fopen(path, "rb");
  if(!f) return -1;
  size_t n = fread(buf, 1, len, f);
  fclose(f);
  return n == len ? 0 : -1;
}

static int write_file(const char *path, const uint8_t *buf, size_t len) {
  FILE *f = fopen(path, "wb");
  if(!f) return -1;
  size_t n = fwrite(buf, 1, len, f);
  fclose(f);
  return n == len ? 0 : -1;
}

int main(int argc, char **argv) {
  if(argc < 2) return 2;
  if(strcmp(argv[1], "print") == 0) {
    printf("CRYPTO_ALGNAME=%s\nN=%d\nK=%d\nL=%d\nTAU=%d\nOMEGA=%d\nPK=%d\nSK=%d\nSIG=%d\n", CRYPTO_ALGNAME, N, K, L, TAU, OMEGA, CRYPTO_PUBLICKEYBYTES, CRYPTO_SECRETKEYBYTES, CRYPTO_BYTES);
    return 0;
  }
  if(strcmp(argv[1], "gen") == 0 && argc == 5) {
    uint8_t pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES];
    if(crypto_sign_keypair(pk, sk) != 0) return 3;
    if(write_file(argv[2], pk, sizeof(pk)) != 0) return 4;
    if(write_file(argv[3], sk, sizeof(sk)) != 0) return 5;
    uint8_t msg[32];
    for(size_t i=0;i<sizeof(msg);i++) msg[i] = (uint8_t)(i + 1);
    if(write_file(argv[4], msg, sizeof(msg)) != 0) return 6;
    return 0;
  }
  if(strcmp(argv[1], "sign") == 0 && argc == 5) {
    uint8_t sk[CRYPTO_SECRETKEYBYTES], msg[32], sig[CRYPTO_BYTES];
    size_t siglen = 0;
    if(read_file(argv[2], sk, sizeof(sk)) != 0) return 7;
    if(read_file(argv[3], msg, sizeof(msg)) != 0) return 8;
    if(crypto_sign_signature(sig, &siglen, msg, sizeof(msg), NULL, 0, sk) != 0) return 9;
    if(siglen != CRYPTO_BYTES) return 10;
    if(write_file(argv[4], sig, siglen) != 0) return 11;
    return 0;
  }
  if(strcmp(argv[1], "verify") == 0 && argc == 5) {
    uint8_t pk[CRYPTO_PUBLICKEYBYTES], msg[32], sig[CRYPTO_BYTES];
    if(read_file(argv[2], pk, sizeof(pk)) != 0) return 12;
    if(read_file(argv[3], msg, sizeof(msg)) != 0) return 13;
    if(read_file(argv[4], sig, sizeof(sig)) != 0) return 14;
    if(crypto_sign_verify(sig, sizeof(sig), msg, sizeof(msg), NULL, 0, pk) != 0) return 15;
    return 0;
  }
  return 16;
}
