[night]: https://www.valorance.org/night/ "*Night* is an efficiency focused layout with specific targets for comfort. It differs from traditional layouts in using the letter R on the left thumb."

# Introduction
*Mid-Night* is an implementation of the [*Night* keyboard layout][night]—optimized for traditional full ANSI keyboards

# Features added
- **Mods**
    * Angle (first & bottom row)
    * Wide
    * Sticky (one-shot) shift
- **Swaps**
    * *BackSpace* ⟷ *Lock* (Base: *Shift*)
    * **Mods**: The position of mods are significantly changed, which can be reviewed better using the [preview](#preview)
- 3rd Layer
    * [***Arensito* symbol layer**](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout"): Improved and highly optimised
        - Navigation support
        - More symbols
- Non-standard symbols on top row

--- 

# Preview
> [!NOTE]
> Only the keys that are expected to be used are shown [^unpreserved-layer-keys/weird-layer-distro]

> [!NOTE]
> Color in tables is not supported on *GitHub*, use some other renderer (e.g. [*Apostrophe*](https://apps.gnome.org/Apostrophe/)) to view it colors that indicate the finger assigned to each key

### Base
| Shift (Right) | “ | → | Control | – | % |  |  |  | — | Control | \| | ” | Caps-Lock |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | q\|b | f | l | k |  | Escape | p | g | o | u | . | : | Insert |
| BackSpace | n | s | h | t | m | Sticky Shift | y | c | a | e | i | ? |  |
|  | x | v | j | d | z | Home | End | ' | w | / | - | , |  |
| Back | Alt | r |  |  |  |  | Space | AltGr | Super (Left) |  |  | Forward |  |
#### Top row usage
The top row is made keeping stretches in mind
- normally, you are only expected to use the keys here not available in the symbols layer
- The other keys are only meant to be used when you are using numpad/mouse, and *AltGr* ins't accessible
### Shift
| **Shift** (Right) |  |  | Control |  |  |  |  |  | ] | Control | ) |  |  |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | Q\|B | F | L | K |  | Menu | P | G | O | U |  | ~ |  |
| BackSpace | N | S | H | T | M | **Sticky Shift** | Y | C | A | E | I | ⸮ | |
|  | X | V | J | D | Z | Home | End | " | W | > | _ | < |  |
| Back | Alt |  |  |  |  |  | Space | AltGr | Super |  |  | Forward |  |

### Symbol (AltGr)
|  |  |  | Control | } |  |  |  |  | ] | Control | ) |  |  |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | !\|@ | {} | [] | = |  | Menu | ^ | # | () | $ | ` |  |  |
| Delete | 1 | ; | Enter | 0 | & | Sticky Shift | \\ | Left | Up | Down | Right | ← |  |
|  | 2 | 3 | 4 | 5 | + | Page Up | Page Down | * | 6 | 7 | 8 | 9 |  |
| Back | Alt |  |  |  |  |  | Space | **AltGr** | Super |  |  | Forward |  |

# Unusual things
### Unusual brackets
It is assumed that your typing program automatically paires the brackets; if it doesn't, the closing keys are provided in the top row.
> [!TIP]
> Use [*Input-Remapper*](https://github.com/sezanzeb/input-remapper)—along with [this configuration](./input-remapper-config.md) for auto-pairing
#### Closing bracket layer usage
- **Symbol**: When used together; close pair with the same modifier
- **Shift**: When used dispersed; alterate the pair with different modifiers 
### Page up and Page down in different layers[^unpreserved-layer-keys/weird-layer-distro]


[^unpreserved-layer-keys/weird-layer-distro]: This layout treats *Shift* and *AltGr* as modifiers that are assigned to a thumb on each hand instead of layer switchers; Sometimes some keys are at uncomfortable positions and thus, don't have a third key assigned to them.  
  In a typical layout, the 2nd keys would go to the 2nd layer; while in *Graphene*, if they are in the left side, they are put in the *Symbol* layer so that the alternate hand can be used so press it (for ergonomics)
