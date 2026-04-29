#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAX_COUNT=${1:-5}
OUT_TXT="$ROOT/build/mamba_sign_kat_diagnose.txt"
OUT_CSV="$ROOT/build/mamba_sign_kat_diagnose.csv"
PROBE="$ROOT/build/mamba_sign_kat_file_probe.txt"
mkdir -p "$ROOT/build"
: > "$OUT_TXT"
: > "$PROBE"
printf 'profile,first_differing_count,first_differing_field,ref_len,avx2_len,ref_sha256,avx2_sha256,mismatch_type\n' > "$OUT_CSV"

get_field() {
  file="$1"; cnt="$2"; field="$3"
  awk -v c="$cnt" -v f="$field" '
    BEGIN{inblk=0}
    $1=="count" && $2=="=" {inblk=($3==c)}
    inblk && tolower($1)==tolower(f) && $2=="=" {
      sub("^[^=]*= ", "", $0);
      gsub(/[[:space:]]/, "", $0);
      print; exit
    }
  ' "$file"
}

for p in 128 192 256; do
  ref="$ROOT/KAT/PQCsignKAT_sign${p}.rsp"
  avx="$ROOT/KAT/PQCsignKAT_sign${p}_avx2.rsp"
  first_count=""; first_field=""; mismatch_type="FORMAT_ONLY_DIFF"
  for c in $(seq 0 $((MAX_COUNT-1))); do
    for f in seed mlen msg pk sk smlen sm; do
      rv=$(get_field "$ref" "$c" "$f" || true)
      av=$(get_field "$avx" "$c" "$f" || true)
      if [ "$rv" != "$av" ]; then
        first_count="$c"; first_field="$f"
        rlen=${#rv}; alen=${#av}
        rh=$(printf '%s' "$rv" | sha256sum | awk '{print $1}')
        ah=$(printf '%s' "$av" | sha256sum | awk '{print $1}')
        if [ "$f" = "seed" ] || [ "$f" = "msg" ] || [ "$f" = "mlen" ]; then
          mismatch_type="KAT_INPUT_DIFF"
        elif [ "$f" = "pk" ] || [ "$f" = "sk" ]; then
          mismatch_type="KEYPAIR_DIFF"
        elif [ "$f" = "sm" ] || [ "$f" = "smlen" ]; then
          mismatch_type="SIGNATURE_DIFF_ONLY"
        fi
        break 2
      fi
    done
  done

  if [ -z "$first_count" ]; then
    rh=$(sha256sum "$ref" | awk '{print $1}')
    ah=$(sha256sum "$avx" | awk '{print $1}')
    if [ "$rh" = "$ah" ]; then
      first_count="NA"; first_field="NA"; rlen=0; alen=0; mismatch_type="IDENTICAL"
    else
      first_count="NA"; first_field="NA"; rlen=0; alen=0; mismatch_type="FORMAT_ONLY_DIFF"
    fi
  fi

  exp_pk=2880; exp_sk=960; [ "$p" = "192" ] && exp_pk=3904 && exp_sk=1472; [ "$p" = "256" ] && exp_pk=5184 && exp_sk=1536
  pk0=$(get_field "$ref" 0 pk || true); sk0=$(get_field "$ref" 0 sk || true); sm0=$(get_field "$ref" 0 sm || true); sml0=$(get_field "$ref" 0 smlen || echo 0)
  if [ ${#pk0} -eq 64 ]; then
    echo "ERROR: parsed pk has length 64, which looks like SHA256 digest rather than full KAT field." >> "$OUT_TXT"
    echo "Check that kat-diagnose is reading full NIST KAT output, not hash-vector output." >> "$OUT_TXT"
    mismatch_type="KAT_INPUT_NOT_FULL"
  fi
  {
    echo "profile=sign$p"
    echo "first differing count=$first_count"
    echo "first differing field=$first_field"
    echo "ref field length=$rlen"
    echo "avx2 field length=$alen"
    echo "ref sha256(field)=$rh"
    echo "avx2 sha256(field)=$ah"
    echo "mismatch_type=$mismatch_type"
    echo
  } >> "$OUT_TXT"
  printf 'sign%s,%s,%s,%s,%s,%s,%s,%s\n' "$p" "$first_count" "$first_field" "$rlen" "$alen" "$rh" "$ah" "$mismatch_type" >> "$OUT_CSV"
done
cat "$OUT_TXT"
echo "Probe written to $PROBE"
echo "CSV written to $OUT_CSV"
  {
    echo "==== sign$p ref head ===="; sed -n '1,40p' "$ref";
    echo "==== sign$p avx2 head ===="; sed -n '1,40p' "$avx";
    echo "---- grep pk ref ----"; grep -n -m 3 '^pk[[:space:]]*=' "$ref" || true; grep -n -m 3 '^PK[[:space:]]*=' "$ref" || true; grep -n -m 3 'pk_sha256' "$ref" || true; grep -n -m 3 'sha256' "$ref" || true;
    echo "---- grep pk avx2 ----"; grep -n -m 3 '^pk[[:space:]]*=' "$avx" || true; grep -n -m 3 '^PK[[:space:]]*=' "$avx" || true; grep -n -m 3 'pk_sha256' "$avx" || true; grep -n -m 3 'sha256' "$avx" || true;
  } >> "$PROBE"
