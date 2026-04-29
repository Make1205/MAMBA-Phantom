# MAMBA-Sign Standalone API Submission Package

This folder is the **standalone API submission package for MAMBA-Sign**.

## Package layout
- `Implementations/Reference_Implementation` contains the reference implementation.
- `Implementations/Optimized_Implementation` contains the AVX2 optimized implementation.
- `Implementations/Reference_Implementation/AlgorithmInstance` contains the API template bridge layer for SIG.

## Supported instances
- MAMBA-Sign-128
- MAMBA-Sign-192
- MAMBA-Sign-256
- MAMBA-Sign-384
- MAMBA-Sign-512

Profile sizes (PK/SK/SIG bytes):
- 128: 1440 / 480 / 2420
- 192: 1952 / 736 / 3309
- 256: 2592 / 768 / 4627
- 384: 2592 / 1120 / 5312
- 512: 3232 / 1376 / 6634

> MAMBA-Sign-384 and MAMBA-Sign-512 are **N=256 experimental high-parameter profiles** and do not yet carry final 384-bit or 512-bit security claims.

## Build
```bash
make clean
make
```

## Test
```bash
make test-all-fast
```

## Generate test vectors
```bash
make kat
```

This generates:
- `Test_Vector/MAMBA-Sign-128-ref.txt` ... `Test_Vector/MAMBA-Sign-512-ref.txt`
- `Test_Vector/MAMBA-Sign-128-avx2.txt` ... `Test_Vector/MAMBA-Sign-512-avx2.txt`

These test vectors can be regenerated at any time with `make kat`.

## Template files intentionally left unchanged
The following template files are left unchanged:
- `drng.c`
- `drng.h`
- `auxfunc.c`
- `auxfunc.h`
- `KAT_SIG.c`
- `KAT_KEM.c`
- `KAT_KEX.c`

The optimized implementation uses a scalar-compatible keypair path for deterministic KAT alignment, while signing and verification retain AVX2 optimized paths.
