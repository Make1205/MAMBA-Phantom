CC ?= cc
CFLAGS = -Wall -Wextra -Wpedantic -O3

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
	src/ntt.c \
	src/reduce.c \
	src/rounding.c \
	src/fips202.c \
	src/symmetric-shake.c

all: KAT_SIG

KAT_SIG: $(SRC)
	$(CC) $(CFLAGS) -I. -Isrc -DDILITHIUM_MODE=2 -o $@ $(SRC)

kat: KAT_SIG
	./KAT_SIG

clean:
	rm -f KAT_SIG *.o
	rm -rf output
