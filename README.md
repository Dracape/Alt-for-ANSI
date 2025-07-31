[graphite]: https://github.com/rdavison/graphite-layout "Graphite is a highly optimized, well balanced, general purpose keyboard layout designed to accommodate the real world needs of typists looking for a great “out-of-the-box” experience. Its design incorporates many contemporary theories about layouts to find a balance between comfort and speed. In addition to its impressive performance in metrics, Graphite has also been extensively tested and validated through real-world usage."

# Introduction
Graphene is a fork of the [*Graphite* keyboard layout][graphite], optimized for traditional ANSI and ISO keyboards available for Linux

# Features added
- Angle mod
- **Swapped**
  - *Caps Lock* <—> *BackSpace*
  - **Mods**
    - **Left**
      - *Alt* -> *Shift*
      - *Shift* -> *Ctrl*
      - *Ctrl* -> *Alt*
    - **Right**
      - *Ctrl* <—> *Shift*
- Layers
  - **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for [*Graphite*][graphite] (made possible thanks to the unique symbol placements of [*Graphite*][graphite])
    - Navigation support
    - More symbols
  - Advanced navigation layer
- Minor optimisations in the layout for these improvements

# Preview
<table>
  <tr>
    <td><img width="1345" height="512" alt="Primary" src="https://github.com/user-attachments/assets/4dea3ea1-c684-4ec5-8133-8c27cdaf558d" /></td>
    <td><img width="1345" height="512" alt="Shift" src="https://github.com/user-attachments/assets/ae99a72e-e1b4-48f9-893a-a2774b75c7a3" /></td>
  </tr>
  <tr>
    <td><img width="1345" height="512" alt="Symbols" src="https://github.com/user-attachments/assets/1870d5c4-e04d-4f37-925f-ac0f5f92d597" /></td>
    <td><img width="1345" height="512" alt="Navigation" src="https://github.com/user-attachments/assets/80a2bcf7-a77a-49fb-b374-17ca6d91b724" /></td>
  </tr>
</table>

---

# Installation
## Startup
The layout for user sessions can be installed by running  
`sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/Dracape/graphene/main/install.sh)"`

But keep in mind that this script does the bare minimum entries just to get the layout working in the user session and is not enough to be used as a full installation.  
This script just installs the layout for the US keymap as a variant and only makes an entry in `/usr/share/X11/xkb/rules/evdev.xml`.  

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
