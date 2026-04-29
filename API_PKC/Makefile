CC ?= cc
CFLAGS_COMMON = -Wall -Wextra -Wpedantic -O3
BUILD_DIR = build
ALG_DIR = Implementations/Reference_Implementation/AlgorithmInstance
REF_DIR = Implementations/Reference_Implementation/MAMBA-Sign

REF_SRC = $(REF_DIR)/sign.c $(REF_DIR)/packing.c $(REF_DIR)/polyvec.c $(REF_DIR)/poly.c $(REF_DIR)/ntt.c $(REF_DIR)/reduce.c $(REF_DIR)/rounding.c $(REF_DIR)/fips202.c $(REF_DIR)/symmetric-shake.c
API_COMMON = $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c $(ALG_DIR)/randombytes_bridge.c

.PHONY: clean make kat-sign128-ref kat-sign512-ref

make: kat-sign128-ref

clean:
	rm -rf $(BUILD_DIR)
	rm -f Test_Vector/*.txt Test_Vector/*.rsp Test_Vector/*.req

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/kat-sign%-ref: $(ALG_DIR)/KAT_SIG.c $(API_COMMON) $(REF_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) -I$(ALG_DIR) -I$(REF_DIR) -DALGORITHM_INSTANCE='"MAMBA-Sign-$*"' -DDILITHIUM_MODE=$(if $(filter $*,128),2,$(if $(filter $*,192),3,$(if $(filter $*,256),5,$(if $(filter $*,384),7,8)))) -o $@ $^

kat-sign128-ref: $(BUILD_DIR)/kat-sign128-ref
	./$<

kat-sign512-ref: $(BUILD_DIR)/kat-sign512-ref
	./$<
