use std::io::{self, Read, Write};
use std::mem;

#[repr(C)] #[derive(Copy, Clone, Debug)]
struct InputEvent { tv_sec: i64, tv_usec: i64, ev_type: u16, code: u16, value: i32 }

const EV_KEY: u16 = 0x01; const EV_SYN: u16 = 0x00;

// --- KEYCODE DEFINITIONS (UPDATED FOR XKB SWAP) ---

// The physical key that now sends SHIFT signals and is used for the left-hand activation.
const KEY_ACTIVATION_L: u16 = 56; // This is the keycode for KEY_LEFTALT

// The standard keycode for the SHIFT modifier, which is used when *outputting* capitalized characters.
// The OS expects this standard keycode from the virtual keyboard.
const KEY_LEFTSHIFT: u16 = 42;

const KEY_RIGHTSHIFT: u16 = 54;
const KEY_CAPSLOCK: u16 = 58; // The physical key for the user's backspace

fn is_letter(code: u16) -> bool {
    // This defines all the physical keys that produce letters in the Graphite layout.
    matches!(code, 16..=20 | 22..=25 | 30..=39 | 44..=50)
}

fn send_event(writer: &mut impl Write, ev_type: u16, code: u16, value: i32) -> io::Result<()> {
    let event = InputEvent { tv_sec: 0, tv_usec: 0, ev_type, code, value };
    let event_bytes: &[u8] = unsafe { mem::transmute::<&InputEvent, &[u8; mem::size_of::<InputEvent>()]>(&event) };
    writer.write_all(event_bytes)
}

fn main() -> io::Result<()> {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut event_buffer = [0u8; mem::size_of::<InputEvent>()];
    let mut word_caps_mode = false;
    let mut l_activation_down = false; // Renamed for clarity
    let mut rshift_down = false;

    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };

        // --- Word Caps trigger logic (UPDATED) ---
        if event.ev_type == EV_KEY {
            match event.code {
                // Listen for the physical Left Alt key as the trigger
                KEY_ACTIVATION_L => l_activation_down = event.value != 0,
                KEY_RIGHTSHIFT => rshift_down = event.value != 0,
                _ => {}
            }
            // Check for the new activation combo
            if event.value == 1 && ((event.code == KEY_ACTIVATION_L && rshift_down) || (event.code == KEY_RIGHTSHIFT && l_activation_down)) {
                word_caps_mode = true;
                continue; // Swallow the trigger event
            }
        }

        // --- Core Word Caps Processing Logic ---
        if word_caps_mode && event.ev_type == EV_KEY && event.value == 1 { // On key press
            if is_letter(event.code) {
                // It's a letter: capitalize it.
                // We still output the STANDARD KEY_LEFTSHIFT for capitalization.
                send_event(&mut stdout, EV_KEY, KEY_LEFTSHIFT, 1)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, event.code, 1)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, event.code, 0)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                send_event(&mut stdout, EV_KEY, KEY_LEFTSHIFT, 0)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                stdout.flush()?;
                continue;
            } else if event.code == KEY_CAPSLOCK {
                // It's the backspace key. Do nothing to let it pass through.
            } else {
                // It's any other key. Terminate the mode.
                word_caps_mode = false;
            }
        }

        // Pass the event through to the next tool in the chain
        stdout.write_all(&event_buffer)?;
        stdout.flush()?;
    }
    Ok(())
}
