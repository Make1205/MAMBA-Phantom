#ifndef PARAMS_H
#define PARAMS_H

#include "config.h"

#define SEEDBYTES 32
#define CRHBYTES 64
#define TRBYTES 64
#define RNDBYTES 32
#define Q 8380417
#define D 13
#define ROOT_OF_UNITY 1753

#if DILITHIUM_MODE == 2
#define SIGN_128 1
#define N 256
#define K 4
#define L 4
#define ETA 2
#define TAU 39
#define BETA 78
#define GAMMA1 (1 << 17)
#define GAMMA2 ((Q-1)/88)
#define OMEGA 80
#define CTILDEBYTES 32

#elif DILITHIUM_MODE == 3
#define SIGN_192 1
#define N 256
#define K 6
#define L 5
#define ETA 4
#define TAU 49
#define BETA 196
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 55
#define CTILDEBYTES 48

#elif DILITHIUM_MODE == 5
#define SIGN_256 1
#define N 256
#define K 8
#define L 7
#define ETA 2
#define TAU 60
#define BETA 120
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 75
#define CTILDEBYTES 64

#elif DILITHIUM_MODE == 7
#define SIGN_384 1
#define N 256
#define K 8
#define L 8
#define ETA 4
#define TAU 128
#define BETA 512
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 120
#define CTILDEBYTES 64

#elif DILITHIUM_MODE == 8
#define SIGN_512 1
#define N 256
#define K 10
#define L 10
#define ETA 4
#define TAU 170
#define BETA 680
#define GAMMA1 (1 << 19)
#define GAMMA2 ((Q-1)/32)
#define OMEGA 160
#define CTILDEBYTES 64
#endif

#if DILITHIUM_MODE == 2
#define TPK 11
#elif DILITHIUM_MODE == 3
#define TPK 10
#elif DILITHIUM_MODE == 5
#define TPK 10
#elif DILITHIUM_MODE == 7
#define TPK 10
#elif DILITHIUM_MODE == 8
#define TPK 10
#endif

#define PPK (1 << TPK)
#define POLYTBAR_PACKEDBYTES ((N*TPK)/8)
#define POLYT1_PACKEDBYTES  320
#define POLYT0_PACKEDBYTES  416
#define POLYVECH_PACKEDBYTES (OMEGA + K)

#if GAMMA1 == (1 << 17)
#define POLYZ_PACKEDBYTES   576
#elif GAMMA1 == (1 << 19)
#define POLYZ_PACKEDBYTES   640
#endif

#if GAMMA2 == (Q-1)/88
#define POLYW1_PACKEDBYTES  192
#elif GAMMA2 == (Q-1)/32
#define POLYW1_PACKEDBYTES  128
#endif

#if ETA == 2
#define POLYETA_PACKEDBYTES  96
#elif ETA == 4
#define POLYETA_PACKEDBYTES 128
#endif

#define CRYPTO_PUBLICKEYBYTES (SEEDBYTES + K*POLYTBAR_PACKEDBYTES)
#define CRYPTO_SECRETKEYBYTES (SEEDBYTES + TRBYTES + L*POLYETA_PACKEDBYTES)
#define CRYPTO_BYTES (CTILDEBYTES + L*POLYZ_PACKEDBYTES + POLYVECH_PACKEDBYTES)

#endif
