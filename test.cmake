# --- test 1: in-place mode ---

# copy source file as main-improved.c
set(TEST_FILE "${CMAKE_CURRENT_BINARY_DIR}/main-improved.c")
file(COPY ${SRC} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
get_filename_component(FILENAME ${SRC} NAME)
file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}" ${TEST_FILE})

# run the tool on the copied file (in-place)
execute_process(
    COMMAND ${BIN} ${TEST_FILE}
    RESULT_VARIABLE RUN_RESULT
)
if(NOT RUN_RESULT EQUAL 0)
    message(FATAL_ERROR "Tool failed to run (in-place mode)")
endif()

# try compiling the modified file
execute_process(
    COMMAND ${CC} ${ARCH_FLAG} -o /dev/null ${TEST_FILE}
    RESULT_VARIABLE COMPILE_RESULT
    ERROR_QUIET
)
if(COMPILE_RESULT EQUAL 0)
    message(FATAL_ERROR "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL.")
else()
    message("test 1/2 passed (${ARCH}): in-place mode works")
endif()

# clean up
file(REMOVE ${TEST_FILE})

# --- test 2: output-file mode ---

set(TEST_SRC "${CMAKE_CURRENT_BINARY_DIR}/main-src.c")
set(TEST_OUT "${CMAKE_CURRENT_BINARY_DIR}/main-improved.c")
file(COPY ${SRC} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}" ${TEST_SRC})

# run the tool with separate input and output
execute_process(
    COMMAND ${BIN} ${TEST_SRC} ${TEST_OUT}
    RESULT_VARIABLE RUN_RESULT
)
if(NOT RUN_RESULT EQUAL 0)
    message(FATAL_ERROR "Tool failed to run (output-file mode)")
endif()

# try compiling the output file
execute_process(
    COMMAND ${CC} ${ARCH_FLAG} -o /dev/null ${TEST_OUT}
    RESULT_VARIABLE COMPILE_RESULT
    ERROR_QUIET
)
if(COMPILE_RESULT EQUAL 0)
    message(FATAL_ERROR "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL.")
else()
    message("test 2/2 passed (${ARCH}): output-file mode works")
endif()

# clean up
file(REMOVE ${TEST_SRC} ${TEST_OUT})
