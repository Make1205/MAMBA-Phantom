.PHONY: clean make-ref test sign128 sign192 sign256 sign384 sign512 kat \
vectors128 vectors192 vectors256 vectors384 vectors512 \
vectors128-small vectors192-small vectors256-small vectors384-small vectors512-small \
sizes bench

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
