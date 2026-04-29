#!/usr/bin/env python3
import os,subprocess,hashlib,tempfile,struct
ROOT=os.path.dirname(os.path.dirname(__file__))
REF=f"{ROOT}/Implementations/Reference_Implementation/MAMBA-Sign"
AVX=f"{ROOT}/Implementations/Optimized_Implementation/MAMBA-Sign"
ALG=f"{ROOT}/Implementations/Reference_Implementation/AlgorithmInstance"
S1=f"{ROOT}/build/keygen_ref_ttrace_s1_before_ntt.bin"

def run(cmd): return subprocess.check_output(cmd,shell=True,text=True)

def build_run(impl):
    idir=REF if impl=='ref' else AVX
    flags='-mavx2 -mpopcnt -march=native -mtune=native' if impl=='avx2' else ''
    c='''#include <stdio.h>\n#include <stdint.h>\n#include <string.h>\n#include "polyvec.h"\n#include "params.h"\nint main(){FILE*f=fopen("'''+S1+'''","rb"); polyvecl s; fread(&s.vec[0].coeffs[0],4,N*L,f); fclose(f); polyvecl a=s; polyvecl_ntt(&a); FILE*o=fopen("build/ntt_'''+impl+'''_ntt.bin","wb"); fwrite(&a.vec[0].coeffs[0],4,N*L,o); fclose(o); polyvecl_invntt_tomont(&a); o=fopen("build/ntt_'''+impl+'''_back.bin","wb"); fwrite(&a.vec[0].coeffs[0],4,N*L,o); fclose(o); return 0;}'''
    fd,tmp=tempfile.mkstemp(suffix='.c'); os.write(fd,c.encode()); os.close(fd)
    srcs=f"{idir}/polyvec.c {idir}/poly.c {idir}/ntt.c {idir}/reduce.c {idir}/rounding.c {idir}/fips202.c {idir}/symmetric-shake.c" if impl=='ref' else f"{idir}/polyvec.c {idir}/poly.c {idir}/ntt.S {idir}/invntt.S {idir}/pointwise.S {idir}/shuffle.S {idir}/consts.c {idir}/rejsample.c {idir}/rounding.c {idir}/fips202.c {idir}/fips202x4.c {idir}/f1600x4.S {idir}/symmetric-shake.c"
    out=tmp+'.bin'
    run(f"cc -O3 -std=c99 -DDILITHIUM_MODE=2 {flags} -I{idir} {tmp} {srcs} -o {out}")
    run(out)

def h(path): return hashlib.sha256(open(path,'rb').read()).hexdigest()

build_run('ref'); build_run('avx2')
# cross
for src,dst,name in [('build/ntt_ref_ntt.bin','ref_ntt_then_avx_back','avx2'),('build/ntt_avx2_ntt.bin','avx_ntt_then_ref_back','ref')]:
    # reuse simple compiled executables not available; skip deep cross by reporting placeholder
    pass

s=open(S1,'rb').read(); hs=hashlib.sha256(s).hexdigest()
rr=h('build/ntt_ref_back.bin'); ar=h('build/ntt_avx2_back.bin')
print(f"s1_before_ntt coeff canonical sha256={hs}")
print(f"s1_ref_ntt domain=NTT layout=ref montgomery=yes sha256={h('build/ntt_ref_ntt.bin')}")
print(f"s1_avx_ntt domain=NTT layout=avx2 montgomery=yes sha256={h('build/ntt_avx2_ntt.bin')}")
print(f"s1_ref_back domain=coeff layout=canonical sha256={rr}")
print(f"s1_avx_back domain=coeff layout=canonical sha256={ar}")
print(f"ref_roundtrip_pass={'YES' if rr==hs else 'NO'}")
print(f"avx2_roundtrip_pass={'YES' if ar==hs else 'NO'}")
print("cross_roundtrip_pass=NOT_IMPLEMENTED")
