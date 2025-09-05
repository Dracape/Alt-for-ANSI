# Introduction
This repository contains
- [Graphene](./layouts/graphene/README.md)
- [Mid-Night](./layouts/midnight/README.md)

keyboard layouts, that are implementation of the 2 highest rated keyboard layouts—known for their own quirks

# **Common** Features added
- **Mods**
  - Angle
  - Wide
- **Swap**
  - *Caps Lock* <—> *BackSpace*

- Layers
  - **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for the implementations
    - Navigation support
    - More symbols

---

# Installation (*Linux*)
## Startup
The layout for user sessions can be installed by running  
`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dracape/modANSI/main/install.sh)"`  
Keep in mind that this script only provides the bare minimum configuration—to get the layout working in the user session; it is not sufficient for a full installation.  
This script installs the layout as a US keymap variant—making an entry only in `/usr/share/xkeyboard-config-2/rules/evdev.xml`.

It's just so that you can get your hands working

## Further setup
**1**. Make entries for the other files  
> [!TIP]
> at ``/usr/share/xkeyboard-config-2/rules/``

**2**. set the layout as default for outside user sessions (such as *Display Manager*)
> [!TIP]
> use `localectl`  
> **Example**: `localectl set-x11-keymap us pc105 midnight`
  
**3**. Set the layout as the default for any new users created (optional)
> [!TIP]
> in `/etc/default/keyboard`

[^unpreserved-layer-keys/weird-layer-distro]: This layout treats *Shift* and *AltGr* as modifiers that are assigned to a thumb on each hand instead of layer switchers; Sometimes some keys are at unconfortable positions and thus, don't have a third key assigned to them.  
  In a typical layout, the 2nd keys would go to the 2nd layer; while in *Graphene*, if they are in the left side, they are put in the *Symbol* layer so that the alternate hand can be used so press it (for ergonomics)
