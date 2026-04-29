.PHONY: clean make-ref test sign128 sign192 sign256 sign384 sign512 kat \
vectors128 vectors192 vectors256 vectors384 vectors512

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
