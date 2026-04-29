#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/build/mamba_sign_kat_compare.txt"
mkdir -p "$ROOT/build" "$ROOT/KAT"
: > "$OUT"

make -C "$ROOT" vectors128 >/dev/null
make -C "$ROOT" vectors192 >/dev/null
make -C "$ROOT" vectors256 >/dev/null
make -C "$ROOT" vectors128-avx2 >/dev/null
make -C "$ROOT" vectors192-avx2 >/dev/null
make -C "$ROOT" vectors256-avx2 >/dev/null

cmp_one() {
  p="$1"
  ref="$ROOT/KAT/PQCsignKAT_sign${p}.rsp"
  avx="$ROOT/KAT/PQCsignKAT_sign${p}_avx2.rsp"
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

if grep -q 'byte-identical: NO' "$OUT"; then
  echo "semantic cross-check fallback: RUN" | tee -a "$OUT"
  "$ROOT/scripts/cross_check_ref_avx2.sh" >> "$OUT"
  echo "semantic cross-check result: PASS" | tee -a "$OUT"
else
  echo "semantic cross-check fallback: SKIP (all byte-identical)" | tee -a "$OUT"
fi

cat "$OUT"
