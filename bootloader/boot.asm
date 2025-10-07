; Delta OS Bootloader - Fixed and Optimized
; A simple 16-bit bootloader that loads the kernel and enters 32-bit protected mode
; Author: Pranav Verma

[BITS 16]
[ORG 0x7C00] ; hell nah man

; Start Dir
start:

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

