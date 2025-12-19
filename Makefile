# Delta OS Makefile

# Tools
ASM = nasm
ASM_FLAGS = -f bin
CARGO = cargo
QEMU = qemu-system-x86_64
QEMU_FLAGS = -drive format=raw,file=

# Directories
BOOTLOADER_DIR = bootloader
KERNEL_DIR = kernel
BUILD_DIR = build

# Files
BOOTLOADER_SRC = $(BOOTLOADER_DIR)/boot.asm
BOOTLOADER_BIN = $(BUILD_DIR)/boot.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
DISK_IMAGE = $(BUILD_DIR)/delta_os.img

# Default target
.PHONY: all
all: $(DISK_IMAGE)
	@echo "Build complete: $(DISK_IMAGE)"

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Assemble bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) | $(BUILD_DIR)
	@echo "Assembling bootloader..."
	$(ASM) $(ASM_FLAGS) $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Build kernel
.PHONY: kernel
kernel: | $(BUILD_DIR)
	@echo "Building kernel..."
	@cd $(KERNEL_DIR) && $(CARGO) build --release 2>&1 | grep -v "warning: unused" || true
	@cp $(KERNEL_DIR)/target/i686-unknown-none/release/kernel $(KERNEL_BIN)
	@echo "Kernel built successfully"

# Create disk image
$(DISK_IMAGE): $(BOOTLOADER_BIN) kernel
	@echo "Creating disk image..."
	@dd if=/dev/zero of=$(DISK_IMAGE) bs=512 count=2880 2>/dev/null
	@dd if=$(BOOTLOADER_BIN) of=$(DISK_IMAGE) conv=notrunc 2>/dev/null
	@dd if=$(KERNEL_BIN) of=$(DISK_IMAGE) bs=512 seek=1 conv=notrunc 2>/dev/null
	@echo "Disk image created successfully"

# Build target
.PHONY: build
build: $(DISK_IMAGE)

# Run in QEMU
.PHONY: run
run: $(DISK_IMAGE)
	@echo "Starting QEMU..."
	$(QEMU) $(QEMU_FLAGS)$(DISK_IMAGE)

# Run with debugging output
.PHONY: run-debug
run-debug: $(DISK_IMAGE)
	@echo "Starting QEMU with debugging..."
	$(QEMU) $(QEMU_FLAGS)$(DISK_IMAGE) -d int,cpu_reset -no-reboot

# Run in QEMU with VNC (hidden)
.PHONY: run-vnc
run-vnc: $(DISK_IMAGE)
	@echo "Starting QEMU with VNC on :5900..."
	$(QEMU) $(QEMU_FLAGS)$(DISK_IMAGE) -vnc :0

# Run with debugging output and VNC (hidden)
.PHONY: run-debug-vnc
run-debug-vnc: $(DISK_IMAGE)
	@echo "Starting QEMU with debugging and VNC on :5900..."
	$(QEMU) $(QEMU_FLAGS)$(DISK_IMAGE) -vnc :0 -d int,cpu_reset -no-reboot

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/*
	@cd $(KERNEL_DIR) && $(CARGO) clean 2>/dev/null || true
	@echo "Clean complete"

# Rebuild everything
.PHONY: rebuild
rebuild: clean all

# Help target
.PHONY: help
help:
	@echo "Delta OS Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build      - Build bootloader, kernel, and create disk image"
	@echo "  make run        - Build and run Delta OS in QEMU"
	@echo "  make run-debug  - Run with QEMU debugging output"
	@echo "  make clean      - Remove all build artifacts"
	@echo "  make rebuild    - Clean and rebuild everything"
	@echo "  make help       - Display this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - nasm: Netwide Assembler"
	@echo "  - cargo: Rust build tool"
	@echo "  - qemu-system-x86_64: QEMU emulator"
	@echo "  - rust nightly toolchain"
