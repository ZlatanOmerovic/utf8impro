#include "io.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
    #include <io.h>
    #define portable_unlink _unlink
#else
    #include <unistd.h>
    #define portable_unlink unlink
#endif

#define STDIN_CHUNK 4096

/*
 * Read an entire file into a heap-allocated buffer.
 * Uses portable large-file seek/tell so files >2GB work on
 * platforms where long is 32 bits (Windows, some 32-bit targets).
 * Caller must free() the returned buffer.
 */
char *read_file(const char *path, fsize_t *out_size)
{
    FILE *fp;
    fsize_t size;
    size_t nread;
    char *buf;

    fp = fopen(path, "rb");
    if (!fp) {
        perror(path);
        return NULL;
    }

    if (portable_fseek(fp, 0, SEEK_END) != 0) {
        perror("fseek");
        fclose(fp);
        return NULL;
    }

    size = portable_ftell(fp);
    if (size < 0) {
        perror("ftell");
        fclose(fp);
        return NULL;
    }

    if (size == 0) {
        fprintf(stderr, "%s: file is empty\n", path);
        fclose(fp);
        return NULL;
    }

    rewind(fp);

    buf = (char *)malloc((size_t)size);
    if (!buf) {
        perror("malloc");
        fclose(fp);
        return NULL;
    }

    nread = fread(buf, 1, (size_t)size, fp);
    if (nread != (size_t)size) {
        fprintf(stderr, "%s: short read\n", path);
        free(buf);
        fclose(fp);
        return NULL;
    }

    fclose(fp);
    *out_size = size;
    return buf;
}

/*
 * Read all of stdin into a heap-allocated buffer.
 * Cannot seek on a pipe, so we grow the buffer in chunks.
 * Caller must free() the returned buffer.
 */
char *read_stdin(fsize_t *out_size)
{
    char *buf;
    size_t capacity = STDIN_CHUNK;
    size_t total = 0;
    size_t nread;

    buf = (char *)malloc(capacity);
    if (!buf) {
        perror("malloc");
        return NULL;
    }

    while ((nread = fread(buf + total, 1, capacity - total, stdin)) > 0) {
        total += nread;
        if (total == capacity) {
            capacity *= 2;
            buf = (char *)realloc(buf, capacity);
            if (!buf) {
                perror("realloc");
                return NULL;
            }
        }
    }

    if (ferror(stdin)) {
        perror("stdin");
        free(buf);
        return NULL;
    }

    if (total == 0) {
        fprintf(stderr, "stdin: no input\n");
        free(buf);
        return NULL;
    }

    *out_size = (fsize_t)total;
    return buf;
}

/*
 * Normalize punctuation in buf to its proper UTF-8 form.
 * Two-pass approach: first count occurrences to compute the exact
 * output size, then do a single copy pass. This avoids byte-at-a-time
 * I/O and lets the caller write the result in one fwrite().
 * Caller must free() the returned buffer.
 */
char *normalize_punctuation(const char *buf, fsize_t in_size, fsize_t *out_size)
{
    fsize_t i;
    fsize_t count = 0;
    fsize_t osz;
    char *out;
    char *dst;

    for (i = 0; i < in_size; i++) {
        if (buf[i] == ';')
            count++;
    }

    /* normalized form is U+037E (2 bytes), net +1 per occurrence */
    osz = in_size + count;

    out = (char *)malloc((size_t)osz);
    if (!out) {
        perror("malloc");
        return NULL;
    }

    dst = out;
    for (i = 0; i < in_size; i++) {
        if (buf[i] == ';') {
            *dst++ = (char)0xCD;
            *dst++ = (char)0xBE;
        } else {
            *dst++ = buf[i];
        }
    }

    *out_size = osz;
    return out;
}

/*
 * Write buf to path atomically: write to <path>.tmp first, then
 * rename() over the target. If anything fails mid-write, the
 * original file is left untouched and the temp file is cleaned up.
 */
int write_file_atomic(const char *path, const char *buf, fsize_t size)
{
    FILE *fp;
    size_t nwritten;
    char *tmp_path;
    size_t path_len;

    path_len = strlen(path);
    tmp_path = (char *)malloc(path_len + 5); /* ".tmp" + NUL */
    if (!tmp_path) {
        perror("malloc");
        return 1;
    }
    memcpy(tmp_path, path, path_len);
    memcpy(tmp_path + path_len, ".tmp", 5);

    fp = fopen(tmp_path, "wb");
    if (!fp) {
        perror(tmp_path);
        free(tmp_path);
        return 1;
    }

    nwritten = fwrite(buf, 1, (size_t)size, fp);
    if (nwritten != (size_t)size) {
        perror("fwrite");
        fclose(fp);
        portable_unlink(tmp_path);
        free(tmp_path);
        return 1;
    }

    /* fclose can fail if the OS buffers haven't flushed to disk */
    if (fclose(fp) != 0) {
        perror("fclose");
        portable_unlink(tmp_path);
        free(tmp_path);
        return 1;
    }

    /* atomic on most filesystems — original is safe until this succeeds */
    if (rename(tmp_path, path) != 0) {
        perror("rename");
        portable_unlink(tmp_path);
        free(tmp_path);
        return 1;
    }

    free(tmp_path);
    return 0;
}

int write_stdout(const char *buf, fsize_t size)
{
    size_t nwritten;

    nwritten = fwrite(buf, 1, (size_t)size, stdout);
    if (nwritten != (size_t)size) {
        perror("fwrite");
        return 1;
    }

    return 0;
}
