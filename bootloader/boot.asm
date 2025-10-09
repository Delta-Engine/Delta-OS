; Delta OS Bootloader - Fixed and Optimized
; A simple 16-bit bootloader that loads the kernel and enters 32-bit protected mode
; Author: Pranav Verma

[BITS 16]
[ORG 0x7C00] ; hell nah man

KERNEL_OFFSET equ 0x1000
KERNEL_SEGMENT equ 0x0000

; Start Dir
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    ; welcome message
    mov si, msg_welcome
    call print_string

    call load_kernel

    ; Enable A20 (fast method)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov si, msg_protected
    call print_string

    cli
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:protected_mode_start

print_string:
    pusha
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret

load_kernel:
    mov si, msg_loading
    call print_string

    mov ah, 0x02    ; Read Sectors
    mov al, 32      ; Number of sectors
    mov ch, 0       ; Cylinder No. 0
    mov cl, 2       ; Sector 2
    mov dh, 0       ; Head 0
    mov dl, [boot_drive]
    mov bx, KERNEL_SEGMENT
    mov es, bx
    mov bx, KERNEL_OFFSET
    int 0x13
    jc disk_error

    mov si, msg_ok
    call print_string
    ret

disk_error:
    mov si, msg_error
    call print_string
    jmp $

[BITS 32]

protected_mode_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw

    jmp CODE_SEG:KERNEL_OFFSET

halt:
    cli
    hlt
    jmp halt


[BITS 16]
align 4
gdt_start:
    dq 0x0

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Data
boot_drive:     db 0
msg_welcome:    db 'Delta OS Bootloader', 0x0D, 0x0A, 0
msg_loading:    db 'Loading kernel...', 0x0D, 0x0A, 0
msg_ok:         db 'OK', 0x0D, 0x0A, 0
msg_error:      db 'Disk Error!', 0x0D, 0x0A, 0
msg_protected:  db 'Entering PM...', 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55

