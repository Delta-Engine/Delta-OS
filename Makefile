# Delta OS Makefile
# This file is AI generated.

# Assembler
ASM = nasm
ASM_FLAGS = -f bin

# Emulator
QEMU = qemu-system-x86_64
QEMU_FLAGS = -drive format=raw,file=

# Directories
BOOTLOADER_DIR = bootloader
BUILD_DIR = build

# Files
BOOTLOADER_SRC = $(BOOTLOADER_DIR)/boot.asm
BOOTLOADER_BIN = $(BUILD_DIR)/boot.bin
DISK_IMAGE = $(BUILD_DIR)/delta_os.img

# Default target
.PHONY: all
all: build

# Build the disk image
.PHONY: build
build: $(DISK_IMAGE)
	@echo "Build complete: $(DISK_IMAGE)"

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Assemble bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) | $(BUILD_DIR)
	@echo "Assembling bootloader..."
	$(ASM) $(ASM_FLAGS) $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Create disk image
$(DISK_IMAGE): $(BOOTLOADER_BIN)
	@echo "Creating disk image..."
	@dd if=/dev/zero of=$(DISK_IMAGE) bs=512 count=2880 2>/dev/null
	@dd if=$(BOOTLOADER_BIN) of=$(DISK_IMAGE) conv=notrunc 2>/dev/null
	@echo "Disk image created successfully"

# Run in QEMU
.PHONY: run
run: build
	@echo "Starting QEMU..."
	$(QEMU) $(QEMU_FLAGS)$(DISK_IMAGE)

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@find $(BUILD_DIR) -type f ! -name '.gitkeep' -delete 2>/dev/null || true
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "Delta OS Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build    - Assemble bootloader and create disk image"
	@echo "  make run      - Build and run Delta OS in QEMU"
	@echo "  make clean    - Remove all build artifacts"
	@echo "  make help     - Display this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - nasm: Netwide Assembler"
	@echo "  - qemu-system-x86_64: QEMU emulator"
