#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "drng.h"

extern DRNG_ctx drng_algorithm;

static int first_call_recorded = 0;

void randombytes(uint8_t *out, size_t outlen)
{
    get_random_number(&drng_algorithm, out, outlen * 8);

#ifdef RNG_TRACE_FILE
    if (!first_call_recorded) {
        FILE *fp = fopen(RNG_TRACE_FILE, "wb");
        if (fp != NULL) {
            size_t n = outlen < 32 ? outlen : 32;
            for (size_t i = 0; i < n; i++) {
                fprintf(fp, "%02X", out[i]);
            }
            fprintf(fp, "\n");
            fclose(fp);
        }
        first_call_recorded = 1;
    }
#endif
}
