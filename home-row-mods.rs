use std::collections::HashMap;
use std::io::{self, Read, Write};
use std::mem;
use std::time::Instant;
const TAP_TIMEOUT_MS: u128 = 200;
#[repr(C)] #[derive(Copy, Clone, Debug)]
struct InputEvent { tv_sec: i64, tv_usec: i64, ev_type: u16, code: u16, value: i32 }
const EV_KEY: u16 = 0x01; const EV_SYN: u16 = 0x00;
const KEY_A: u16 = 30; const KEY_S: u16 = 31; const KEY_D: u16 = 32; const KEY_F: u16 = 33;
const KEY_J: u16 = 36; const KEY_K: u16 = 37; const KEY_L: u16 = 38; const KEY_SEMICOLON: u16 = 39;
const KEY_LEFTCTRL: u16 = 29; const KEY_LEFTSHIFT: u16 = 42;
const KEY_LEFTALT: u16 = 56;  const KEY_LEFTMETA: u16 = 125;
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
    let mut stdin = io::stdin().lock(); let mut stdout = io::stdout().lock();
    let mut event_buffer = [0u8; mem::size_of::<InputEvent>()];
    let mut mod_map = HashMap::new();
    mod_map.insert(KEY_A, (KEY_LEFTCTRL, KEY_A)); mod_map.insert(KEY_S, (KEY_LEFTSHIFT, KEY_S));
    mod_map.insert(KEY_D, (KEY_LEFTALT, KEY_D)); mod_map.insert(KEY_F, (KEY_LEFTMETA, KEY_F));
    mod_map.insert(KEY_J, (KEY_LEFTMETA, KEY_J)); mod_map.insert(KEY_K, (KEY_LEFTALT, KEY_K));
    mod_map.insert(KEY_L, (KEY_LEFTSHIFT, KEY_L)); mod_map.insert(KEY_SEMICOLON, (KEY_LEFTCTRL, KEY_SEMICOLON));
    let mut key_states: HashMap<u16, ModKeyState> = HashMap::new();
    while let Ok(()) = stdin.read_exact(&mut event_buffer) {
        let event: InputEvent = unsafe { mem::transmute(event_buffer) };
        let now = Instant::now();
        for (keycode, state) in key_states.iter_mut() {
            if state.is_held && !state.modifier_sent && now.duration_since(state.press_time).as_millis() > TAP_TIMEOUT_MS {
                let (modifier_code, _) = mod_map.get(keycode).unwrap();
                send_event(&mut stdout, EV_KEY, *modifier_code, 1)?; send_event(&mut stdout, EV_SYN, 0, 0)?;
                state.modifier_sent = true;
            }
        }
        let is_mod_key = mod_map.contains_key(&event.code);
        if event.ev_type == EV_KEY && is_mod_key {
            let (modifier_code, tap_code) = mod_map.get(&event.code).unwrap();
            if event.value == 1 { key_states.insert(event.code, ModKeyState { is_held: true, press_time: Instant::now(), modifier_sent: false }); continue; }
            if event.value == 0 {
                if let Some(state) = key_states.get_mut(&event.code) {
                    if state.modifier_sent { send_event(&mut stdout, EV_KEY, *modifier_code, 0)?; } else { send_key_tap(&mut stdout, *tap_code)?; }
                    key_states.remove(&event.code); continue;
                }
            }
        } else if event.ev_type == EV_KEY && event.value == 1 {
            for (keycode, state) in key_states.iter_mut() {
                if state.is_held && !state.modifier_sent {
                    let (modifier_code, _) = mod_map.get(keycode).unwrap();
                    send_event(&mut stdout, EV_KEY, *modifier_code, 1)?; send_event(&mut stdout, EV_SYN, 0, 0)?;
                    state.modifier_sent = true;
                }
            }
        }
        stdout.write_all(&event_buffer)?; stdout.flush()?;
    }
    Ok(())
}
