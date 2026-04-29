#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAX_COUNT=${1:-5}
OUT_TXT="$ROOT/build/mamba_sign_kat_diagnose.txt"
OUT_CSV="$ROOT/build/mamba_sign_kat_diagnose.csv"
mkdir -p "$ROOT/build"
: > "$OUT_TXT"
printf 'profile,first_differing_count,first_differing_field,ref_len,avx2_len,ref_sha256,avx2_sha256,mismatch_type\n' > "$OUT_CSV"

get_field() {
  file="$1"; cnt="$2"; field="$3"
  awk -v c="$cnt" -v f="$field" '
    BEGIN{inblk=0}
    $1=="count" && $2=="=" {inblk=($3==c)}
    inblk && $1==f && $2=="=" {
      sub("^[^=]*= ", "", $0); print; exit
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
echo "CSV written to $OUT_CSV"
