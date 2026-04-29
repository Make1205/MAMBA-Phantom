.PHONY: clean make-ref test sign128 sign192 sign256 sign384 sign512 kat \
vectors128 vectors192 vectors256 vectors384 vectors512 \
vectors128-small vectors192-small vectors256-small vectors384-small vectors512-small \
sizes bench avx2 avx2-test avx2-bench avx2-sign128 avx2-sign192 avx2-sign256 avx2-sign384 avx2-sign512 \
vectors128-avx2 vectors192-avx2 vectors256-avx2 cross-check kat-compare all-tests \
kat-diagnose kat-diagnose-full \
keygen-trace \
kat128 kat192 kat256 kat128-avx2 kat192-avx2 kat256-avx2 \
hash-vectors128 hash-vectors192 hash-vectors256

clean:
	$(MAKE) -C ref clean

make-ref:
	$(MAKE) -C ref all

# keep default `make` behavior requested by integration scripts
all: make-ref

test: sign128 sign192 sign256 sign384 sign512

sign128: make-ref
	./ref/test/sign128

sign192: make-ref
	./ref/test/sign192

sign256: make-ref
	./ref/test/sign256

sign384:
	./ref/test/sign384

sign512:
	./ref/test/sign512

kat:
	$(MAKE) -C ref nistkat
	./ref/nistkat/PQCgenKAT_sign128
	./ref/nistkat/PQCgenKAT_sign192
	./ref/nistkat/PQCgenKAT_sign256

hash-vectors128: make-ref
	@mkdir -p KAT/hash
	./ref/test/vectors128 > KAT/hash/hash_vectors_sign128.txt

hash-vectors192: make-ref
	@mkdir -p KAT/hash
	./ref/test/vectors192 > KAT/hash/hash_vectors_sign192.txt

hash-vectors256: make-ref
	@mkdir -p KAT/hash
	./ref/test/vectors256 > KAT/hash/hash_vectors_sign256.txt

vectors128: kat128
vectors192: kat192
vectors256: kat256

vectors384: make-ref
	@mkdir -p KAT
	./ref/test/vectors384 > KAT/PQCsignKAT_sign384.rsp

vectors512: make-ref
	@mkdir -p KAT
	./ref/test/vectors512 > KAT/PQCsignKAT_sign512.rsp

vectors128-small: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign128_small
	./ref/nistkat/PQCgenKAT_sign128_small
	mv -f PQCsignKAT_MAMBA-Sign-128.rsp KAT/PQCsignKAT_sign128_small.rsp
	mv -f PQCsignKAT_MAMBA-Sign-128.req KAT/PQCsignKAT_sign128_small.req

vectors192-small: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign192_small
	./ref/nistkat/PQCgenKAT_sign192_small
	mv -f PQCsignKAT_MAMBA-Sign-192.rsp KAT/PQCsignKAT_sign192_small.rsp
	mv -f PQCsignKAT_MAMBA-Sign-192.req KAT/PQCsignKAT_sign192_small.req

vectors256-small: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign256_small
	./ref/nistkat/PQCgenKAT_sign256_small
	mv -f PQCsignKAT_MAMBA-Sign-256.rsp KAT/PQCsignKAT_sign256_small.rsp
	mv -f PQCsignKAT_MAMBA-Sign-256.req KAT/PQCsignKAT_sign256_small.req

vectors384-small: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign384_small
	./ref/nistkat/PQCgenKAT_sign384_small
	mv -f PQCsignKAT_MAMBA-Sign-384.rsp KAT/PQCsignKAT_sign384_small.rsp
	mv -f PQCsignKAT_MAMBA-Sign-384.req KAT/PQCsignKAT_sign384_small.req

vectors512-small: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign512_small
	./ref/nistkat/PQCgenKAT_sign512_small
	mv -f PQCsignKAT_MAMBA-Sign-512.rsp KAT/PQCsignKAT_sign512_small.rsp
	mv -f PQCsignKAT_MAMBA-Sign-512.req KAT/PQCsignKAT_sign512_small.req

sizes: make-ref
	./scripts/collect_sizes.sh

bench: make-ref
	./scripts/bench_all.sh

avx2:
	$(MAKE) -C avx2 all

avx2-sign128:
	$(MAKE) -C avx2 avx2-sign128

avx2-sign192:
	$(MAKE) -C avx2 avx2-sign192

avx2-sign256:
	$(MAKE) -C avx2 avx2-sign256

avx2-sign384:
	$(MAKE) -C avx2 avx2-sign384

avx2-sign512:
	$(MAKE) -C avx2 avx2-sign512

avx2-test:
	$(MAKE) -C avx2 test

avx2-bench:
	./scripts/bench_all_avx2.sh

