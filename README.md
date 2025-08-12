[graphite]: https://github.com/rdavison/graphite-layout "Graphite is a highly optimized, well balanced, general purpose keyboard layout designed to accommodate the real world needs of typists looking for a great “out-of-the-box” experience. Its design incorporates many contemporary theories about layouts to find a balance between comfort and speed. In addition to its impressive performance in metrics, Graphite has also been extensively tested and validated through real-world usage."

# Introduction
Graphene is a fork of the [*Graphite* keyboard layout][graphite]—optimized for traditional full ANSI and ISO keyboards—available for Linux

# Features added
- **Mods**
  - Angle
  - Wide
- **Swaps**
  - *Caps Lock* <—> *BackSpace*
  - **Mods**
    - **Left**
      - *Alt* -> *Shift*
      - *Shift* -> *Ctrl*
      - *Ctrl* -> *Alt*
    - **Right**
      - *Ctrl* -> *Shift*
      - *Shift* -> Used in wide mod
- Layers
  - **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for [*Graphite*][graphite] (made possible thanks to the unique symbol placements of [*Graphite*][graphite])
    - Navigation support
    - More symbols
  - Advanced navigation layer
- Minor optimisations in the layout for these improvements

# Preview
(to be added)

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
