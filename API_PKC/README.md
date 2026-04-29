# MAMBA-Sign API Submission Package

This folder is the standalone API submission package for MAMBA-Sign.

- `Reference_Implementation` contains the reference implementation.
- `Optimized_Implementation` contains the AVX2 optimized implementation.

Supported instances:
- MAMBA-Sign-128
- MAMBA-Sign-192
- MAMBA-Sign-256
- MAMBA-Sign-384
- MAMBA-Sign-512

MAMBA-Sign-384 and MAMBA-Sign-512 are N=256 experimental high-parameter profiles and do not yet carry final 384-bit or 512-bit security claims.

Build:
- `make clean`
- `make`

Test:
- `make test-all-fast`

Generate SIG KAT:
- `make kat`

Template files `drng.c/h`, `auxfunc.c/h`, `KAT_SIG.c`, `KAT_KEM.c`, `KAT_KEX.c` are left unchanged.

Reference and optimized implementations are functionally compatible. Byte-identical deterministic KAT between ref and optimized is not required in this package.
