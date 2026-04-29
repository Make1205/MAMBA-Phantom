.PHONY: clean make-ref test sign128 sign192 sign256 sign384 sign512 kat \
vectors128 vectors192 vectors256 vectors384 vectors512 \
vectors128-small vectors192-small vectors256-small vectors384-small vectors512-small \
sizes bench avx2 avx2-test avx2-bench avx2-sign128 avx2-sign192 avx2-sign256 avx2-sign384 avx2-sign512 \
vectors128-avx2 vectors192-avx2 vectors256-avx2 cross-check kat-compare all-tests \
kat-diagnose kat-diagnose-full

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

vectors128: make-ref
	@mkdir -p KAT
	./ref/test/vectors128 > KAT/PQCsignKAT_sign128.rsp

vectors192: make-ref
	@mkdir -p KAT
	./ref/test/vectors192 > KAT/PQCsignKAT_sign192.rsp

vectors256: make-ref
	@mkdir -p KAT
	./ref/test/vectors256 > KAT/PQCsignKAT_sign256.rsp

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
	$(MAKE) -C avx2 avx2-sign384
	$(MAKE) -C avx2 avx2-sign512

avx2-bench:
	./scripts/bench_all_avx2.sh

vectors128-avx2: avx2
	@mkdir -p KAT
	./avx2/test/test_vectors2 > KAT/PQCsignKAT_sign128_avx2.rsp

vectors192-avx2: avx2
	@mkdir -p KAT
	./avx2/test/test_vectors3 > KAT/PQCsignKAT_sign192_avx2.rsp

vectors256-avx2: avx2
	@mkdir -p KAT
	./avx2/test/test_vectors5 > KAT/PQCsignKAT_sign256_avx2.rsp

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
