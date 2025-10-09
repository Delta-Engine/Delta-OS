#![no_std]
#![no_main]

use core::panic::PanicInfo;

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
    fn new(fg: Color, bg: Color) -> self {
        Writer {
            column: 0,
            row: 0,
            color: ((bg as u8) << 4) | (fg as u8)
        }
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    let mut writer = Writer::new(Color::white, Color::Red);
}

