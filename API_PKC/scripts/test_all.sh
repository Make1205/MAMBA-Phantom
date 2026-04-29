#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ITERS=${BENCH_ITERS:-100}
OUT_TXT="$ROOT/build/mamba_sign_test_all.txt"
OUT_CSV="$ROOT/build/mamba_sign_test_all.csv"
TMP="$ROOT/build/testall_tmp"
REF_DIR="$ROOT/Implementations/Reference_Implementation/MAMBA-Sign"
AVX2_DIR="$ROOT/Implementations/Optimized_Implementation/MAMBA-Sign"
mkdir -p "$TMP" "$ROOT/build"
: > "$OUT_TXT"
printf 'implementation,profile,CRYPTO_ALGNAME,N,K,L,TAU,OMEGA,PK bytes,SK bytes,SIG bytes,correctness result,keygen cycles,sign cycles,verify cycles,iterations,timing source\n' > "$OUT_CSV"
fail=0
run_correct(){ impl=$1; profile=$2; bin=$3; if $bin >"$TMP/${impl}_${profile}.out" 2>&1; then c=PASS; else c=FAIL; fail=1; fi; echo "$c"; }
bench_one(){ impl=$1; mode=$2; prof=$3; inc=$4; srcs=$5; out="$TMP/bench_${impl}_${prof}"; cat > "$TMP/bench.c" <<'C'
#include <stdio.h>
#include <stdint.h>
#include "sign.h"
#include "params.h"
#include "randombytes.h"
#include "cpucycles.h"
#ifndef BENCH_ITERS
#define BENCH_ITERS 100
#endif
int main(void){uint8_t pk[CRYPTO_PUBLICKEYBYTES],sk[CRYPTO_SECRETKEYBYTES],m[32],sig[CRYPTO_BYTES];size_t siglen=0;uint64_t a=0,b=0,c=0,t0,t1,ov=cpucycles_overhead();for(int i=0;i<BENCH_ITERS;i++){randombytes(m,sizeof(m));t0=cpucycles();crypto_sign_keypair(pk,sk);t1=cpucycles();a+=t1-t0-ov;t0=cpucycles();crypto_sign_signature(sig,&siglen,m,sizeof(m),NULL,0,sk);t1=cpucycles();b+=t1-t0-ov;t0=cpucycles();crypto_sign_verify(sig,siglen,m,sizeof(m),NULL,0,pk);t1=cpucycles();c+=t1-t0-ov;}printf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%llu,%llu,%llu\n",CRYPTO_ALGNAME,N,K,L,TAU,OMEGA,CRYPTO_PUBLICKEYBYTES,CRYPTO_SECRETKEYBYTES,CRYPTO_BYTES,(unsigned long long)(a/BENCH_ITERS),(unsigned long long)(b/BENCH_ITERS),(unsigned long long)(c/BENCH_ITERS));}
C
  eval "cc -O3 -DDILITHIUM_MODE=$mode -DBENCH_ITERS=$ITERS $inc $TMP/bench.c $srcs -o $out"
  $out
}
for mode_prof in "2 sign128 128" "3 sign192 192" "5 sign256 256" "7 sign384 384" "8 sign512 512"; do
 set -- $mode_prof; mode=$1; prof=$2; label=$3
 cres=$(run_correct ref $prof "./build/kat-sign${label}-ref")
 row=$(bench_one ref $mode $prof "-I$REF_DIR" "$REF_DIR/randombytes.c $REF_DIR/sign.c $REF_DIR/packing.c $REF_DIR/polyvec.c $REF_DIR/poly.c $REF_DIR/ntt.c $REF_DIR/reduce.c $REF_DIR/rounding.c $REF_DIR/fips202.c $REF_DIR/symmetric-shake.c $REF_DIR/cpucycles.c")
 IFS=, read alg n k l tau omg pk sk sig kg sg vf <<EOF2
$row
EOF2
 echo "impl=ref profile=$prof correctness=$cres keygen=$kg sign=$sg verify=$vf" >> "$OUT_TXT"
 printf 'ref,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,cpucycles\n' "$prof" "$alg" "$n" "$k" "$l" "$tau" "$omg" "$pk" "$sk" "$sig" "$cres" "$kg" "$sg" "$vf" "$ITERS" >> "$OUT_CSV"

 cres=$(run_correct avx2 $prof "./build/kat-sign${label}-avx2")
 row=$(bench_one avx2 $mode $prof "-I$AVX2_DIR -mavx2 -mpopcnt -march=native -mtune=native" "$AVX2_DIR/randombytes.c $AVX2_DIR/sign.c $AVX2_DIR/packing.c $AVX2_DIR/polyvec.c $AVX2_DIR/poly.c $AVX2_DIR/ntt.S $AVX2_DIR/invntt.S $AVX2_DIR/pointwise.S $AVX2_DIR/shuffle.S $AVX2_DIR/consts.c $AVX2_DIR/rejsample.c $AVX2_DIR/rounding.c $AVX2_DIR/fips202.c $AVX2_DIR/fips202x4.c $AVX2_DIR/f1600x4.S $AVX2_DIR/symmetric-shake.c $AVX2_DIR/cpucycles.c")
 IFS=, read alg n k l tau omg pk sk sig kg sg vf <<EOF2
$row
EOF2
 echo "impl=avx2 profile=$prof correctness=$cres keygen=$kg sign=$sg verify=$vf" >> "$OUT_TXT"
 printf 'avx2,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,cpucycles\n' "$prof" "$alg" "$n" "$k" "$l" "$tau" "$omg" "$pk" "$sk" "$sig" "$cres" "$kg" "$sg" "$vf" "$ITERS" >> "$OUT_CSV"
done
cat "$OUT_TXT"
echo "CSV written to $OUT_CSV"
if [ $fail -ne 0 ]; then echo "FAILURES detected"; exit 1; fi
