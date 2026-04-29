#ifndef CONFIG_H
#define CONFIG_H

//#define DILITHIUM_MODE 2
#define DILITHIUM_RANDOMIZED_SIGNING
//#define USE_RDPMC
//#define DBENCH

#ifndef DILITHIUM_MODE
#define DILITHIUM_MODE 2
#endif

#if DILITHIUM_MODE == 2
#define CRYPTO_ALGNAME "MAMBA-Sign-128"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium2_ref
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium2_ref_##s
#elif DILITHIUM_MODE == 3
#define CRYPTO_ALGNAME "MAMBA-Sign-192"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium3_ref
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium3_ref_##s
#elif DILITHIUM_MODE == 5
#define CRYPTO_ALGNAME "MAMBA-Sign-256"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium5_ref
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium5_ref_##s
#elif DILITHIUM_MODE == 7
#define CRYPTO_ALGNAME "MAMBA-Sign-384"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium7_ref
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium7_ref_##s
#elif DILITHIUM_MODE == 8
#define CRYPTO_ALGNAME "MAMBA-Sign-512"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium8_ref
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium8_ref_##s
#endif

#endif
