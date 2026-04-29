#!/usr/bin/env python3
import subprocess, textwrap, tempfile, os, hashlib, json
ROOT=os.path.dirname(os.path.dirname(__file__))
REF=f"{ROOT}/Implementations/Reference_Implementation/MAMBA-Sign"
AVX=f"{ROOT}/Implementations/Optimized_Implementation/MAMBA-Sign"
ALG=f"{ROOT}/Implementations/Reference_Implementation/AlgorithmInstance"

def run(cmd):
    return subprocess.check_output(cmd,shell=True,text=True)

def build_and_run(impl,mode,kind):
    idir=REF if impl=='ref' else AVX
    flags='-mavx2 -mpopcnt -march=native -mtune=native' if impl=='avx2' else ''
    csrc=''
    if kind=='symmetric':
      csrc='''
#include <stdio.h>
#include <stdint.h>
#include "fips202.h"
#include "drng.h"
DRNG_ctx drng_algorithm;
int main(){uint8_t seed[64]={0}; init_random_number(&drng_algorithm,seed,64); uint8_t in[64]; for(int i=0;i<64;i++) in[i]=i; uint8_t o[128]; shake256(o,128,in,64); for(int i=0;i<128;i++) printf("%02X",o[i]); puts(""); return 0;}
'''
    elif kind=='sampling':
      csrc='''
#include <stdio.h>
#include <stdint.h>
#include "poly.h"
#include "drng.h"
DRNG_ctx drng_algorithm;
int main(){uint8_t seed[64]={0}; init_random_number(&drng_algorithm,seed,64); uint8_t rho[32],rp[64]; for(int i=0;i<32;i++) rho[i]=i; for(int i=0;i<64;i++) rp[i]=i+1; poly a,b,c; poly_uniform(&a,rho,0); poly_uniform_eta(&b,rp,0); poly_uniform_gamma1(&c,rp,0); for(int i=0;i<N;i++) printf("%08X", (uint32_t)a.coeffs[i]); puts(""); for(int i=0;i<N;i++) printf("%08X", (uint32_t)b.coeffs[i]); puts(""); for(int i=0;i<N;i++) printf("%08X", (uint32_t)c.coeffs[i]); puts(""); return 0;}
'''
    else:
      csrc='''
#include <stdio.h>
#include <stdint.h>
#include "sign.h"
#include "drng.h"
DRNG_ctx drng_algorithm;
int main(){uint8_t seed[64]={0}; init_random_number(&drng_algorithm,seed,64); uint8_t pk[CRYPTO_PUBLICKEYBYTES],sk[CRYPTO_SECRETKEYBYTES]; crypto_sign_keypair(pk,sk); for(size_t i=0;i<CRYPTO_PUBLICKEYBYTES;i++) printf("%02X",pk[i]); puts(""); for(size_t i=0;i<CRYPTO_SECRETKEYBYTES;i++) printf("%02X",sk[i]); puts(""); return 0;}
'''
    fd,tmp=tempfile.mkstemp(suffix='.c'); os.write(fd,csrc.encode()); os.close(fd)
    out=tmp+'.bin'
    srcs=' '.join([f'{idir}/sign.c',f'{idir}/packing.c',f'{idir}/polyvec.c',f'{idir}/poly.c',f'{idir}/rounding.c',f'{idir}/fips202.c',f'{idir}/symmetric-shake.c',f'{ALG}/drng.c',f'{ALG}/randombytes_bridge.c'])
    if impl=='ref': srcs += f' {idir}/ntt.c {idir}/reduce.c {ALG}/auxfunc.c'
    else: srcs += f' {idir}/ntt.S {idir}/invntt.S {idir}/pointwise.S {idir}/shuffle.S {idir}/consts.c {idir}/rejsample.c {idir}/fips202x4.c {idir}/f1600x4.S {ALG}/auxfunc.c'
    cmd=f"cc -O3 -std=c99 -DDILITHIUM_MODE={mode} {flags} -I{idir} -I{ALG} {tmp} {srcs} -o {out}"
    run(cmd)
    outtxt=run(out).strip().splitlines()
    return outtxt

kind=os.environ['KIND']
mode=int(os.environ.get('MODE','2'))
for impl in ['ref','avx2']:
    lines=build_and_run(impl,mode,kind)
    print(impl)
    for i,l in enumerate(lines):
        h=hashlib.sha256(bytes.fromhex(l)).hexdigest() if all(c in '0123456789ABCDEF' for c in l) else hashlib.sha256(l.encode()).hexdigest()
        print(f"L{i}_sha256={h}")
