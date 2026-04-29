#!/usr/bin/env sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR="$ROOT_DIR/build"
TXT_OUT="$OUT_DIR/mamba_sign_sizes.txt"
CSV_OUT="$OUT_DIR/mamba_sign_sizes.csv"
TMP_C="$OUT_DIR/.sizes_tmp.c"
TMP_BIN="$OUT_DIR/.sizes_tmp"

mkdir -p "$OUT_DIR"
printf 'profile,CRYPTO_ALGNAME,N,K,L,ETA,TAU,GAMMA1,GAMMA2,OMEGA,CRYPTO_PUBLICKEYBYTES,CRYPTO_SECRETKEYBYTES,CRYPTO_BYTES\n' > "$CSV_OUT"
: > "$TXT_OUT"

collect_one() {
  profile="$1"
  mode="$2"
  cat > "$TMP_C" <<'C'
#include <stdio.h>
#include "sign.h"
#include "params.h"
int main(void) {
  printf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", CRYPTO_ALGNAME, N, K, L, ETA, TAU, GAMMA1, GAMMA2, OMEGA, CRYPTO_PUBLICKEYBYTES, CRYPTO_SECRETKEYBYTES, CRYPTO_BYTES);
  return 0;
}
C
  cc -I"$ROOT_DIR/ref" -DDILITHIUM_MODE="$mode" "$TMP_C" -o "$TMP_BIN"
  row=$($TMP_BIN)

  algname=$(printf '%s' "$row" | cut -d',' -f1)
  n=$(printf '%s' "$row" | cut -d',' -f2)
  k=$(printf '%s' "$row" | cut -d',' -f3)
  l=$(printf '%s' "$row" | cut -d',' -f4)
  eta=$(printf '%s' "$row" | cut -d',' -f5)
  tau=$(printf '%s' "$row" | cut -d',' -f6)
  gamma1=$(printf '%s' "$row" | cut -d',' -f7)
  gamma2=$(printf '%s' "$row" | cut -d',' -f8)
  omega=$(printf '%s' "$row" | cut -d',' -f9)
  pk=$(printf '%s' "$row" | cut -d',' -f10)
  sk=$(printf '%s' "$row" | cut -d',' -f11)
  sig=$(printf '%s' "$row" | cut -d',' -f12)

  {
    printf 'profile = sign%s\n' "$profile"
    printf 'CRYPTO_ALGNAME = %s\n' "$algname"
    printf 'N = %s\nK = %s\nL = %s\nETA = %s\nTAU = %s\nGAMMA1 = %s\nGAMMA2 = %s\nOMEGA = %s\n' "$n" "$k" "$l" "$eta" "$tau" "$gamma1" "$gamma2" "$omega"
    printf 'CRYPTO_PUBLICKEYBYTES = %s\nCRYPTO_SECRETKEYBYTES = %s\nCRYPTO_BYTES = %s\n\n' "$pk" "$sk" "$sig"
  } >> "$TXT_OUT"

  printf 'sign%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "$profile" "$algname" "$n" "$k" "$l" "$eta" "$tau" "$gamma1" "$gamma2" "$omega" "$pk" "$sk" "$sig" >> "$CSV_OUT"
}

collect_one 128 2
collect_one 192 3
collect_one 256 5
collect_one 384 7
collect_one 512 8
rm -f "$TMP_C" "$TMP_BIN"
cat "$TXT_OUT"
printf 'CSV written to %s\n' "$CSV_OUT"
