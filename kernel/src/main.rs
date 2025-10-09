#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xB8000 as *mut u8;
const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;

// Color codes for VGA text mode (AI Generated)
#[allow(dead_code)]
#[repr(u8)]
pub enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

struct Writer {
    column: usize,
    row: usize,
    color: u8,
}

impl Writer {
    fn new(fg: Color, bg: Color) -> Self {
        Writer {
            column: 0,
            row: 0,
            color: ((bg as u8) << 4) | (fg as u8),
        }
    }

    fn write_byte(&mut self, byte: u8) {
        match byte {
            b'\n' => self.new_line(),
            byte => {
                if self.column >= VGA_WIDTH {
                    self.new_line();
                }

                let offset = (self.row * VGA_WIDTH + self.column) * 2;
                unsafe {
                    *VGA_BUFFER.add(offset) = byte;
                    *VGA_BUFFER.add(offset + 1) = self.color;
                }
                self.column += 1;
            }
        }
    }

    fn write_string(&mut self, s: &str) {
        for byte in s.bytes() {
            match byte {
                0x20..=0x7e | b'\n' => self.write_byte(byte),
                _ => self.write_byte(0xfe),
            }
        }
    }

    fn new_line(&mut self) {
        self.row = self.row + 1;
        self.column = 0;

        if self.row >= VGA_HEIGHT {
            self.scroll();
            self.row = VGA_HEIGHT - 1
        }
    }

    fn scroll(&mut self) {
        unsafe {
            for row in 1..VGA_HEIGHT {
                for col in 0..VGA_WIDTH {
                    let src = (row * VGA_WIDTH + col) * 2;
                    let dst = ((row - 1) * VGA_WIDTH + col) * 2;

                    *VGA_BUFFER.add(dst) = *VGA_BUFFER.add(src);
                    *VGA_BUFFER.add(dst + 1) = *VGA_BUFFER.add(src + 1);
                }
            }

            let last_row = VGA_HEIGHT - 1;
            for col in 0..VGA_WIDTH {
                let offset = (last_row * VGA_WIDTH + col) * 2;
                *VGA_BUFFER.add(offset) = b' ';
                *VGA_BUFFER.add(offset + 1) = self.color;
            }
        }
    }

    fn clear_screen(&mut self) {
        for row in 0..VGA_HEIGHT {
            for col in 0..VGA_WIDTH {
                let offset = (row * VGA_WIDTH + col) * 2;
                unsafe {
                    *VGA_BUFFER.add(offset) = b' ';
                    *VGA_BUFFER.add(offset + 1) = self.color;
                }
            }
        }
        self.column = 0;
        self.row = 0;
    }
}

#[repr(C, packed)]
#[derive(Copy, Clone)]
struct IdtEntry {
    offset_low: u16,
    selector: u16,
    zero: u8,
    type_attr: u8,
    offset_high: u16,
}

impl IdtEntry {
    const fn new() -> Self {
        IdtEntry {
            offset_low: 0,
            selector: 0x08,
            zero: 0,
            type_attr: 0x8E,
            offset_high: 0,
        }
    }

    fn set_handler(&mut self, handler: u32) {
        self.offset_low = (handler & 0xFFFF) as u16;
        self.offset_high = ((handler >> 16) & 0xFFFF) as u16;
        self.selector = 0x08;
        self.type_attr = 0x8E;
        self.zero = 0;
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    let mut writer = Writer::new(Color::White, Color::Red);
    writer.clear_screen();
    writer.write_string("KERNEL PANIC!\n\n");

    if let Some(location) = info.location() {
        writer.write_string("Location: ");
        writer.write_string(location.file());
        writer.write_string("\n");
    }

    loop {
        unsafe { core::arch::asm!("hlt") }
    }
}
