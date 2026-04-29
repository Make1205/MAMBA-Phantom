# MAMBA-Sign API_PKC Submission Package

This directory is the official API_PKC adaptation package for **MAMBA-Sign**.

- Sign is an **MLWQ-Z digital signature algorithm**.
- Sign was previously developed under the working name Phantom.
- Official instances in this package:
  - MAMBA-Sign-128
  - MAMBA-Sign-192
  - MAMBA-Sign-256
  - MAMBA-Sign-384
  - MAMBA-Sign-512
- `Reference_Implementation` contains the ISO C reference implementations.
- `Optimized_Implementation` contains the 64-bit PC optimized implementations.
- `Test_Vectors` contains exactly one official KAT file per instance.
- Official KAT files are generated with official `KAT_SIG.c` and official DRNG.
- Optimized outputs are compared against official reference KAT using byte-level `diff`.
- MAMBA-Sign-384 and MAMBA-Sign-512 currently remain N=256 high-parameter profiles and do not claim final 384-bit/512-bit security.

## Common commands

- Build/clean in each instance directory:
  - `make clean`
  - `make`
  - `./KAT_SIG`
- Top-level official KAT pipeline:
  - `make clean`
  - `make kat`
