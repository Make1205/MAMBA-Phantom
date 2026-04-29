#!/usr/bin/env sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR="$ROOT_DIR/build"
TXT_OUT="$OUT_DIR/mamba_sign_bench_avx2.txt"
CSV_OUT="$OUT_DIR/mamba_sign_bench_avx2.csv"
TMP_C="$OUT_DIR/.bench_avx2_tmp.c"
TMP_BIN="$OUT_DIR/.bench_avx2_tmp"
ITERATIONS=1000
TIMING_SOURCE="cpucycles"

mkdir -p "$OUT_DIR"
printf 'profile,implementation,CRYPTO_ALGNAME,N,K,L,TAU,OMEGA,PK bytes,SK bytes,SIG bytes,keygen cycles,sign cycles,verify cycles,iterations,timing source\n' > "$CSV_OUT"
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
  for(int i = 0; i < BENCH_ITERS; i++) {
    randombytes(m, sizeof(m));
    t0 = cpucycles(); crypto_sign_keypair(pk, sk); t1 = cpucycles(); sum_keygen += (t1 - t0 - ov);
    t0 = cpucycles(); crypto_sign_signature(sig, &siglen, m, sizeof(m), NULL, 0, sk); t1 = cpucycles(); sum_sign += (t1 - t0 - ov);
    t0 = cpucycles(); crypto_sign_verify(sig, siglen, m, sizeof(m), NULL, 0, pk); t1 = cpucycles(); sum_verify += (t1 - t0 - ov);
  }
  printf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%llu,%llu,%llu,%d,cpucycles\n", CRYPTO_ALGNAME, N, K, L, TAU, OMEGA, CRYPTO_PUBLICKEYBYTES, CRYPTO_SECRETKEYBYTES, CRYPTO_BYTES, (unsigned long long)(sum_keygen/BENCH_ITERS), (unsigned long long)(sum_sign/BENCH_ITERS), (unsigned long long)(sum_verify/BENCH_ITERS), BENCH_ITERS);
  return 0;
}
C

  cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -I"$ROOT_DIR/avx2" -DDILITHIUM_MODE="$mode" -DBENCH_ITERS="$ITERATIONS" \
    "$TMP_C" "$ROOT_DIR/avx2/randombytes.c" "$ROOT_DIR/avx2/sign.c" "$ROOT_DIR/avx2/packing.c" "$ROOT_DIR/avx2/polyvec.c" "$ROOT_DIR/avx2/poly.c" \
    "$ROOT_DIR/avx2/ntt.S" "$ROOT_DIR/avx2/invntt.S" "$ROOT_DIR/avx2/pointwise.S" "$ROOT_DIR/avx2/shuffle.S" "$ROOT_DIR/avx2/consts.c" \
    "$ROOT_DIR/avx2/rejsample.c" "$ROOT_DIR/avx2/rounding.c" "$ROOT_DIR/avx2/fips202.c" "$ROOT_DIR/avx2/fips202x4.c" "$ROOT_DIR/avx2/f1600x4.S" \
    "$ROOT_DIR/avx2/symmetric-shake.c" "$ROOT_DIR/avx2/test/cpucycles.c" -o "$TMP_BIN"

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
    printf 'profile = sign%s\nimplementation = avx2\nCRYPTO_ALGNAME = %s\nN = %s\nK = %s\nL = %s\nTAU = %s\nOMEGA = %s\n' "$profile" "$algname" "$n" "$k" "$l" "$tau" "$omega"
    printf 'PK bytes = %s\nSK bytes = %s\nSIG bytes = %s\nkeygen cycles = %s\nsign cycles = %s\nverify cycles = %s\niterations = %s\ntiming source = %s\n\n' "$pk" "$sk" "$sig" "$keygen" "$signc" "$verify" "$ITERATIONS" "$TIMING_SOURCE"
  } >> "$TXT_OUT"
  printf 'sign%s,avx2,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "$profile" "$algname" "$n" "$k" "$l" "$tau" "$omega" "$pk" "$sk" "$sig" "$keygen" "$signc" "$verify" "$ITERATIONS" "$TIMING_SOURCE" >> "$CSV_OUT"
}

collect_one 128 2
collect_one 192 3
collect_one 256 5

rm -f "$TMP_C" "$TMP_BIN"
cat "$TXT_OUT"
echo "sign384 AVX2 status: unsupported (K/L-specific optimized code)." | tee -a "$TXT_OUT"
echo "sign512 AVX2 status: unsupported (K/L-specific optimized code)." | tee -a "$TXT_OUT"
printf 'CSV written to %s\n' "$CSV_OUT"
