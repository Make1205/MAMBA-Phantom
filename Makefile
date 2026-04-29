.PHONY: clean make-ref test sign128 sign192 sign256 sign384 sign512 kat

clean:
	$(MAKE) -C ref clean

make-ref:
	$(MAKE) -C ref all

# keep default `make` behavior requested by integration scripts
all: make-ref

test: sign128 sign192 sign256 sign384 sign512 kat

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
	./ref/test/vectors128

vectors192: make-ref
	./ref/test/vectors192

vectors256: make-ref
	./ref/test/vectors256
