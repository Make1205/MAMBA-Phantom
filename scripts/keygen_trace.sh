#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TXT="$ROOT/build/mamba_sign_keygen_trace.txt"
CSV="$ROOT/build/mamba_sign_keygen_trace.csv"
TMP="$ROOT/build/keytrace_tmp"
mkdir -p "$TMP"
: > "$TXT"
printf 'profile,implementation,object,sha256\n' > "$CSV"
hash_hex(){ printf '%s' "$1" | perl -pe 's/(..)/chr(hex($1))/ge' | sha256sum | awk '{print $1}'; }
for pm in "128 2" "192 3" "256 5"; do
 set -- $pm; p=$1; m=$2
 cc -O3 -I"$ROOT/ref" -I"$ROOT/ref/nistkat" -DDILITHIUM_MODE="$m" "$ROOT/scripts/keygen_trace_tool.c" "$ROOT/ref/nistkat/rng.c" "$ROOT/ref/sign.c" "$ROOT/ref/packing.c" "$ROOT/ref/polyvec.c" "$ROOT/ref/poly.c" "$ROOT/ref/ntt.c" "$ROOT/ref/reduce.c" "$ROOT/ref/rounding.c" "$ROOT/ref/fips202.c" "$ROOT/ref/symmetric-shake.c" -lcrypto -o "$TMP/ref$p"
 cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -I"$ROOT/avx2" -I"$ROOT/ref/nistkat" -DDILITHIUM_MODE="$m" "$ROOT/scripts/keygen_trace_tool.c" "$ROOT/ref/nistkat/rng.c" "$ROOT/avx2/sign.c" "$ROOT/avx2/packing.c" "$ROOT/avx2/polyvec.c" "$ROOT/avx2/poly.c" "$ROOT/avx2/ntt.S" "$ROOT/avx2/invntt.S" "$ROOT/avx2/pointwise.S" "$ROOT/avx2/shuffle.S" "$ROOT/avx2/consts.c" "$ROOT/avx2/rejsample.c" "$ROOT/avx2/rounding.c" "$ROOT/avx2/fips202.c" "$ROOT/avx2/fips202x4.c" "$ROOT/avx2/f1600x4.S" "$ROOT/avx2/symmetric-shake.c" -lcrypto -o "$TMP/avx$p"
 "$TMP/ref$p" > "$TMP/ref$p.out"; "$TMP/avx$p" > "$TMP/avx$p.out"
 for impl in ref avx; do
  f="$TMP/${impl}$p.out"
  for obj in randombytes_seedbuf packed_pk packed_sk; do
   v=$(awk -F= -v k="$obj" '$1==k{print $2}' "$f")
   h=$(hash_hex "$v")
   echo "profile=sign$p impl=$impl object=$obj sha256=$h" >> "$TXT"
   printf 'sign%s,%s,%s,%s\n' "$p" "$impl" "$obj" "$h" >> "$CSV"
  done
 done
 echo >> "$TXT"
done
cat "$TXT"
echo "CSV written to $CSV"
