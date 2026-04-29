CC ?= cc
ROOT := .
REF_DIR := Implementations/Reference_Implementation/MAMBA-Sign
AVX2_DIR := Implementations/Optimized_Implementation/MAMBA-Sign
ALG_DIR := Implementations/Reference_Implementation/AlgorithmInstance
OUT_DIR := build
VEC_DIR := Test_Vector

REF_SOURCES := $(REF_DIR)/sign.c $(REF_DIR)/packing.c $(REF_DIR)/polyvec.c $(REF_DIR)/poly.c $(REF_DIR)/ntt.c $(REF_DIR)/reduce.c $(REF_DIR)/rounding.c $(REF_DIR)/fips202.c $(REF_DIR)/symmetric-shake.c $(REF_DIR)/randombytes.c
AVX2_SOURCES := $(AVX2_DIR)/sign.c $(AVX2_DIR)/packing.c $(AVX2_DIR)/polyvec.c $(AVX2_DIR)/poly.c $(AVX2_DIR)/ntt.S $(AVX2_DIR)/invntt.S $(AVX2_DIR)/pointwise.S $(AVX2_DIR)/shuffle.S $(AVX2_DIR)/consts.c $(AVX2_DIR)/rejsample.c $(AVX2_DIR)/rounding.c $(AVX2_DIR)/fips202.c $(AVX2_DIR)/fips202x4.c $(AVX2_DIR)/f1600x4.S $(AVX2_DIR)/symmetric-shake.c $(AVX2_DIR)/randombytes.c

API_COMMON := $(ALG_DIR)/KAT_SIG.c $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c
CFLAGS_COMMON := -std=c99 -O3 -Wall -Wextra -Wno-unused-parameter
AVX2_FLAGS := -mavx2 -mpopcnt -march=native -mtune=native

.PHONY: all clean kat test-all-fast \
kat-sign128-ref kat-sign192-ref kat-sign256-ref kat-sign384-ref kat-sign512-ref \
kat-sign128-avx2 kat-sign192-avx2 kat-sign256-avx2 kat-sign384-avx2 kat-sign512-avx2

all: build/kat-sign128-ref build/kat-sign192-ref build/kat-sign256-ref build/kat-sign384-ref build/kat-sign512-ref \
     build/kat-sign128-avx2 build/kat-sign192-avx2 build/kat-sign256-avx2 build/kat-sign384-avx2 build/kat-sign512-avx2

build:
	mkdir -p $(OUT_DIR) $(VEC_DIR)

build/kat-sign%-ref: $(API_COMMON) $(REF_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) -I$(ALG_DIR) -I$(REF_DIR) -DDILITHIUM_MODE=$(if $(filter 128,$*),2,$(if $(filter 192,$*),3,$(if $(filter 256,$*),5,$(if $(filter 384,$*),7,8)))) -DMAMBA_PROFILE=$* $^ -o $@

build/kat-sign%-avx2: $(API_COMMON) $(AVX2_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) $(AVX2_FLAGS) -I$(ALG_DIR) -I$(AVX2_DIR) -DDILITHIUM_MODE=$(if $(filter 128,$*),2,$(if $(filter 192,$*),3,$(if $(filter 256,$*),5,$(if $(filter 384,$*),7,8)))) -DMAMBA_PROFILE=$* $^ -o $@

kat: kat-sign128-ref kat-sign192-ref kat-sign256-ref kat-sign384-ref kat-sign512-ref kat-sign128-avx2 kat-sign192-avx2 kat-sign256-avx2 kat-sign384-avx2 kat-sign512-avx2

test-all-fast: all
	./scripts/test_all.sh

kat-sign128-ref: build/kat-sign128-ref
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-128.txt $(VEC_DIR)/MAMBA-Sign-128-ref.txt
kat-sign192-ref: build/kat-sign192-ref
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-192.txt $(VEC_DIR)/MAMBA-Sign-192-ref.txt
kat-sign256-ref: build/kat-sign256-ref
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-256.txt $(VEC_DIR)/MAMBA-Sign-256-ref.txt
kat-sign384-ref: build/kat-sign384-ref
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-384.txt $(VEC_DIR)/MAMBA-Sign-384-ref.txt
kat-sign512-ref: build/kat-sign512-ref
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-512.txt $(VEC_DIR)/MAMBA-Sign-512-ref.txt

kat-sign128-avx2: build/kat-sign128-avx2
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-128.txt $(VEC_DIR)/MAMBA-Sign-128-avx2.txt
kat-sign192-avx2: build/kat-sign192-avx2
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-192.txt $(VEC_DIR)/MAMBA-Sign-192-avx2.txt
kat-sign256-avx2: build/kat-sign256-avx2
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-256.txt $(VEC_DIR)/MAMBA-Sign-256-avx2.txt
kat-sign384-avx2: build/kat-sign384-avx2
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-384.txt $(VEC_DIR)/MAMBA-Sign-384-avx2.txt
kat-sign512-avx2: build/kat-sign512-avx2
	./$< && mv -f output/KAT_SIG_MAMBA-Sign-512.txt $(VEC_DIR)/MAMBA-Sign-512-avx2.txt

clean:
	rm -rf $(OUT_DIR) output
	rm -f $(VEC_DIR)/MAMBA-Sign-*-ref.txt $(VEC_DIR)/MAMBA-Sign-*-avx2.txt
