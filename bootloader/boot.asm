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
    mov dx, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    ; welcome message
    mov si, msg_welcome
    call print_string

    call load_kernel

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

halt:
    cli
    hlt
    jmp halt

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

    ; For Verification
    push es
    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov ax, [es:KERNEL_OFFSET]
    pop es
    test ax, ax
    jz disk_error

    mov si, msg_ok
    call print_string
    ret

disk_error:
    mov si, msg_error
    call print_string
    jmp $

; Data
boot_drive:     db 0
msg_welcome:    db 'Delta OS v1.0 (Dev)', 0x0D, 0x0A, 0
msg_loading:    db 'Loading...', 0x0D, 0x0A, 0
msg_ok:         db 'OK', 0x0D, 0x0A, 0
msg_error:      db 'Error!', 0x0D, 0x0A, 0
msg_protected:  db 'PM...', 0x0D, 0x0A, 0
pm_msg:         db 'Delta OS - Protected Mode', 0

times 510-($-$$) db 0
dw 0xAA55

