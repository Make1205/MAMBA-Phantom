# MAMBA-Sign API Submission Package

1. This folder is the standalone API submission package for MAMBA-Sign.
2. `Reference_Implementation` contains the reference implementation.
3. `Optimized_Implementation` contains the AVX2 optimized implementation.
4. Supported instances:
   - MAMBA-Sign-128
   - MAMBA-Sign-192
   - MAMBA-Sign-256
   - MAMBA-Sign-384
   - MAMBA-Sign-512
5. MAMBA-Sign-384 and MAMBA-Sign-512 are N=256 experimental high-parameter profiles and do not yet carry final 384-bit or 512-bit security claims.
6. Build:
   - `make clean`
   - `make`
7. Test:
   - `make test-all-fast`
8. Generate SIG KAT:
   - `make kat`
9. Template files `drng.c/h`, `auxfunc.c/h`, `KAT_SIG.c`, `KAT_KEM.c`, `KAT_KEX.c` are left unchanged.
10. Reference and optimized implementations are functionally compatible. Byte-identical deterministic KAT between ref and optimized is not required in this package.
