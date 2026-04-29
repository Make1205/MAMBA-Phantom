# MAMBA-Sign API Submission Package (API_PKC)

This directory is the official API-style submission package for **MAMBA-Sign**.

## Mapping to current repository
- `Implementations/Reference_Implementation` maps to the current `ref` implementation.
- `Implementations/Optimized_Implementation` maps to the current `avx2` implementation.

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

> Note: Sign-384 and Sign-512 currently remain **N=256 experimental high-parameter profiles** and are not claimed as final 384-bit/512-bit security levels.

## Build and KAT generation
From `API_PKC/`:

```bash
make clean
make
make kat
```

Optional per-target KAT commands:

```bash
make kat-sign128-ref
make kat-sign192-ref
make kat-sign256-ref
make kat-sign384-ref
make kat-sign512-ref

make kat-sign128-avx2
make kat-sign192-avx2
make kat-sign256-avx2
make kat-sign384-avx2
make kat-sign512-avx2
```

KAT output files are generated under:
- `Test_Vector/MAMBA-Sign-128-ref.txt` ... `Test_Vector/MAMBA-Sign-512-ref.txt`
- `Test_Vector/MAMBA-Sign-128-avx2.txt` ... `Test_Vector/MAMBA-Sign-512-avx2.txt`

## Template files intentionally left unmodified
The following template files are kept unchanged as required:
- `drng.c`
- `drng.h`
- `auxfunc.c`
- `auxfunc.h`
- `KAT_SIG.c`
- `KAT_KEM.c`
- `KAT_KEX.c`

## Integration note
`SIG_AlgorithmInstance.c/.h` bridge template API functions to the existing MAMBA-Sign signing API (`crypto_sign_keypair`, `crypto_sign_signature`, `crypto_sign_verify`) without changing core signing logic or algorithm parameters.
