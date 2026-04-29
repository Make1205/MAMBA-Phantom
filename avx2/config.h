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
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium2_avx2
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium2_avx2_##s
#elif DILITHIUM_MODE == 3
#define CRYPTO_ALGNAME "MAMBA-Sign-192"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium3_avx2
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium3_avx2_##s
#elif DILITHIUM_MODE == 5
#define CRYPTO_ALGNAME "MAMBA-Sign-256"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium5_avx2
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium5_avx2_##s
#elif DILITHIUM_MODE == 7
#define CRYPTO_ALGNAME "MAMBA-Sign-384"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium7_avx2
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium7_avx2_##s
#elif DILITHIUM_MODE == 8
#define CRYPTO_ALGNAME "MAMBA-Sign-512"
#define DILITHIUM_NAMESPACETOP pqcrystals_dilithium8_avx2
#define DILITHIUM_NAMESPACE(s) pqcrystals_dilithium8_avx2_##s
#endif

#endif
