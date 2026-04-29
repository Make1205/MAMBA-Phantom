#!/usr/bin/env sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR="$ROOT_DIR/build"
TXT_OUT="$OUT_DIR/mamba_sign_bench.txt"
CSV_OUT="$OUT_DIR/mamba_sign_bench.csv"
TMP_C="$OUT_DIR/.bench_tmp.c"
TMP_BIN="$OUT_DIR/.bench_tmp"
ITERATIONS=1000
TIMING_SOURCE="cpucycles"

mkdir -p "$OUT_DIR"
printf 'profile,CRYPTO_ALGNAME,N,K,L,TAU,OMEGA,PK bytes,SK bytes,SIG bytes,keygen cycles,sign cycles,verify cycles,number of iterations,timing source\n' > "$CSV_OUT"
: > "$TXT_OUT"

collect_one() {
  profile="$1"
  mode="$2"
  cat > "$TMP_C" <<'C'
#include <stdio.h>
#include <stdint.h>
#include "sign.h"
#include "params.h"
#include "randombytes.h"
#include "test/cpucycles.h"

#ifndef BENCH_ITERS
#define BENCH_ITERS 1000
#endif

int main(void) {
  uint8_t pk[CRYPTO_PUBLICKEYBYTES], sk[CRYPTO_SECRETKEYBYTES];
  uint8_t m[32], sig[CRYPTO_BYTES];
  size_t siglen = 0;
  uint64_t t0, t1, sum_keygen = 0, sum_sign = 0, sum_verify = 0;
  uint64_t ov = cpucycles_overhead();
  int i;

  randombytes(m, sizeof(m));
  for(i = 0; i < BENCH_ITERS; i++) {
    t0 = cpucycles();
    crypto_sign_keypair(pk, sk);
    t1 = cpucycles();
    sum_keygen += (t1 - t0 - ov);

    t0 = cpucycles();
    crypto_sign_signature(sig, &siglen, m, sizeof(m), NULL, 0, sk);
    t1 = cpucycles();
    sum_sign += (t1 - t0 - ov);

    t0 = cpucycles();
    crypto_sign_verify(sig, siglen, m, sizeof(m), NULL, 0, pk);
    t1 = cpucycles();
    sum_verify += (t1 - t0 - ov);
  }

  printf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%llu,%llu,%llu,%d,cpucycles\n",
    CRYPTO_ALGNAME, N, K, L, TAU, OMEGA, CRYPTO_PUBLICKEYBYTES, CRYPTO_SECRETKEYBYTES, CRYPTO_BYTES,
    (unsigned long long)(sum_keygen / BENCH_ITERS),
    (unsigned long long)(sum_sign / BENCH_ITERS),
    (unsigned long long)(sum_verify / BENCH_ITERS),
    BENCH_ITERS);
  return 0;
}
C

  cc -O3 -I"$ROOT_DIR/ref" -DDILITHIUM_MODE="$mode" -DBENCH_ITERS="$ITERATIONS" \
    "$TMP_C" "$ROOT_DIR/ref/randombytes.c" "$ROOT_DIR/ref/sign.c" "$ROOT_DIR/ref/packing.c" \
    "$ROOT_DIR/ref/polyvec.c" "$ROOT_DIR/ref/poly.c" "$ROOT_DIR/ref/ntt.c" "$ROOT_DIR/ref/reduce.c" \
    "$ROOT_DIR/ref/rounding.c" "$ROOT_DIR/ref/fips202.c" "$ROOT_DIR/ref/symmetric-shake.c" \
    "$ROOT_DIR/ref/test/cpucycles.c" -o "$TMP_BIN"

  row=$($TMP_BIN)
  algname=$(printf '%s' "$row" | cut -d',' -f1)
  n=$(printf '%s' "$row" | cut -d',' -f2)
  k=$(printf '%s' "$row" | cut -d',' -f3)
  l=$(printf '%s' "$row" | cut -d',' -f4)
  tau=$(printf '%s' "$row" | cut -d',' -f5)
  omega=$(printf '%s' "$row" | cut -d',' -f6)
  pk=$(printf '%s' "$row" | cut -d',' -f7)
  sk=$(printf '%s' "$row" | cut -d',' -f8)
  sig=$(printf '%s' "$row" | cut -d',' -f9)
  keygen=$(printf '%s' "$row" | cut -d',' -f10)
  signc=$(printf '%s' "$row" | cut -d',' -f11)
  verify=$(printf '%s' "$row" | cut -d',' -f12)

  {
    printf 'profile = sign%s\n' "$profile"
    printf 'CRYPTO_ALGNAME = %s\nN = %s\nK = %s\nL = %s\nTAU = %s\nOMEGA = %s\n' "$algname" "$n" "$k" "$l" "$tau" "$omega"
    printf 'PK bytes = %s\nSK bytes = %s\nSIG bytes = %s\n' "$pk" "$sk" "$sig"
    printf 'keygen cycles = %s\nsign cycles = %s\nverify cycles = %s\n' "$keygen" "$signc" "$verify"
    printf 'number of iterations = %s\ntiming source = %s\n\n' "$ITERATIONS" "$TIMING_SOURCE"
  } >> "$TXT_OUT"

  printf 'sign%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
    "$profile" "$algname" "$n" "$k" "$l" "$tau" "$omega" "$pk" "$sk" "$sig" "$keygen" "$signc" "$verify" "$ITERATIONS" "$TIMING_SOURCE" >> "$CSV_OUT"
}

collect_one 128 2
collect_one 192 3
collect_one 256 5
collect_one 384 7
collect_one 512 8

rm -f "$TMP_C" "$TMP_BIN"
cat "$TXT_OUT"
printf 'CSV written to %s\n' "$CSV_OUT"
