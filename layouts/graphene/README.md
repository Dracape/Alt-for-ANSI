[graphite]: https://github.com/rdavison/graphite-layout "Graphite is a highly optimized, well balanced, general purpose keyboard layout designed to accommodate the real world needs of typists looking for a great “out-of-the-box” experience. Its design incorporates many contemporary theories about layouts to find a balance between comfort and speed. In addition to its impressive performance in metrics, Graphite has also been extensively tested and validated through real-world usage."

# Introduction
*Graphene* is a implementation of the [*Graphite* keyboard layout][graphite]—optimized for traditional full ANSI keyboards

# Features added
- **Mods**
  - Angle
  - Wide
- **Swaps**
  - *Caps Lock* <—> *BackSpace*
  - **Mods**: The position of mods are significantly changed, which can be reviewed better using the [preview](#preview)
- 3rd Layer
  - **[*Arensito* symbol layer](https://www.pvv.org/~hakonhal/main.cgi/keyboard "The homepage for the *Arensito* layout")**: Improved and highly optimised for [*Graphite*][graphite]
    - Navigation support
    - More symbols
- Minor optimisations in the layout for these improvements

---

# Preview
> [!NOTE]
> Only the keys that are expected to be used are shown  

> [!NOTE]
> Empty space in the upper layers generally[^unpreserved-layer-keys/weird-layer-distro] mean—keys from the *Base* layer are used  
### Base
| | | | Alt | % | – | | | | — | Alt | \| | • |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | b | l | d | w | z | Esc | ' | f | o | u | j | ; |
| BackSpace | n | r | t | s | g | Home | y | h | a | e | i | , |
| | Ctrl | x | m | c | q\|v | End | k | p | . | - | / | |
| | Super | Shift | | | | | Space | AltGr | | | | |
#### Top row usage
The top row is made keeping stretches in mind
- normally, you are only expected to use the keys here not available in the symbols layer
- The other keys are only meant to be used when you are using numpad/mouse, and *AltGr* ins't accessible
### Shift
| | | | Alt | | | | | | ] | Alt | ) | |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | B | L | D | W | Z | | " | F | O | U | J | : |
| BackSpace | N | R | T | S | G | | Y | H | A | E | I | ? | |
| | Ctrl | X | M | C | Q\|V | Page Down | K | P | > | _ | < | |
| | Super | **Shift** | | | | | Space | AltGr | | | | |

### Symbol (AltGr)
| | | | Alt | } | | | | | ] | Alt | ) | |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Tab | ! | { | [ | # | = | Insert | ^ | @ | ( | $ | ` | |
| Delete | 1 | ~ | Return | 0 | & | Page Up | \ | Left | Up | Down | Right | |
| | Ctrl | 2 | 3 | 4 | 5\|+ | | * | 6 | 7 | 8 | 9 | |
| | Super | Shift | | | | | Space | **AltGr** | | | | |
#### Unusual brackets
It is assumed that your typing program automatically paires the brackets; if it doesn't, the closing keys are provided in the top row
##### Closing bracket layer usage
- **Symbol**: When used together; close pair with the same modifier
- **Shift**: When used dispersed; alterate the pair with different modifiers 
#### Page up and Page down in different layers[^unpreserved-layer-keys/weird-layer-distro]


[^unpreserved-layer-keys/weird-layer-distro]: This layout treats *Shift* and *AltGr* as modifiers that are assigned to a thumb on each hand instead of layer switchers; Sometimes some keys are at unconfortable positions and thus, don't have a third key assigned to them.  
  In a typical layout, the 2nd keys would go to the 2nd layer; while in *Graphene*, if they are in the left side, they are put in the *Symbol* layer so that the alternate hand can be used so press it (for ergonomics)
