CC ?= cc
CFLAGS = -Wall -Wextra -Wpedantic -O3 -mavx2 -maes -msse2 -mssse3

SRC = \
	KAT_SIG.c \
	SIG_AlgorithmInstance.c \
	drng.c \
	auxfunc.c \
	randombytes_bridge.c \
	src/sign.c \
	src/packing.c \
	src/polyvec.c \
	src/poly.c \
	src/ntt.S \
	src/invntt.S \
	src/pointwise.S \
	src/shuffle.S \
	src/consts.c \
	src/rejsample.c \
	src/rounding.c \
	src/fips202.c \
	src/fips202x4.c \
	src/f1600x4.S \
	src/symmetric-shake.c

all: KAT_SIG

KAT_SIG: $(SRC)
	$(CC) $(CFLAGS) -I. -Isrc -DDILITHIUM_MODE=8 -o $@ $(SRC)

kat: KAT_SIG
	./KAT_SIG

clean:
	rm -f KAT_SIG *.o
	rm -rf output