kat128: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign128
	./ref/nistkat/PQCgenKAT_sign128
	mv -f PQCsignKAT_MAMBA-Sign-128.rsp KAT/PQCsignKAT_sign128.rsp

kat192: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign192
	./ref/nistkat/PQCgenKAT_sign192
	mv -f PQCsignKAT_MAMBA-Sign-192.rsp KAT/PQCsignKAT_sign192.rsp

kat256: make-ref
	@mkdir -p KAT
	$(MAKE) -C ref nistkat/PQCgenKAT_sign256
	./ref/nistkat/PQCgenKAT_sign256
	mv -f PQCsignKAT_MAMBA-Sign-256.rsp KAT/PQCsignKAT_sign256.rsp

kat128-avx2: avx2
	@mkdir -p KAT build
	cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -Iavx2 -Iref/nistkat -DDILITHIUM_MODE=2 scripts/PQCgenKAT_sign_generic.c ref/nistkat/rng.c avx2/sign.c avx2/packing.c avx2/polyvec.c avx2/poly.c avx2/ntt.S avx2/invntt.S avx2/pointwise.S avx2/shuffle.S avx2/consts.c avx2/rejsample.c avx2/rounding.c avx2/fips202.c avx2/fips202x4.c avx2/f1600x4.S avx2/symmetric-shake.c -lcrypto -o build/PQCgenKAT_sign128_avx2
	./build/PQCgenKAT_sign128_avx2
	mv -f PQCsignKAT_MAMBA-Sign-128.rsp KAT/PQCsignKAT_sign128_avx2.rsp

kat192-avx2: avx2
	@mkdir -p KAT build
	cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -Iavx2 -Iref/nistkat -DDILITHIUM_MODE=3 scripts/PQCgenKAT_sign_generic.c ref/nistkat/rng.c avx2/sign.c avx2/packing.c avx2/polyvec.c avx2/poly.c avx2/ntt.S avx2/invntt.S avx2/pointwise.S avx2/shuffle.S avx2/consts.c avx2/rejsample.c avx2/rounding.c avx2/fips202.c avx2/fips202x4.c avx2/f1600x4.S avx2/symmetric-shake.c -lcrypto -o build/PQCgenKAT_sign192_avx2
	./build/PQCgenKAT_sign192_avx2
	mv -f PQCsignKAT_MAMBA-Sign-192.rsp KAT/PQCsignKAT_sign192_avx2.rsp

kat256-avx2: avx2
	@mkdir -p KAT build
	cc -O3 -mavx2 -mpopcnt -march=native -mtune=native -Iavx2 -Iref/nistkat -DDILITHIUM_MODE=5 scripts/PQCgenKAT_sign_generic.c ref/nistkat/rng.c avx2/sign.c avx2/packing.c avx2/polyvec.c avx2/poly.c avx2/ntt.S avx2/invntt.S avx2/pointwise.S avx2/shuffle.S avx2/consts.c avx2/rejsample.c avx2/rounding.c avx2/fips202.c avx2/fips202x4.c avx2/f1600x4.S avx2/symmetric-shake.c -lcrypto -o build/PQCgenKAT_sign256_avx2
	./build/PQCgenKAT_sign256_avx2
	mv -f PQCsignKAT_MAMBA-Sign-256.rsp KAT/PQCsignKAT_sign256_avx2.rsp

vectors128-avx2: kat128-avx2
vectors192-avx2: kat192-avx2
vectors256-avx2: kat256-avx2

cross-check:
	./scripts/cross_check_ref_avx2.sh

kat-compare:
	./scripts/kat_compare_ref_avx2.sh

kat-diagnose:
	$(MAKE) vectors128
	$(MAKE) vectors192
	$(MAKE) vectors256
	$(MAKE) vectors128-avx2
	$(MAKE) vectors192-avx2
	$(MAKE) vectors256-avx2
	./scripts/diagnose_kat_diff.sh 5
	./scripts/seed_locked_diag.sh

kat-diagnose-full:
	$(MAKE) vectors128
	$(MAKE) vectors192
	$(MAKE) vectors256
	$(MAKE) vectors128-avx2
	$(MAKE) vectors192-avx2
	$(MAKE) vectors256-avx2
	./scripts/diagnose_kat_diff.sh 100
	./scripts/seed_locked_diag.sh

keygen-trace:
	./scripts/keygen_trace.sh

stress-test:
	./scripts/stress_test.sh

test-all-fast: make-ref avx2
	./scripts/test_all.sh

all-tests:
	$(MAKE) test
	$(MAKE) sizes
	$(MAKE) bench
	$(MAKE) avx2-test
	$(MAKE) avx2-bench
	$(MAKE) cross-check
	$(MAKE) vectors128-small
	$(MAKE) vectors192-small
	$(MAKE) vectors256-small
	$(MAKE) vectors384-small
	$(MAKE) vectors512-small
