use std::collections::HashMap;
use std::io::{self, Read, Write};
use std::mem;
use std::time::Instant;

const TAP_TIMEOUT_MS: u128 = 200;

#[repr(C)] #[derive(Copy, Clone, Debug)]
struct InputEvent { tv_sec: i64, tv_usec: i64, ev_type: u16, code: u16, value: i32 }

#[derive(Clone, Copy, PartialEq, Debug)]
enum Hand { Left, Right }

const EV_KEY: u16 = 0x01; const EV_SYN: u16 = 0x00;

// Modifier Keycodes
const KEY_LEFTCTRL: u16 = 29; const KEY_LEFTSHIFT: u16 = 42;

#[derive(Clone, Copy)] struct ModKeyState { is_held: bool, press_time: Instant, modifier_sent: bool }

fn send_event(writer: &mut impl Write, ev_type: u16, code: u16, value: i32) -> io::Result<()> {
    let event = InputEvent { tv_sec: 0, tv_usec: 0, ev_type, code, value };
    let event_bytes: &[u8] = unsafe { mem::transmute::<&InputEvent, &[u8; mem::size_of::<InputEvent>()]>(&event) };
    writer.write_all(event_bytes)
}

fn send_key_tap(writer: &mut impl Write, code: u16) -> io::Result<()> {
    send_event(writer, EV_KEY, code, 1)?; send_event(writer, EV_SYN, 0, 0)?;
    send_event(writer, EV_KEY, code, 0)?; send_event(writer, EV_SYN, 0, 0)
}

fn main() -> io::Result<()> {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut event_buffer = [0u8; mem::size_of::<InputEvent>()];

    // --- Data Maps ---
    let mut mod_map = HashMap::new();
    let mut key_hand_map = HashMap::new();
    let mut key_states: HashMap<u16, ModKeyState> = HashMap::new();

    // Keycodes for the mod keys
    const KEY_A: u16 = 30; const KEY_S: u16 = 31;
    const KEY_L: u16 = 38; const KEY_SEMICOLON: u16 = 39;

    // --- Modifier Map ---
    mod_map.insert(KEY_A, (KEY_LEFTCTRL, KEY_A));
    mod_map.insert(KEY_S, (KEY_LEFTSHIFT, KEY_S));
    mod_map.insert(KEY_L, (KEY_LEFTSHIFT, KEY_L));
    mod_map.insert(KEY_SEMICOLON, (KEY_LEFTCTRL, KEY_SEMICOLON));

    // --- Hand Mapping ---
    // This maps every physical key to a hand.
    let left_hand_keys = [
        1, 2, 3, 4, 5, 16, 17, 18, 19, 20, 30, 31, 32, 33, 34, 44, 45, 46, 47, 48, 57, 41, 29, 42, 56, 15, 58
    ];
    let right_hand_keys = [
        6, 7, 8, 9, 10, 11, 12, 13, 21, 22, 23, 24, 25, 26, 27, 35, 36, 37, 38, 39, 40, 43, 50, 51, 52, 53, 97, 54, 125, 28
    ];
    for key in left_hand_keys.iter() { key_hand_map.insert(*key, Hand::Left); }
    for key in right_hand_keys.iter() { key_hand_map.insert(*key, Hand::Right); }

    // --- Main Loop ---
    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };
        let now = Instant::now();

        // Check for timed-out holds (a hold without any other key press)
        let mut timed_out_keys = Vec::new();
        for (keycode, state) in key_states.iter_mut() {
            if state.is_held && !state.modifier_sent && now.duration_since(state.press_time).as_millis() > TAP_TIMEOUT_MS {
                let (modifier_code, _) = mod_map.get(keycode).unwrap();
                send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                state.modifier_sent = true;
                timed_out_keys.push(*keycode);
            }
        }

        let is_mod_key = mod_map.contains_key(&event.code);

        if event.ev_type == EV_KEY && is_mod_key {
            // --- MOD KEY PRESS/RELEASE LOGIC ---
            if event.value == 1 { // Press
                key_states.insert(event.code, ModKeyState { is_held: true, press_time: now, modifier_sent: false });
                continue;
            }
            if event.value == 0 { // Release
                if let Some(state) = key_states.get_mut(&event.code) {
                    if state.modifier_sent {
                        let (modifier_code, _) = mod_map.get(&event.code).unwrap();
                        send_event(&mut stdout, EV_KEY, *modifier_code, 0)?;
                        send_event(&mut stdout, EV_SYN, 0, 0)?;
                    } else {
                        let (_, tap_code) = mod_map.get(&event.code).unwrap();
                        send_key_tap(&mut stdout, *tap_code)?;
                    }
                    key_states.remove(&event.code);
                    continue;
                }
            }
        } else if event.ev_type == EV_KEY && event.value == 1 {
            // --- CHORDING LOGIC (A NON-MOD KEY WAS PRESSED) ---
            if let Some(new_key_hand) = key_hand_map.get(&event.code) {
                let mut cancelled_keys = Vec::new();
                for (mod_keycode, state) in key_states.iter_mut() {
                    if state.is_held && !state.modifier_sent {
                        if let Some(mod_key_hand) = key_hand_map.get(mod_keycode) {
                            if *new_key_hand != *mod_key_hand {
                                // OPPOSITE HAND: Activate the modifier
                                let (modifier_code, _) = mod_map.get(mod_keycode).unwrap();
                                send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                                send_event(&mut stdout, EV_SYN, 0, 0)?;
                                state.modifier_sent = true;
                            } else {
                                // SAME HAND: Cancel the hold and tap the mod key's character
                                let (_, tap_code) = mod_map.get(mod_keycode).unwrap();
                                send_key_tap(&mut stdout, *tap_code)?;
                                cancelled_keys.push(*mod_keycode);
                            }
                        }
                    }
                }
                // Clean up any cancelled keys
                for key in cancelled_keys { key_states.remove(&key); }
            }
        }

        // Pass the original event through
        stdout.write_all(&event_buffer)?;
        stdout.flush()?;
    }
    Ok(())
}
