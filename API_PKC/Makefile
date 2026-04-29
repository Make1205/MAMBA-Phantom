CC ?= cc
CFLAGS_COMMON = -Wall -Wextra -Wpedantic -O3
CFLAGS_AVX2 = -mavx2 -mpopcnt -maes -msse2 -mssse3
BUILD_DIR = build
ALG_DIR = Implementations/Reference_Implementation/AlgorithmInstance
REF_DIR = Implementations/Reference_Implementation/MAMBA-Sign
OPT_DIR = Implementations/Optimized_Implementation/MAMBA-Sign

REF_SRC = $(REF_DIR)/sign.c $(REF_DIR)/packing.c $(REF_DIR)/polyvec.c $(REF_DIR)/poly.c $(REF_DIR)/ntt.c $(REF_DIR)/reduce.c $(REF_DIR)/rounding.c $(REF_DIR)/fips202.c $(REF_DIR)/symmetric-shake.c
OPT_SRC = $(OPT_DIR)/sign.c $(OPT_DIR)/packing.c $(OPT_DIR)/polyvec.c $(OPT_DIR)/poly.c $(OPT_DIR)/ntt.S $(OPT_DIR)/invntt.S $(OPT_DIR)/pointwise.S $(OPT_DIR)/shuffle.S $(OPT_DIR)/consts.c $(OPT_DIR)/rejsample.c $(OPT_DIR)/rounding.c $(OPT_DIR)/fips202.c $(OPT_DIR)/fips202x4.c $(OPT_DIR)/f1600x4.S $(OPT_DIR)/symmetric-shake.c
API_COMMON_REF = $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c $(ALG_DIR)/randombytes_bridge.c
API_COMMON_AVX2 = $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c $(OPT_DIR)/randombytes_bridge.c

.PHONY: clean make kat-sign128-ref kat-sign512-ref kat-sign128-avx2 kat-sign512-avx2

make: kat-sign128-ref

clean:
	rm -rf $(BUILD_DIR)
	rm -f Test_Vector/*.txt Test_Vector/*.rsp Test_Vector/*.req

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/kat-sign%-ref: $(ALG_DIR)/KAT_SIG.c $(API_COMMON_REF) $(REF_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) -I$(ALG_DIR) -I$(REF_DIR) -DALGORITHM_INSTANCE='"MAMBA-Sign-$*"' -DDILITHIUM_MODE=$(if $(filter $*,128),2,$(if $(filter $*,192),3,$(if $(filter $*,256),5,$(if $(filter $*,384),7,8)))) -o $@ $^

$(BUILD_DIR)/kat-sign%-avx2: $(ALG_DIR)/KAT_SIG.c $(API_COMMON_AVX2) $(OPT_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) $(CFLAGS_AVX2) -I$(ALG_DIR) -I$(OPT_DIR) -DALGORITHM_INSTANCE='"MAMBA-Sign-$*"' -DDILITHIUM_MODE=$(if $(filter $*,128),2,$(if $(filter $*,192),3,$(if $(filter $*,256),5,$(if $(filter $*,384),7,8)))) -o $@ $^

kat-sign128-ref: $(BUILD_DIR)/kat-sign128-ref
	./$<

kat-sign512-ref: $(BUILD_DIR)/kat-sign512-ref
	./$<

kat-sign128-avx2: $(BUILD_DIR)/kat-sign128-avx2
	./$<

kat-sign512-avx2: $(BUILD_DIR)/kat-sign512-avx2
	./$<
