CC ?= cc
ROOT := .
REF_DIR := Implementations/Reference_Implementation/MAMBA-Sign
AVX2_DIR := Implementations/Optimized_Implementation/MAMBA-Sign
ALG_DIR := Implementations/Reference_Implementation/AlgorithmInstance
OUT_DIR := build
VEC_DIR := Test_Vector

REF_SOURCES := $(REF_DIR)/sign.c $(REF_DIR)/packing.c $(REF_DIR)/polyvec.c $(REF_DIR)/poly.c $(REF_DIR)/ntt.c $(REF_DIR)/reduce.c $(REF_DIR)/rounding.c $(REF_DIR)/fips202.c $(REF_DIR)/symmetric-shake.c
AVX2_SOURCES := $(AVX2_DIR)/sign.c $(AVX2_DIR)/packing.c $(AVX2_DIR)/polyvec.c $(AVX2_DIR)/poly.c $(AVX2_DIR)/ntt.S $(AVX2_DIR)/invntt.S $(AVX2_DIR)/pointwise.S $(AVX2_DIR)/shuffle.S $(AVX2_DIR)/consts.c $(AVX2_DIR)/rejsample.c $(AVX2_DIR)/rounding.c $(AVX2_DIR)/fips202.c $(AVX2_DIR)/fips202x4.c $(AVX2_DIR)/f1600x4.S $(AVX2_DIR)/symmetric-shake.c $(AVX2_DIR)/keypair_scalar_compat.c

API_COMMON := $(ALG_DIR)/KAT_SIG.c $(ALG_DIR)/SIG_AlgorithmInstance.c $(ALG_DIR)/drng.c $(ALG_DIR)/auxfunc.c $(ALG_DIR)/randombytes_bridge.c
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


.PHONY: kat-rng-check

build/kat-rngcheck128-ref: $(API_COMMON) $(REF_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) -DRNG_TRACE_FILE=\"build/rng_ref_128.txt\" -I$(ALG_DIR) -I$(REF_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@

build/kat-rngcheck128-avx2: $(API_COMMON) $(AVX2_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) $(AVX2_FLAGS) -DRNG_TRACE_FILE=\"build/rng_avx2_128.txt\" -I$(ALG_DIR) -I$(AVX2_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@

kat-rng-check: build/kat-rngcheck128-ref build/kat-rngcheck128-avx2
	./build/kat-rngcheck128-ref >/dev/null
	mv -f output/KAT_SIG_MAMBA-Sign-128.txt build/KAT_SIG_MAMBA-Sign-128-ref.txt
	./build/kat-rngcheck128-avx2 >/dev/null
	mv -f output/KAT_SIG_MAMBA-Sign-128.txt build/KAT_SIG_MAMBA-Sign-128-avx2.txt
	@echo "[ref]"
	@awk '/Count = 0/{p=1} p&&/Count = 1/{exit} p' build/KAT_SIG_MAMBA-Sign-128-ref.txt | awk '/Count =|Seed =/{print}'
	@echo -n "first32 randombytes(keygen) = "; cat build/rng_ref_128.txt
	@python -c "import hashlib,re; t=open('build/KAT_SIG_MAMBA-Sign-128-ref.txt').read(); b=t.split('Count = 1')[0]; pk=re.search(r'PK = ([0-9A-F]+)',b).group(1); sk=re.search(r'SK = ([0-9A-F]+)',b).group(1); print('PK sha256 =',hashlib.sha256(bytes.fromhex(pk)).hexdigest()); print('SK sha256 =',hashlib.sha256(bytes.fromhex(sk)).hexdigest())"
	@echo "[avx2]"
	@awk '/Count = 0/{p=1} p&&/Count = 1/{exit} p' build/KAT_SIG_MAMBA-Sign-128-avx2.txt | awk '/Count =|Seed =/{print}'
	@echo -n "first32 randombytes(keygen) = "; cat build/rng_avx2_128.txt
	@python -c "import hashlib,re; t=open('build/KAT_SIG_MAMBA-Sign-128-avx2.txt').read(); b=t.split('Count = 1')[0]; pk=re.search(r'PK = ([0-9A-F]+)',b).group(1); sk=re.search(r'SK = ([0-9A-F]+)',b).group(1); print('PK sha256 =',hashlib.sha256(bytes.fromhex(pk)).hexdigest()); print('SK sha256 =',hashlib.sha256(bytes.fromhex(sk)).hexdigest())"

clean:
	rm -rf $(OUT_DIR) output
	rm -f $(VEC_DIR)/MAMBA-Sign-*-ref.txt $(VEC_DIR)/MAMBA-Sign-*-avx2.txt

.PHONY: symmetric-check sampling-check arithmetic-check
symmetric-check:
	KIND=symmetric MODE=2 ./scripts/impl_diag.py
sampling-check:
	KIND=sampling MODE=2 ./scripts/impl_diag.py
arithmetic-check:
	KIND=arithmetic MODE=2 ./scripts/impl_diag.py

.PHONY: keygen-trace-real
build/keygen-trace-ref: $(API_COMMON) $(REF_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) -DDEBUG_KEYGEN_TRACE -DKEYGEN_TRACE_IMPL=\"ref\" -I$(ALG_DIR) -I$(REF_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@
build/keygen-trace-avx2: $(API_COMMON) $(AVX2_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) $(AVX2_FLAGS) -DDEBUG_KEYGEN_TRACE -DKEYGEN_TRACE_IMPL=\"avx2\" -I$(ALG_DIR) -I$(AVX2_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@
keygen-trace-real: build/keygen-trace-ref build/keygen-trace-avx2
	./build/keygen-trace-ref >/dev/null
	./build/keygen-trace-avx2 >/dev/null
	./scripts/keygen_trace_real.py

.PHONY: t-trace-real
build/t-trace-ref: $(API_COMMON) $(REF_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) -DDEBUG_T_TRACE -DKEYGEN_TRACE_IMPL=\"ref\" -I$(ALG_DIR) -I$(REF_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@
build/t-trace-avx2: $(API_COMMON) $(AVX2_SOURCES) | build
	$(CC) $(CFLAGS_COMMON) $(AVX2_FLAGS) -DDEBUG_T_TRACE -DKEYGEN_TRACE_IMPL=\"avx2\" -I$(ALG_DIR) -I$(AVX2_DIR) -DDILITHIUM_MODE=2 -DMAMBA_PROFILE=128 $^ -o $@
t-trace-real: build/t-trace-ref build/t-trace-avx2
	./build/t-trace-ref >/dev/null
	./build/t-trace-avx2 >/dev/null
	./scripts/t_trace_real.py

.PHONY: ntt-equivalence-check
ntt-equivalence-check: build/t-trace-ref build/t-trace-avx2
	./build/t-trace-ref >/dev/null
	./build/t-trace-avx2 >/dev/null
	./scripts/ntt_equiv_check.py | tee build/mamba_sign_ntt_equivalence_check.txt
