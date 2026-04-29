#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_TXT="$ROOT/build/mamba_sign_seed_locked.txt"
OUT_CSV="$ROOT/build/mamba_sign_seed_locked.csv"
TMP="$ROOT/build/seed_tmp"
mkdir -p "$TMP"
: > "$OUT_TXT"
printf 'profile,implementation,CRYPTO_ALGNAME,seed,msg,pk_sha256,sk_sha256,sig_sha256,sm_sha256,verify_result\n' > "$OUT_CSV"

hash_hex(){ printf '%s' "$1" | perl -pe 's/(..)/chr(hex($1))/ge' | sha256sum | awk '{print $1}'; }
val(){ awk -F= -v k="$1" '$1==k{print $2}' "$2"; }

for p_m in "128 2" "192 3" "256 5"; do
  set -- $p_m; p=$1; m=$2
  cc -O3 -I"$ROOT/ref" -I"$ROOT/ref/nistkat" -DDILITHIUM_MODE="$m" "$ROOT/scripts/kat_one_sample_tool.c" "$ROOT/ref/nistkat/rng.c" "$ROOT/ref/sign.c" "$ROOT/ref/packing.c" "$ROOT/ref/polyvec.c" "$ROOT/ref/poly.c" "$ROOT/ref/ntt.c" "$ROOT/ref/reduce.c" "$ROOT/ref/rounding.c" "$ROOT/ref/fips202.c" "$ROOT/ref/symmetric-shake.c" -lcrypto -o "$TMP/ref$p"
  cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -I"$ROOT/avx2" -I"$ROOT/ref/nistkat" -DDILITHIUM_MODE="$m" "$ROOT/scripts/kat_one_sample_tool.c" "$ROOT/ref/nistkat/rng.c" "$ROOT/avx2/sign.c" "$ROOT/avx2/packing.c" "$ROOT/avx2/polyvec.c" "$ROOT/avx2/poly.c" "$ROOT/avx2/ntt.S" "$ROOT/avx2/invntt.S" "$ROOT/avx2/pointwise.S" "$ROOT/avx2/shuffle.S" "$ROOT/avx2/consts.c" "$ROOT/avx2/rejsample.c" "$ROOT/avx2/rounding.c" "$ROOT/avx2/fips202.c" "$ROOT/avx2/fips202x4.c" "$ROOT/avx2/f1600x4.S" "$ROOT/avx2/symmetric-shake.c" -lcrypto -o "$TMP/avx$p"
  "$TMP/ref$p" > "$TMP/ref$p.out"
  "$TMP/avx$p" > "$TMP/avx$p.out"
  for impl in ref avx; do
    f="$TMP/${impl}$p.out"
    alg=$(val CRYPTO_ALGNAME "$f"); seed=$(val seed "$f"); msg=$(val msg "$f"); pk=$(val pk "$f"); sk=$(val sk "$f"); sig=$(val sig "$f"); sm=$(val sm "$f"); vr=$(val verify_result "$f")
    pkh=$(hash_hex "$pk"); skh=$(hash_hex "$sk"); sigh=$(hash_hex "$sig"); smh=$(hash_hex "$sm")
    printf 'profile=sign%s implementation=%s CRYPTO_ALGNAME=%s seed=%s msg=%s pk_sha256=%s sk_sha256=%s sig_sha256=%s sm_sha256=%s verify_result=%s\n' "$p" "$impl" "$alg" "$seed" "$msg" "$pkh" "$skh" "$sigh" "$smh" "$vr" >> "$OUT_TXT"
    printf 'sign%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "$p" "$impl" "$alg" "$seed" "$msg" "$pkh" "$skh" "$sigh" "$smh" "$vr" >> "$OUT_CSV"
  done
  echo >> "$OUT_TXT"
done
cat "$OUT_TXT"
echo "CSV written to $OUT_CSV"
