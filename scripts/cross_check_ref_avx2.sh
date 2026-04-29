#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR="$ROOT/build"
TMP="$OUT_DIR/cross_tmp"
TXT="$OUT_DIR/mamba_sign_cross_check.txt"
CSV="$OUT_DIR/mamba_sign_cross_check.csv"
mkdir -p "$TMP"

cc_common_ref='-O3 -I'$ROOT'/ref -I'$ROOT'/ref/test -m64'
cc_common_avx2='-O3 -mavx2 -mpopcnt -march=native -mtune=native -I'$ROOT'/avx2 -I'$ROOT'/avx2/test'

printf 'profile,test,result\n' > "$CSV"
: > "$TXT"

run_profile() {
  name="$1"; mode="$2"
  ref_bin="$TMP/ref_${name}"; avx2_bin="$TMP/avx2_${name}"
  cc $cc_common_ref -DDILITHIUM_MODE="$mode" "$ROOT/scripts/cross_impl_tool.c" "$ROOT/ref/randombytes.c" "$ROOT/ref/sign.c" "$ROOT/ref/packing.c" "$ROOT/ref/polyvec.c" "$ROOT/ref/poly.c" "$ROOT/ref/ntt.c" "$ROOT/ref/reduce.c" "$ROOT/ref/rounding.c" "$ROOT/ref/fips202.c" "$ROOT/ref/symmetric-shake.c" -o "$ref_bin"
  cc $cc_common_avx2 -DDILITHIUM_MODE="$mode" "$ROOT/scripts/cross_impl_tool.c" "$ROOT/avx2/randombytes.c" "$ROOT/avx2/sign.c" "$ROOT/avx2/packing.c" "$ROOT/avx2/polyvec.c" "$ROOT/avx2/poly.c" "$ROOT/avx2/ntt.S" "$ROOT/avx2/invntt.S" "$ROOT/avx2/pointwise.S" "$ROOT/avx2/shuffle.S" "$ROOT/avx2/consts.c" "$ROOT/avx2/rejsample.c" "$ROOT/avx2/rounding.c" "$ROOT/avx2/fips202.c" "$ROOT/avx2/fips202x4.c" "$ROOT/avx2/f1600x4.S" "$ROOT/avx2/symmetric-shake.c" -o "$avx2_bin"

  p="$TMP/$name"
  "$ref_bin" gen "$p.pk.ref" "$p.sk.ref" "$p.msg"
  "$ref_bin" sign "$p.sk.ref" "$p.msg" "$p.sig.ref"
  "$ref_bin" verify "$p.pk.ref" "$p.msg" "$p.sig.ref"
  echo "$name,a_ref_ref_ref,PASS" >> "$CSV"

  "$avx2_bin" gen "$p.pk.avx2" "$p.sk.avx2" "$p.msg2"
  "$avx2_bin" sign "$p.sk.avx2" "$p.msg2" "$p.sig.avx2"
  "$avx2_bin" verify "$p.pk.avx2" "$p.msg2" "$p.sig.avx2"
  echo "$name,b_avx2_avx2_avx2,PASS" >> "$CSV"

  "$avx2_bin" verify "$p.pk.ref" "$p.msg" "$p.sig.ref"
  echo "$name,c_refsign_avx2verify,PASS" >> "$CSV"

  "$ref_bin" verify "$p.pk.avx2" "$p.msg2" "$p.sig.avx2"
  echo "$name,d_avx2sign_refverify,PASS" >> "$CSV"

  "$avx2_bin" sign "$p.sk.ref" "$p.msg" "$p.sig.from_refsk.avx2"
  "$ref_bin" verify "$p.pk.ref" "$p.msg" "$p.sig.from_refsk.avx2"
  echo "$name,e_ref_keys_parse_by_avx2,PASS" >> "$CSV"

  "$ref_bin" sign "$p.sk.avx2" "$p.msg2" "$p.sig.from_avx2sk.ref"
  "$avx2_bin" verify "$p.pk.avx2" "$p.msg2" "$p.sig.from_avx2sk.ref"
  echo "$name,f_avx2_keys_parse_by_ref,PASS" >> "$CSV"

  {
    echo "[$name] PASS"
    "$ref_bin" print
  } >> "$TXT"
}

run_profile sign128 2
run_profile sign192 3
run_profile sign256 5
run_profile sign384 7
run_profile sign512 8
cat "$TXT"
echo "CSV written to $CSV"
