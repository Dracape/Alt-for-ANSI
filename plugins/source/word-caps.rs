use std::io::{self, Read, Write};
use std::mem;

#[repr(C)] #[derive(Copy, Clone, Debug)]
struct InputEvent { tv_sec: i64, tv_usec: i64, ev_type: u16, code: u16, value: i32 }

const EV_KEY: u16 = 0x01; const EV_SYN: u16 = 0x00;
const KEY_LEFTSHIFT: u16 = 42; const KEY_RIGHTSHIFT: u16 = 54;
const KEY_CAPSLOCK: u16 = 58; // The physical key for the user's backspace

fn is_letter(code: u16) -> bool {
    matches!(code, 16..=25 | 30..=39 | 44..=50)
}

fn send_event(writer: &mut impl Write, ev_type: u16, code: u16, value: i32) -> io::Result<()> {
    let event = InputEvent { tv_sec: 0, tv_usec: 0, ev_type, code, value };
    let event_bytes: &[u8] = unsafe { mem::transmute::<&InputEvent, &[u8; mem::size_of::<InputEvent>()]>(&event) };
    writer.write_all(event_bytes)
}

fn main() -> io::Result<()> {
    let mut stdin = io::stdin().lock(); let mut stdout = io::stdout().lock();
    let mut event_buffer = [0u8; mem::size_of::<InputEvent>()];
    let mut word_caps_mode = false; let mut lshift_down = false; let mut rshift_down = false;

    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };
        if event.ev_type == EV_KEY {
            match event.code { KEY_LEFTSHIFT => lshift_down = event.value != 0, KEY_RIGHTSHIFT => rshift_down = event.value != 0, _ => {} }
            if event.value == 1 && ((event.code == KEY_LEFTSHIFT && rshift_down) || (event.code == KEY_RIGHTSHIFT && lshift_down)) {
                word_caps_mode = true; continue;
            }
        }
        
        // This is the core logic block with the fix
        if word_caps_mode && event.ev_type == EV_KEY && event.value == 1 {
            if is_letter(event.code) {
                // If it's a letter, capitalize it and swallow the original event.
                send_event(&mut stdout, EV_KEY, KEY_LEFTSHIFT, 1)?; send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, event.code, 1)?;    send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, event.code, 0)?;    send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, KEY_LEFTSHIFT, 0)?; send_event(&mut stdout, EV_SYN, 0, 0)?;
                stdout.flush()?; continue;
            } else if event.code == KEY_CAPSLOCK {
                // THIS IS THE FIX: If it's the backspace key (physical CapsLock),
                // do nothing here. This prevents the 'else' block from running,
                // so the mode is NOT terminated. The event will be passed through normally below.
            }
             else {
                // If it's any other non-letter key, terminate the mode.
                word_caps_mode = false;
            }
        }
        
        // Pass the event through to the next tool in the chain.
        stdout.write_all(&event_buffer)?; stdout.flush()?;
    }
    Ok(())
}
