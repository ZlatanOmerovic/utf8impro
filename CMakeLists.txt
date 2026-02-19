cmake_minimum_required(VERSION 3.21)
project(utf8-improver C)

set(SRC src/main.c src/io.c)
set(BIN utf8impro)

# default to release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# compiler warnings and flags
if(MSVC)
    add_compile_options(/W4)
    set(CMAKE_C_FLAGS_DEBUG "/Zi /Od /DDEBUG")
    set(CMAKE_C_FLAGS_RELEASE "/O2 /DNDEBUG")
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
    set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG")
    set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
endif()

# detect architecture
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
    set(IS_ARM TRUE)
    set(ARCH1 "arm64")
    set(ARCH2 "x64")
    set(ARCH1_FLAGS "-arch;arm64")
    set(ARCH2_FLAGS "-arch;x86_64")
else()
    set(IS_ARM FALSE)
    set(ARCH1 "x86")
    set(ARCH2 "x64")
    if(NOT MSVC)
        set(ARCH1_FLAGS "-m32")
        set(ARCH2_FLAGS "-m64")
    else()
        set(ARCH1_FLAGS "")
        set(ARCH2_FLAGS "")
    endif()
endif()

# C standards to build against
set(C_STANDARDS 90 99 11 17 23)

# architectures to build for
set(ARCHS ${ARCH1} ${ARCH2})

# default build
add_executable(${BIN} ${SRC})
set_target_properties(${BIN} PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED ON
)

# build matrix: each standard x each arch
foreach(STD ${C_STANDARDS})
    foreach(ARCH ${ARCHS})
        set(TARGET_NAME "${BIN}-c${STD}-${ARCH}")
        add_executable(${TARGET_NAME} ${SRC})
        set_target_properties(${TARGET_NAME} PROPERTIES
            C_STANDARD ${STD}
            C_STANDARD_REQUIRED ON
        )

        # set arch flags for gcc/clang
        if(NOT MSVC)
            if(ARCH STREQUAL ${ARCH1})
                target_compile_options(${TARGET_NAME} PRIVATE ${ARCH1_FLAGS})
                target_link_options(${TARGET_NAME} PRIVATE ${ARCH1_FLAGS})
            else()
                target_compile_options(${TARGET_NAME} PRIVATE ${ARCH2_FLAGS})
                target_link_options(${TARGET_NAME} PRIVATE ${ARCH2_FLAGS})
            endif()
        endif()
    endforeach()
endforeach()

# test for each arch
enable_testing()
foreach(ARCH ${ARCHS})
    set(TEST_TARGET "${BIN}-c11-${ARCH}")

    if(ARCH STREQUAL ${ARCH1})
        set(TEST_ARCH_FLAG "${ARCH1_FLAGS}")
    else()
        set(TEST_ARCH_FLAG "${ARCH2_FLAGS}")
    endif()

    add_test(
        NAME utf8-improver-${ARCH}
        COMMAND ${CMAKE_COMMAND}
            -DBIN=$<TARGET_FILE:${TEST_TARGET}>
            -DSRC=${CMAKE_SOURCE_DIR}/${SRC}
            -DCC=${CMAKE_C_COMPILER}
            -DARCH=${ARCH}
            -DARCH_FLAG=${TEST_ARCH_FLAG}
            -P ${CMAKE_SOURCE_DIR}/test.cmake
    )
endforeach()
