#ifndef IO_H
#define IO_H

#include <stdio.h>

/*
 * Portable large-file seek/tell.
 * - MSVC: _fseeki64 / _ftelli64 with __int64
 * - POSIX (glibc, musl, macOS, BSDs): fseeko / ftello with off_t
 * - Fallback (C90 bare-metal, etc.): fseek / ftell with long
 */
#if defined(_MSC_VER)
    typedef __int64 fsize_t;
    #define portable_fseek(fp, off, whence) _fseeki64((fp), (off), (whence))
    #define portable_ftell(fp)              _ftelli64((fp))
#elif defined(_POSIX_C_SOURCE) || defined(__unix__) || defined(__APPLE__) || \
      defined(__linux__) || defined(__FreeBSD__) || defined(__OpenBSD__) || \
      defined(__NetBSD__)
    #include <sys/types.h>
    typedef off_t fsize_t;
    #define portable_fseek(fp, off, whence) fseeko((fp), (off), (whence))
    #define portable_ftell(fp)              ftello((fp))
#else
    typedef long fsize_t;
    #define portable_fseek(fp, off, whence) fseek((fp), (long)(off), (whence))
    #define portable_ftell(fp)              ftell((fp))
#endif

/* read entire file into a malloc'd buffer; sets *out_size; returns NULL on error */
char *read_file(const char *path, fsize_t *out_size);

/* read all of stdin into a malloc'd buffer; sets *out_size; returns NULL on error */
char *read_stdin(fsize_t *out_size);

/* normalize punctuation to U+037E; returns new malloc'd buffer; sets *out_size */
char *normalize_punctuation(const char *buf, fsize_t in_size, fsize_t *out_size);

/* write buf to path atomically (temp file + rename); returns 0 on success */
int write_file_atomic(const char *path, const char *buf, fsize_t size);

/* write buf to stdout; returns 0 on success */
int write_stdout(const char *buf, fsize_t size);

#endif /* IO_H */
