[graphite]: https://github.com/rdavison/graphite-layout "Graphite is a highly optimized, well balanced, general purpose keyboard layout designed to accommodate the real world needs of typists looking for a great “out-of-the-box” experience. Its design incorporates many contemporary theories about layouts to find a balance between comfort and speed. In addition to its impressive performance in metrics, Graphite has also been extensively tested and validated through real-world usage."

# Introduction
Graphene is a fork of the [*Graphite* keyboard layout][graphite]—optimized for traditional full ANSI and ISO keyboards—available for Linux

# Features added
- **Mods**
  - Angle
  - Wide
- **Swapped**
  - *Caps Lock* <—> *BackSpace*
  - **Mods**
    - **Left**
      - *Alt* -> *Shift*
      - *Shift* -> *Ctrl*
      - *Ctrl* -> *Alt*
    - **Right**
      - *Ctrl* —> *Shift*
      - *Shift* —> Used in wide mod
- Layers
  - **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for [*Graphite*][graphite] (made possible thanks to the unique symbol placements of [*Graphite*][graphite])
    - Navigation support
    - More symbols
  - Advanced navigation layer
- Minor optimisations in the layout for these improvements

# Preview
<table>
  <tr>
    <td><img width="1358" height="518" alt="Primary" src="https://github.com/user-attachments/assets/2eeba5ca-ac3c-4552-b68c-b6042ce3e710" /></td>
    <td><img width="1358" height="518" alt="Shift" src="https://github.com/user-attachments/assets/069e7505-4bda-4a4a-919e-e4eb225fd387" /></td>
  </tr>
  <tr>
    <td><img width="1358" height="518" alt="Symbols" src="https://github.com/user-attachments/assets/9cc70a95-b0d1-48bd-9294-6b0b6edc061f" /></td>
    <td><img width="1358" height="518" alt="Advanced" src="https://github.com/user-attachments/assets/e91d22d6-306a-463a-9977-e0cbfd8c9e80" /></td>
  </tr>
</table>

---

# Installation
## Startup
The layout for user sessions can be installed by running  
`sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/Dracape/graphene/main/install.sh)"`
Keep in mind that this script only provides the bare minimum configuration to get the layout working in the user session; it is not sufficient for a full installation.
This script installs the layout as a US keymap variant—making an entry only in `/usr/share/X11/xkb/rules/evdev.xml`.

It's just so that you can get your hands working

## Further setup
**1**. Make entries for the other files  
> [!TIP]
> at ``/usr/share/X11/xkb/rules/``

**2**. set the layout as default for outside user sessions (such as a *display manager*)
> [!TIP]
> use `localectl`
  
**3**. Set the layout as the default for any new users created (optional)
> [!TIP]
> in `/etc/default/keyboard`
