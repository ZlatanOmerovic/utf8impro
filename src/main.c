/* normalizes unicode punctuation to their proper UTF-8 representations */

#include <stdio.h>
#include <stdlib.h>

#include "io.h"

int main(int argc, char *argv[])
{
    char *input;
    char *output;
    fsize_t in_size;
    fsize_t out_size;
    const char *target;
    int rc;

    if (argc > 3) {
        fprintf(stderr, "usage: %s [input] [output]\n", argv[0]);
        return 1;
    }

    /* read input */
    if (argc < 2) {
        input = read_stdin(&in_size);
    } else {
        input = read_file(argv[1], &in_size);
    }
    if (!input)
        return 1;

    /* transform */
    output = normalize_punctuation(input, in_size, &out_size);
    free(input);
    if (!output)
        return 1;

    /* write output */
    if (argc < 2) {
        rc = write_stdout(output, out_size);
    } else {
        target = (argc == 3) ? argv[2] : argv[1];
        rc = write_file_atomic(target, output, out_size);
    }

    free(output);
    return rc;
}
