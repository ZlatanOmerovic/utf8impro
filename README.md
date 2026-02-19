# utf8impro

A lightweight, cross-platform CLI tool for normalizing unicode punctuation in source files to their proper UTF-8 representations.

Written in portable C89 — no dependencies, no runtime, no nonsense.

## Table of Contents

- [About](#about)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Building](#building)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## About

Source files authored across different editors, operating systems, and locales often contain punctuation characters that appear visually identical but differ at the byte level. This can lead to subtle, hard-to-diagnose issues during compilation, linting, or diffing.

**utf8impro** performs in-place normalization of affected punctuation to their correct UTF-8 encoded equivalents, ensuring consistency across your codebase.

The tool reads a file into memory, applies the necessary byte-level corrections, and writes the result back — safely and atomically. Every error path is handled. Every allocation is checked.

## Requirements

**Linux / macOS:**

- GCC or Clang
- GNU Make
- CMake 3.21+ *(optional, for CMake builds)*

**Windows:**

- MSVC (Visual Studio 2019+)
- nmake
- CMake 3.21+ *(optional)*

**macOS (Apple Silicon):**

Fully supported. The build system auto-detects ARM64 and adjusts architecture targets accordingly.

## Getting Started

```bash
git clone https://github.com/user/utf8impro.git
cd utf8impro
make
```

That's it. The compiled binary will be at `build/gcc/release/<arch>/utf8impro`.

## Building

### Quick Build

```bash
# default release build (auto-detects architecture)
make

# debug build
make debug

# build both architectures
make release
```

### Architecture Targets

On ARM systems (Apple Silicon, etc.):

```bash
make release-arm64
make release-x64
```

On x86/x64 systems:

```bash
make release-x86
make release-x64
```

### C Standard Targets

Build against a specific C standard:

```bash
make c89
make c99
make c11
make c17
make c23
```

Each standard builds for both architectures. To target a specific combination:

```bash
make c89-arm64
make c11-x64
```

### Build Everything

```bash
make full
```

This builds debug, release, and all C standard variants for both architectures.

### Windows

From a Visual Studio Developer Command Prompt:

```cmd
nmake /f Makefile.win
nmake /f Makefile.win release-x64
nmake /f Makefile.win full
```

Architecture is determined by which Developer Command Prompt you launch — x86, x64, or ARM64 Native Tools.

### CMake

```bash
cmake -S . -B build/cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build/cmake
```

Or through Make:

```bash
make cmake
```

## Usage

```bash
./build/gcc/release/<arch>/utf8impro [input] [output]
```

The tool supports three modes:

| Mode | Command | Behavior |
|------|---------|----------|
| Pipe | `utf8impro` | Reads from stdin, writes to stdout |
| In-place | `utf8impro <file>` | Modifies the file atomically (via temp file + rename) |
| Output file | `utf8impro <input> <output>` | Reads input, writes result to output |

**Examples:**

```bash
# normalize a single file in-place
./utf8impro src/parser.c

# normalize to a separate output file
./utf8impro src/parser.c src/parser-improved.c

# pipe mode — use with shell pipelines
cat src/parser.c | ./utf8impro > improved.c

# normalize multiple files
for f in src/*.c; do ./utf8impro "$f"; done

# use with find
find . -name "*.c" -exec ./utf8impro {} \;
```

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0    | Success |
| 1    | Error (missing argument, file not found, I/O failure) |

## Testing

```bash
# test both architectures
make test

# test specific architecture
make test-arm64
make test-x64
```

The test suite copies `src/main.c`, runs the tool against the copy in both in-place and output-file modes, and verifies the output behaves as expected when passed back to the compiler. Temp files are cleaned up automatically.

### CMake Tests

```bash
make cmake
# or
ctest --test-dir build/cmake
```

## Project Structure

```
utf8impro/
├── src/
│   ├── main.c              # entry point and argument parsing
│   ├── io.c                # file I/O and transformation logic
│   └── io.h                # io.c declarations and portable large-file support
├── build/                   # build artifacts (gitignored)
│   ├── .gitkeep
│   ├── gcc/                 # Makefile builds
│   │   ├── debug/
│   │   │   ├── arm64/       # or x86/
│   │   │   └── x64/
│   │   ├── release/
│   │   │   ├── arm64/
│   │   │   └── x64/
│   │   └── c89/ ... c23/
│   │       ├── arm64/
│   │       └── x64/
│   ├── msvc/                # Makefile.win builds
│   │   └── ...
│   └── cmake/               # CMake builds
├── Makefile                 # Linux / macOS
├── Makefile.win             # Windows (nmake)
├── CMakeLists.txt           # CMake
├── test.cmake               # CMake test script
├── .gitignore
└── README.md
```

## Contributing

1. Fork the repository
2. Create your branch: `git checkout -b feature/your-feature`
3. Write portable C89 — no compiler-specific extensions, no C99+ features in core logic
4. Ensure `make full` passes on your platform
5. Ensure `make test` passes for all architectures you can build
6. Submit a pull request

### Code Style

- `/* */` comments only — no `//`
- All variables declared at the top of the block
- Every `malloc` must have a corresponding `free`
- Every `fopen` must have a corresponding `fclose`
- Every error path must clean up resources before returning
- No compiler warnings with `-Wall -Wextra -Wpedantic`

## License

MIT
