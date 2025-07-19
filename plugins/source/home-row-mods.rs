use std::collections::HashMap;
use std::io::{self, Read, Write};
use std::mem;
use std::time::Instant;

const TAP_TIMEOUT_MS: u128 = 200;

#[repr(C)] #[derive(Copy, Clone, Debug)]
struct InputEvent { tv_sec: i64, tv_usec: i64, ev_type: u16, code: u16, value: i32 }

#[derive(Clone, Copy, PartialEq, Debug)]
enum Hand { Left, Right }
#[derive(Clone, Copy, PartialEq, Debug)]
enum ModType { Ctrl, Shift }

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

    const KEY_L: u16 = 38; const KEY_SEMICOLON: u16 = 39;

    // --- MODIFIER MAP (EDITED) ---
    // Left-hand keys have been removed. They will now act as normal keys.
    // Right-hand keys remain as active home row mods.
    mod_map.insert(KEY_L, (KEY_LEFTSHIFT, KEY_L, ModType::Shift));
    mod_map.insert(KEY_SEMICOLON, (KEY_LEFTCTRL, KEY_SEMICOLON, ModType::Ctrl));

    // Hand mapping is still needed for the remaining right-hand mods.
    let left_hand_keys = [1,2,3,4,5,6,15,16,17,18,19,20,30,31,32,33,34,42,44,45,46,47,48,58,29,56,125,57];
    let right_hand_keys = [7,8,9,10,11,12,13,14,21,22,23,24,25,26,27,35,36,37,38,39,40,43,54,49,50,51,52,53,97,100,28];
    for key in left_hand_keys.iter() { key_hand_map.insert(*key, Hand::Left); }
    for key in right_hand_keys.iter() { key_hand_map.insert(*key, Hand::Right); }

    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };
        let now = Instant::now();

        for (keycode, state) in key_states.iter_mut() {
            if state.is_held && !state.modifier_sent && now.duration_since(state.press_time).as_millis() > TAP_TIMEOUT_MS {
                let (modifier_code, _, _) = mod_map.get(keycode).unwrap();
                send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                send_event(&mut stdout, EV_SYN, 0, 0)?;
                state.modifier_sent = true;
            }
        }
        
        if event.ev_type != EV_KEY {
            stdout.write_all(&event_buffer)?; stdout.flush()?; continue;
        }

        let is_new_key_a_mod = mod_map.contains_key(&event.code);

        match event.value {
            1 => { // --- KEY PRESS ---
                let mut active_mod: Option<(u16, ModType, Hand)> = None;
                for (code, state) in key_states.iter() {
                    if state.modifier_sent {
                        if let Some((_, _, mod_type)) = mod_map.get(code) {
                            if let Some(hand) = key_hand_map.get(code) {
                                active_mod = Some((*code, *mod_type, *hand));
                                break;
                            }
                        }
                    }
                }

                if let Some((active_mod_code, active_mod_type, _)) = active_mod {
                    if is_new_key_a_mod {
                        let (_, tap_code, new_mod_type) = mod_map.get(&event.code).unwrap();
                        let new_key_hand = key_hand_map.get(&event.code).unwrap();

                        if active_mod_type == ModType::Shift {
                            send_key_tap(&mut stdout, *tap_code)?;
                            continue;
                        } else if active_mod_type == ModType::Ctrl {
                            let is_opposite_shift = *new_key_hand != *key_hand_map.get(&active_mod_code).unwrap() && *new_mod_type == ModType::Shift;
                            if !is_opposite_shift {
                                send_key_tap(&mut stdout, *tap_code)?;
                                continue;
                            }
                        }
                    }
                }
                
                let mut cancelled_keys = Vec::new();
                if let Some(new_key_hand) = key_hand_map.get(&event.code) {
                    for (mod_keycode, state) in key_states.iter_mut() {
                        if state.is_held && !state.modifier_sent {
                            if let Some(mod_key_hand) = key_hand_map.get(mod_keycode) {
                                if *new_key_hand != *mod_key_hand {
                                    let (modifier_code, _, _) = mod_map.get(mod_keycode).unwrap();
                                    send_event(&mut stdout, EV_KEY, *modifier_code, 1)?;
                                    send_event(&mut stdout, EV_SYN, 0, 0)?;
                                    state.modifier_sent = true;
                                } else {
                                    let (_, tap_code, _) = mod_map.get(mod_keycode).unwrap();
                                    send_key_tap(&mut stdout, *tap_code)?;
                                    cancelled_keys.push(*mod_keycode);
                                }
                            }
                        }
                    }
                }
                for key in cancelled_keys { key_states.remove(&key); }

                if is_new_key_a_mod {
                    key_states.insert(event.code, ModKeyState { is_held: true, press_time: now, modifier_sent: false });
                    continue;
                }
            },
            0 => { // --- KEY RELEASE ---
                if is_new_key_a_mod {
                    if let Some(state) = key_states.get_mut(&event.code) {
                        if state.modifier_sent {
                            let (modifier_code, _, _) = mod_map.get(&event.code).unwrap();
                            send_event(&mut stdout, EV_KEY, *modifier_code, 0)?;
                            send_event(&mut stdout, EV_SYN, 0, 0)?;
                        } else {
                            let (_, tap_code, _) = mod_map.get(&event.code).unwrap();
                            send_key_tap(&mut stdout, *tap_code)?;
                        }
                        key_states.remove(&event.code);
                        continue;
                    }
                }
            },
            _ => {}
        }

        stdout.write_all(&event_buffer)?;
        stdout.flush()?;
    }
    Ok(())
}
