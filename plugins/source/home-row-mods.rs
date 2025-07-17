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

    let mut mod_map = HashMap::new();
    let mut key_hand_map = HashMap::new();
    let mut key_states: HashMap<u16, ModKeyState> = HashMap::new();

    const KEY_A: u16 = 30; const KEY_S: u16 = 31;
    const KEY_L: u16 = 38; const KEY_SEMICOLON: u16 = 39;

    mod_map.insert(KEY_A, (KEY_LEFTCTRL, KEY_A));
    mod_map.insert(KEY_S, (KEY_LEFTSHIFT, KEY_S));
    mod_map.insert(KEY_L, (KEY_LEFTSHIFT, KEY_L));
    mod_map.insert(KEY_SEMICOLON, (KEY_LEFTCTRL, KEY_SEMICOLON));

    // --- Comprehensive Hand Mapping ---
    // This now includes symbol keys, function keys, and special keys like backspace.
    let left_hand_keys = [
        1, 2, 3, 4, 5, 6,      // Esc, 1-5
        15, 16, 17, 18, 19, 20, // Tab, Q, W, E, R, T
        30, 31, 32, 33, 34,    // A, S, D, F, G
        42, 44, 45, 46, 47, 48, // LShift, Z, X, C, V, B
        58, 29, 56, 125, 57    // CapsLock (user's Backspace), LCtrl, LAlt, LMeta, Space
    ];
    let right_hand_keys = [
        7, 8, 9, 10, 11, 12, 13, 14, // 6-0, -, =, Backspace
        21, 22, 23, 24, 25, 26, 27,   // Y, U, I, O, P, [, ]
        35, 36, 37, 38, 39, 40, 43,   // H, J, K, L, ;, ', `
        54, 49, 50, 51, 52, 53,       // RShift, N, M, ,, ., /
        97, 100, 28                   // RCtrl, RAlt, Enter
    ];
    for key in left_hand_keys.iter() { key_hand_map.insert(*key, Hand::Left); }
    for key in right_hand_keys.iter() { key_hand_map.insert(*key, Hand::Right); }

    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };
        let now = Instant::now();

        // Timeout logic for single holds
        for (keycode, state) in key_states.iter_mut() {
            if state.is_held && !state.modifier_sent && now.duration_since(state.press_time).as_millis() > TAP_TIMEOUT_MS {
                let (modifier_code, _) = mod_map.get(keycode).unwrap();
                send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                state.modifier_sent = true;
            }
        }
        
        if event.ev_type != EV_KEY {
            stdout.write_all(&event_buffer)?; stdout.flush()?; continue;
        }

        let is_mod_key = mod_map.contains_key(&event.code);

        // --- Core Logic Block ---
        match event.value {
            1 => { // --- KEY PRESS ---
                let mut cancelled_keys = Vec::new();

                if let Some(new_key_hand) = key_hand_map.get(&event.code) {
                    for (mod_keycode, state) in key_states.iter_mut() {
                        if state.is_held && !state.modifier_sent {
                            if let Some(mod_key_hand) = key_hand_map.get(mod_keycode) {
                                if *new_key_hand != *mod_key_hand { // Opposite hand
                                    let (modifier_code, _) = mod_map.get(mod_keycode).unwrap();
                                    send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                                    send_event(&mut stdout, EV_SYN, 0, 0)?;
                                    state.modifier_sent = true;
                                } else { // Same hand
                                    let (_, tap_code) = mod_map.get(mod_keycode).unwrap();
                                    send_key_tap(&mut stdout, *tap_code)?;
                                    cancelled_keys.push(*mod_keycode);
                                }
                            }
                        }
                    }
                }
                for key in cancelled_keys { key_states.remove(&key); }

                if is_mod_key {
                    key_states.insert(event.code, ModKeyState { is_held: true, press_time: now, modifier_sent: false });
                    continue;
                }
            },
            0 => { // --- KEY RELEASE ---
                if is_mod_key {
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
            },
            _ => {} // Repeat events are ignored
        }

        // Pass the original event through if it was not swallowed by a `continue`
        stdout.write_all(&event_buffer)?;
        stdout.flush()?;
    }
    Ok(())
}
