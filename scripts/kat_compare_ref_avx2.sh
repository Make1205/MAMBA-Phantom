#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/build/mamba_sign_kat_compare.txt"
mkdir -p "$ROOT/build" "$ROOT/KAT"
: > "$OUT"

make -C "$ROOT" kat128 >/dev/null
make -C "$ROOT" kat192 >/dev/null
make -C "$ROOT" kat256 >/dev/null
make -C "$ROOT" kat128-avx2 >/dev/null
make -C "$ROOT" kat192-avx2 >/dev/null
make -C "$ROOT" kat256-avx2 >/dev/null

cmp_one() {
  p="$1"
  ref="$ROOT/KAT/PQCsignKAT_sign${p}.rsp"
  avx="$ROOT/KAT/PQCsignKAT_sign${p}_avx2.rsp"
  pklen=$(awk -F' = ' '/^pk = /{print length($2); exit}' "$ref")
  if [ "$pklen" = "64" ]; then
    echo "ERROR: KAT_INPUT_NOT_FULL for sign$p" | tee -a "$OUT"; exit 2
  fi
  h1=$(sha256sum "$ref" | awk '{print $1}')
  h2=$(sha256sum "$avx" | awk '{print $1}')
  if [ "$h1" = "$h2" ]; then
    echo "sign$p byte-identical: YES" | tee -a "$OUT"
  else
    echo "sign$p byte-identical: NO" | tee -a "$OUT"
  fi
  echo "sign$p ref_sha256=$h1" >> "$OUT"
  echo "sign$p avx2_sha256=$h2" >> "$OUT"
}

cmp_one 128
cmp_one 192
cmp_one 256

echo "semantic cross-check fallback: DISABLED in kat-compare" | tee -a "$OUT"

cat "$OUT"
