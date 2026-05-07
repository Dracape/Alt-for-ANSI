# Introduction
This repository contains
- [Graphene](./layouts/graphene/README.md)
- [Mid-Night](./layouts/midnight/README.md)

keyboard layouts, that are implementations of the 2 highest rated keyboard layouts—known for their own quirks

# **Common** Features added
- **Mods**
    * Angle (first & bottom row)
    * Wide
    * Sticky (one-shot) shift
- **Swap**: *Caps Lock* ↔ *BackSpace*
- Layers
    * **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for the implementations
        - Navigation support
        - More symbols
- Non-standard symbols on top row

---

# Installation (*Linux*)
## Initial
The layouts can be installed by running  
`curl -fsSL https://raw.githubusercontent.com/Drazape/Alt-for-ANSI/main/install.sh | bash`

## Further
##### Set the layout as the default for any new users created (optional)
Edit `/etc/default/keyboard`
> [!TIP]
> Set the `XKBVARIANT` value
> - `graphene`
> - `midnight`
