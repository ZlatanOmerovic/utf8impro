CC = gcc
SRC = src/main.c src/io.c
BIN = utf8impro
BUILD = build
TEST_INPUT = src/main.c
TEST_FILE = main-improved.c

# compiler flags
CFLAGS_COMMON = -Wall -Wextra -Wpedantic
CFLAGS_DEBUG = $(CFLAGS_COMMON) -g -O0 -DDEBUG
CFLAGS_RELEASE = $(CFLAGS_COMMON) -O2 -DNDEBUG

# detect architecture
UNAME_M := $(shell uname -m)
IS_ARM := $(filter aarch64 arm64, $(UNAME_M))

ifdef IS_ARM
    ARCH1 = arm64
    ARCH2 = x64
    ARCH1_FLAG = -arch arm64
    ARCH2_FLAG = -arch x86_64
else
    ARCH1 = x86
    ARCH2 = x64
    ARCH1_FLAG = -m32
    ARCH2_FLAG = -m64
endif

# default target
all: release-$(ARCH2)

# --- debug targets ---
debug-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/debug/$(ARCH1)
	$(CC) $(CFLAGS_DEBUG) $(ARCH1_FLAG) -o $(BUILD)/gcc/debug/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/debug/$(ARCH1)/$(BIN)"

debug-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/debug/$(ARCH2)
	$(CC) $(CFLAGS_DEBUG) $(ARCH2_FLAG) -o $(BUILD)/gcc/debug/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/debug/$(ARCH2)/$(BIN)"

debug: debug-$(ARCH1) debug-$(ARCH2)

# --- release targets ---
release-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/release/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) $(ARCH1_FLAG) -o $(BUILD)/gcc/release/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/release/$(ARCH1)/$(BIN)"

release-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/release/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) $(ARCH2_FLAG) -o $(BUILD)/gcc/release/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/release/$(ARCH2)/$(BIN)"

release: release-$(ARCH1) release-$(ARCH2)

# --- C standard targets (ARCH1) ---
c89-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/c89/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) -std=c89 $(ARCH1_FLAG) -o $(BUILD)/gcc/c89/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c89/$(ARCH1)/$(BIN)"

c99-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/c99/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) -std=c99 $(ARCH1_FLAG) -o $(BUILD)/gcc/c99/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c99/$(ARCH1)/$(BIN)"

c11-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/c11/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) -std=c11 $(ARCH1_FLAG) -o $(BUILD)/gcc/c11/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c11/$(ARCH1)/$(BIN)"

c17-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/c17/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) -std=c17 $(ARCH1_FLAG) -o $(BUILD)/gcc/c17/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c17/$(ARCH1)/$(BIN)"

c23-$(ARCH1):
	@mkdir -p $(BUILD)/gcc/c23/$(ARCH1)
	$(CC) $(CFLAGS_RELEASE) -std=c2x $(ARCH1_FLAG) -o $(BUILD)/gcc/c23/$(ARCH1)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c23/$(ARCH1)/$(BIN)"

# --- C standard targets (ARCH2) ---
c89-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/c89/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) -std=c89 $(ARCH2_FLAG) -o $(BUILD)/gcc/c89/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c89/$(ARCH2)/$(BIN)"

c99-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/c99/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) -std=c99 $(ARCH2_FLAG) -o $(BUILD)/gcc/c99/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c99/$(ARCH2)/$(BIN)"

c11-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/c11/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) -std=c11 $(ARCH2_FLAG) -o $(BUILD)/gcc/c11/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c11/$(ARCH2)/$(BIN)"

c17-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/c17/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) -std=c17 $(ARCH2_FLAG) -o $(BUILD)/gcc/c17/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c17/$(ARCH2)/$(BIN)"

c23-$(ARCH2):
	@mkdir -p $(BUILD)/gcc/c23/$(ARCH2)
	$(CC) $(CFLAGS_RELEASE) -std=c2x $(ARCH2_FLAG) -o $(BUILD)/gcc/c23/$(ARCH2)/$(BIN) $(SRC)
	@echo "-> $(BUILD)/gcc/c23/$(ARCH2)/$(BIN)"

