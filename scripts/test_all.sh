#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ITERS=${BENCH_ITERS:-100}
OUT_TXT="$ROOT/build/mamba_sign_test_all.txt"
OUT_CSV="$ROOT/build/mamba_sign_test_all.csv"
TMP="$ROOT/build/testall_tmp"
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
#include "test/cpucycles.h"
#ifndef BENCH_ITERS
#define BENCH_ITERS 100
#endif
int main(void){uint8_t pk[CRYPTO_PUBLICKEYBYTES],sk[CRYPTO_SECRETKEYBYTES],m[32],sig[CRYPTO_BYTES];size_t siglen=0;uint64_t a=0,b=0,c=0,t0,t1,ov=cpucycles_overhead();for(int i=0;i<BENCH_ITERS;i++){randombytes(m,sizeof(m));t0=cpucycles();crypto_sign_keypair(pk,sk);t1=cpucycles();a+=t1-t0-ov;t0=cpucycles();crypto_sign_signature(sig,&siglen,m,sizeof(m),NULL,0,sk);t1=cpucycles();b+=t1-t0-ov;t0=cpucycles();crypto_sign_verify(sig,siglen,m,sizeof(m),NULL,0,pk);t1=cpucycles();c+=t1-t0-ov;}printf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%llu,%llu,%llu\n",CRYPTO_ALGNAME,N,K,L,TAU,OMEGA,CRYPTO_PUBLICKEYBYTES,CRYPTO_SECRETKEYBYTES,CRYPTO_BYTES,(unsigned long long)(a/BENCH_ITERS),(unsigned long long)(b/BENCH_ITERS),(unsigned long long)(c/BENCH_ITERS));}
C
  eval "cc -O3 -DDILITHIUM_MODE=$mode -DBENCH_ITERS=$ITERS $inc $TMP/bench.c $srcs -o $out"
  $out
}
for mode_prof in "2 sign128" "3 sign192" "5 sign256" "7 sign384" "8 sign512"; do
 set -- $mode_prof; mode=$1; prof=$2
 cres=$(run_correct ref $prof "./ref/test/${prof}")
 row=$(bench_one ref $mode $prof "-I$ROOT/ref" "$ROOT/ref/randombytes.c $ROOT/ref/sign.c $ROOT/ref/packing.c $ROOT/ref/polyvec.c $ROOT/ref/poly.c $ROOT/ref/ntt.c $ROOT/ref/reduce.c $ROOT/ref/rounding.c $ROOT/ref/fips202.c $ROOT/ref/symmetric-shake.c $ROOT/ref/test/cpucycles.c")
 IFS=, read alg n k l tau omg pk sk sig kg sg vf <<EOF
$row
EOF
 echo "impl=ref profile=$prof correctness=$cres keygen=$kg sign=$sg verify=$vf" >> "$OUT_TXT"
 printf 'ref,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,cpucycles\n' "$prof" "$alg" "$n" "$k" "$l" "$tau" "$omg" "$pk" "$sk" "$sig" "$cres" "$kg" "$sg" "$vf" "$ITERS" >> "$OUT_CSV"

 cres=$(run_correct avx2 $prof "./avx2/test/${prof}_avx2")
 row=$(bench_one avx2 $mode $prof "-I$ROOT/avx2 -mavx2 -mpopcnt -march=native -mtune=native" "$ROOT/avx2/randombytes.c $ROOT/avx2/sign.c $ROOT/avx2/packing.c $ROOT/avx2/polyvec.c $ROOT/avx2/poly.c $ROOT/avx2/ntt.S $ROOT/avx2/invntt.S $ROOT/avx2/pointwise.S $ROOT/avx2/shuffle.S $ROOT/avx2/consts.c $ROOT/avx2/rejsample.c $ROOT/avx2/rounding.c $ROOT/avx2/fips202.c $ROOT/avx2/fips202x4.c $ROOT/avx2/f1600x4.S $ROOT/avx2/symmetric-shake.c $ROOT/avx2/test/cpucycles.c")
 IFS=, read alg n k l tau omg pk sk sig kg sg vf <<EOF
$row
EOF
 echo "impl=avx2 profile=$prof correctness=$cres keygen=$kg sign=$sg verify=$vf" >> "$OUT_TXT"
 printf 'avx2,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,cpucycles\n' "$prof" "$alg" "$n" "$k" "$l" "$tau" "$omg" "$pk" "$sk" "$sig" "$cres" "$kg" "$sg" "$vf" "$ITERS" >> "$OUT_CSV"
done
cat "$OUT_TXT"
echo "CSV written to $OUT_CSV"
if [ $fail -ne 0 ]; then echo "FAILURES detected"; exit 1; fi
