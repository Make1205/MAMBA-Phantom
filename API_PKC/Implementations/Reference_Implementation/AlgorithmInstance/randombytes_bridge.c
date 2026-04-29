#include "drng.h"

extern DRNG_ctx drng_algorithm;

void randombytes(unsigned char *out, unsigned long long outlen)
{
    get_random_number(&drng_algorithm, out, (unsigned int)(outlen * 8ULL));
}