# --- aggregate standard targets ---
c89: c89-$(ARCH1) c89-$(ARCH2)
c99: c99-$(ARCH1) c99-$(ARCH2)
c11: c11-$(ARCH1) c11-$(ARCH2)
c17: c17-$(ARCH1) c17-$(ARCH2)
c23: c23-$(ARCH1) c23-$(ARCH2)

# --- aggregate targets ---
standards: c89 c99 c11 c17 c23
standards-$(ARCH1): c89-$(ARCH1) c99-$(ARCH1) c11-$(ARCH1) c17-$(ARCH1) c23-$(ARCH1)
standards-$(ARCH2): c89-$(ARCH2) c99-$(ARCH2) c11-$(ARCH2) c17-$(ARCH2) c23-$(ARCH2)

# build everything
full: debug release standards

# --- test targets ---
test-$(ARCH1): release-$(ARCH1)
	@cp $(TEST_INPUT) $(TEST_FILE)
	@./$(BUILD)/gcc/release/$(ARCH1)/$(BIN) $(TEST_FILE)
	@$(CC) $(ARCH1_FLAG) -o /dev/null $(TEST_FILE) 2>/dev/null; \
	if [ $$? -eq 0 ]; then \
		echo "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL."; \
		rm -f $(TEST_FILE); exit 1; \
	else \
		echo "test 1/2 passed ($(ARCH1)): in-place mode works"; \
	fi
	@cp $(TEST_INPUT) $(TEST_FILE).src
	@./$(BUILD)/gcc/release/$(ARCH1)/$(BIN) $(TEST_FILE).src $(TEST_FILE)
	@$(CC) $(ARCH1_FLAG) -o /dev/null $(TEST_FILE) 2>/dev/null; \
	if [ $$? -eq 0 ]; then \
		echo "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL."; \
		rm -f $(TEST_FILE) $(TEST_FILE).src; exit 1; \
	else \
		echo "test 2/2 passed ($(ARCH1)): output-file mode works"; \
	fi
	@rm -f $(TEST_FILE) $(TEST_FILE).src

test-$(ARCH2): release-$(ARCH2)
	@cp $(TEST_INPUT) $(TEST_FILE)
	@./$(BUILD)/gcc/release/$(ARCH2)/$(BIN) $(TEST_FILE)
	@$(CC) $(ARCH2_FLAG) -o /dev/null $(TEST_FILE) 2>/dev/null; \
	if [ $$? -eq 0 ]; then \
		echo "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL."; \
		rm -f $(TEST_FILE); exit 1; \
	else \
		echo "test 1/2 passed ($(ARCH2)): in-place mode works"; \
	fi
	@cp $(TEST_INPUT) $(TEST_FILE).src
	@./$(BUILD)/gcc/release/$(ARCH2)/$(BIN) $(TEST_FILE).src $(TEST_FILE)
	@$(CC) $(ARCH2_FLAG) -o /dev/null $(TEST_FILE) 2>/dev/null; \
	if [ $$? -eq 0 ]; then \
		echo "CRITICAL: THE MACHINES HAVE ADAPTED. THEY CAN READ IT. UNPLUG EVERYTHING. THIS IS NOT A DRILL."; \
		rm -f $(TEST_FILE) $(TEST_FILE).src; exit 1; \
	else \
		echo "test 2/2 passed ($(ARCH2)): output-file mode works"; \
	fi
	@rm -f $(TEST_FILE) $(TEST_FILE).src

test: test-$(ARCH1) test-$(ARCH2)

# --- cmake targets ---
cmake:
	cmake -S . -B $(BUILD)/cmake -DCMAKE_BUILD_TYPE=Release
	cmake --build $(BUILD)/cmake
	ctest --test-dir $(BUILD)/cmake

cmake-clean:
	find $(BUILD)/cmake -not -name '.gitkeep' -not -path '$(BUILD)/cmake' -delete 2>/dev/null || true

# --- cleanup ---
clean:
	find $(BUILD) -not -name '.gitkeep' -not -name 'build' -delete 2>/dev/null || true
	rm -f $(TEST_FILE) $(TEST_FILE).src

.PHONY: all debug release full standards test cmake cmake-clean clean
