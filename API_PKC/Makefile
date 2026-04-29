CC ?= cc
CFLAGS_COMMON = -Wall -Wextra -Wpedantic -O3
CFLAGS_AVX2 = -mavx2 -mpopcnt -march=native -mtune=native
BUILD_DIR = build
ALG_DIR = Implementations/Reference_Implementation/AlgorithmInstance
REF_DIR = Implementations/Reference_Implementation/MAMBA-Sign
OPT_DIR = Implementations/Optimized_Implementation/MAMBA-Sign

MODES = 2 3 5 7 8
MODE_NAMES = 128 192 256 384 512

REF_SRC = $(REF_DIR)/sign.c $(REF_DIR)/packing.c $(REF_DIR)/polyvec.c $(REF_DIR)/poly.c $(REF_DIR)/ntt.c $(REF_DIR)/reduce.c $(REF_DIR)/rounding.c $(REF_DIR)/fips202.c $(REF_DIR)/symmetric-shake.c
AVX2_SRC = $(OPT_DIR)/sign.c $(OPT_DIR)/packing.c $(OPT_DIR)/polyvec.c $(OPT_DIR)/poly.c $(OPT_DIR)/ntt.S $(OPT_DIR)/invntt.S $(OPT_DIR)/pointwise.S $(OPT_DIR)/shuffle.S $(OPT_DIR)/consts.c $(OPT_DIR)/rejsample.c $(OPT_DIR)/rounding.c $(OPT_DIR)/fips202.c $(OPT_DIR)/fips202x4.c $(OPT_DIR)/f1600x4.S $(OPT_DIR)/symmetric-shake.c
API_COMMON = $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c $(ALG_DIR)/randombytes_bridge.c

.PHONY: all clean kat test-all-fast \
  kat-sign128-ref kat-sign192-ref kat-sign256-ref kat-sign384-ref kat-sign512-ref \
  kat-sign128-avx2 kat-sign192-avx2 kat-sign256-avx2 kat-sign384-avx2 kat-sign512-avx2

all: $(BUILD_DIR)/kat-sign128-ref $(BUILD_DIR)/kat-sign128-avx2

clean:
	rm -rf $(BUILD_DIR)
	rm -f Test_Vector/*.txt Test_Vector/*.rsp Test_Vector/*.req

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/kat-sign%-ref: $(ALG_DIR)/KAT_SIG.c $(API_COMMON) $(REF_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) -I$(ALG_DIR) -I$(REF_DIR) -DALGORITHM_INSTANCE='"MAMBA-Sign-$*"' -DDILITHIUM_MODE=$(if $(filter $*,128),2,$(if $(filter $*,192),3,$(if $(filter $*,256),5,$(if $(filter $*,384),7,8)))) -o $@ $^

$(BUILD_DIR)/kat-sign%-avx2: $(ALG_DIR)/KAT_SIG.c $(API_COMMON) $(AVX2_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) $(CFLAGS_AVX2) -I$(ALG_DIR) -I$(OPT_DIR) -DALGORITHM_INSTANCE='"MAMBA-Sign-$*"' -DDILITHIUM_MODE=$(if $(filter $*,128),2,$(if $(filter $*,192),3,$(if $(filter $*,256),5,$(if $(filter $*,384),7,8)))) -o $@ $^

kat-sign128-ref: $(BUILD_DIR)/kat-sign128-ref
	./$<
kat-sign192-ref: $(BUILD_DIR)/kat-sign192-ref
	./$<
kat-sign256-ref: $(BUILD_DIR)/kat-sign256-ref
	./$<
kat-sign384-ref: $(BUILD_DIR)/kat-sign384-ref
	./$<
kat-sign512-ref: $(BUILD_DIR)/kat-sign512-ref
	./$<

kat-sign128-avx2: $(BUILD_DIR)/kat-sign128-avx2
	./$<
kat-sign192-avx2: $(BUILD_DIR)/kat-sign192-avx2
	./$<
kat-sign256-avx2: $(BUILD_DIR)/kat-sign256-avx2
	./$<
kat-sign384-avx2: $(BUILD_DIR)/kat-sign384-avx2
	./$<
kat-sign512-avx2: $(BUILD_DIR)/kat-sign512-avx2
	./$<

kat: kat-sign128-ref kat-sign192-ref kat-sign256-ref kat-sign384-ref kat-sign512-ref \
     kat-sign128-avx2 kat-sign192-avx2 kat-sign256-avx2 kat-sign384-avx2 kat-sign512-avx2

test-all-fast: | $(BUILD_DIR)
	bash -c 'set -e; out=$(BUILD_DIR)/mamba_sign_test_all.txt; csv=$(BUILD_DIR)/mamba_sign_test_all.csv; : > $$out; echo "impl,profile,stage,status" > $$csv; \
	for impl in ref avx2; do \
	 for p in 128 192 256 384 512; do \
	   bin=$(BUILD_DIR)/kat-sign$$p-$$impl; $(MAKE) $$bin >/dev/null; \
	   echo "== $$impl $$p ==" | tee -a $$out; \
	   if ./$$bin >> $$out 2>&1; then s=PASS; else s=FAIL; fi; \
	   echo "$$impl,$$p,kat,$$s" >> $$csv; \
	 done; \
	done'
