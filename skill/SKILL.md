---
name: fig
description: "AI-assisted Figma design via figma-use CDP. Use when the user says 'fig', 'fig setup', 'fig stop', 'start figma', 'figma setup', 'AI design setup', or wants to control Figma from Claude Code. Covers launch, daily workflow, tool reference, and safeguards. macOS only."
---

# fig — AI-Assisted Figma Design

Control Figma directly from Claude Code. No plugins, no tokens, no bridge. Just `fig` to start, `fig stop` when done. **macOS only.**

figma-use (https://github.com/dannote/figma-use) connects to Figma Desktop via Chrome DevTools Protocol (CDP). It gives Claude Code 118+ tools to read, write, query, lint, and render designs — including JSX rendering.

**Full documentation:** https://github.com/dannote/figma-use/blob/master/README.md
**Full command reference:** https://github.com/dannote/figma-use/blob/master/REFERENCE.md
**MCP setup:** https://github.com/dannote/figma-use/blob/master/MCP.md

If you don't know how to do something with figma-use, read the README above before guessing.

---

## Safeguards (ALWAYS follow these)

This gives you full read/write access to Figma. That includes the ability to DELETE anything. Follow these rules:

- **NEVER** delete pages, frames, or components without explicitly asking the user first
- **NEVER** navigate to or modify a different Figma file than the one the user is working in
- **ALWAYS** describe what you're about to create or change BEFORE executing the action
- **ALWAYS** work on the current page unless the user specifically asks to switch pages
- When creating new elements, place them in empty canvas space — don't overlap existing work
- If the user shares a Figma file URL, only work within that specific file
- If you're unsure whether an action is destructive, ask before doing it
- Prefer creating NEW frames over modifying existing ones — let the user decide what to keep

---

## Commands

| Command | What it does |
|---------|-------------|
| `fig` | Launches Figma with AI access + starts the MCP server |
| `fig stop` | Stops the MCP server (Figma stays open) |
| `fig restart` | Stops and restarts everything |
| `fig status` | Shows whether Figma CDP and MCP server are running |

---

## Two Modes

### Imperative — one command at a time (via MCP tools)

Each CLI command maps to an MCP tool with `figma_` prefix:

```
figma-use create frame → figma_create_frame
figma-use set fill    → figma_set_fill
figma-use query       → figma_query
```

### Declarative — JSX rendering

LLMs think in React. figma-use renders JSX directly into Figma:

```tsx
<Frame style={{p: 24, gap: 16, flex: "col", bg: "#FFF", rounded: 12}}>
  <Text style={{size: 24, weight: "bold", color: "#000"}}>Card Title</Text>
  <Text style={{size: 14, color: "#666"}}>Description text</Text>
</Frame>
```

**Elements:** `Frame`, `Rectangle`, `Ellipse`, `Text`, `Line`, `Star`, `Polygon`, `Vector`, `Group`, `Icon`, `Image`

---

## Inline Tool Reference

### Create

```bash
figma-use create frame --width 400 --height 300 --fill "#FFF" --radius 12 --layout VERTICAL --gap 16
figma-use create text "Hello" --size 24 --weight bold --color "#000" --font "Inter"
figma-use create rectangle --width 100 --height 100 --fill "#3B82F6" --radius 8
figma-use create ellipse --width 80 --height 80 --fill "#EF4444"
figma-use create icon mdi:home --size 32 --color "#3B82F6"
figma-use create icon lucide:star --size 48 --color "#F59E0B"
figma-use create line --length 200 --stroke "#000" --stroke-weight 2
figma-use create component --name "Button" --width 120 --height 44 --fill "#3B82F6" --layout HORIZONTAL --gap 8
```

### Set / Modify

```bash
figma-use set fill <id> "#FF0000"
figma-use set fill <id> "var:Colors/Primary"       # Bind to Figma variable
figma-use set stroke <id> "#000" --weight 2
figma-use set text <id> "New text content"
figma-use set font <id> --family "Inter" --size 16 --weight 600
figma-use set size <id> --width 400 --height 300
figma-use set position <id> --x 100 --y 200
figma-use set radius <id> 12                        # All corners
figma-use set radius <id> --tl 12 --tr 12           # Individual corners
figma-use set opacity <id> 0.5
figma-use set layout <id> --mode VERTICAL --gap 16 --padding 24
figma-use set layout <id> --mode HORIZONTAL --gap 8 --align CENTER
figma-use set layout <id> --mode GRID --cols "1fr 1fr 1fr" --gap 16
figma-use set name <id> "New Name"
figma-use set constraints <id> --horizontal STRETCH --vertical TOP
figma-use set effects <id> --shadow "0 4 12 rgba(0,0,0,0.1)"
```

### Read / Inspect

```bash
figma-use status                    # Check connection
figma-use node get <id>             # Full node details
figma-use node tree                 # Page tree (readable)
figma-use node children <id>        # Direct children
figma-use page list                 # All pages
figma-use page current              # Current page name + ID
```

### Query (XPath)

```bash
figma-use query "//FRAME"                                    # All frames
figma-use query "//FRAME[@width < 300]"                      # Narrower than 300px
figma-use query "//COMPONENT[starts-with(@name, 'Button')]"  # Name starts with
figma-use query "//FRAME[contains(@name, 'Card')]"           # Name contains
figma-use query "//SECTION/FRAME"                            # Direct children of sections
figma-use query "//SECTION//TEXT"                             # All text in sections
figma-use query "//*[@cornerRadius > 0]"                     # Any node with radius
```

### Export

```bash
figma-use export node <id> --format png --scale 2
figma-use export node <id> --format svg
figma-use export jsx <id> --pretty                           # Node → JSX code
figma-use export jsx <id> --match-icons --prefer-icons lucide
figma-use export storybook --out ./stories                   # Components → Storybook
figma-use diff jsx <id1> <id2>                               # Compare two nodes as JSX
```

### Render (JSX)

```bash
echo '<Frame style={{p: 24, gap: 16, flex: "col", bg: "#FFF", rounded: 12}}>
  <Text style={{size: 24, weight: "bold"}}>Title</Text>
</Frame>' | figma-use render --stdin --x 100 --y 200
```

Or render a `.figma.tsx` file:
```bash
figma-use render ./my-component.figma.tsx
```

### Analyze

```bash
figma-use analyze clusters                       # Find repeated patterns
figma-use analyze colors                         # Color palette usage
figma-use analyze colors --show-similar          # Find mergeable colors
figma-use analyze typography                     # All font combinations
figma-use analyze typography --group-by size
figma-use analyze spacing --grid 8               # Gap/padding + grid compliance
figma-use analyze snapshot                       # Accessibility snapshot
figma-use analyze snapshot <id> -i               # Interactive elements only
```

### Lint

```bash
figma-use lint                          # Recommended rules
figma-use lint --page "Components"      # Lint specific page
figma-use lint --preset strict          # Stricter for production
figma-use lint --preset accessibility   # A11y checks only
figma-use lint -v                       # With fix suggestions
figma-use lint --json > report.json     # JSON output for CI/CD
```

**17 rules:** no-hardcoded-colors, consistent-spacing, consistent-radius, effect-style-required, prefer-auto-layout, pixel-perfect, text-style-required, min-text-size, no-mixed-styles, color-contrast, touch-target-size, no-default-names, no-hidden-layers, no-deeply-nested, no-empty-frames, no-groups, no-detached-instances

### Arrange

```bash
figma-use arrange                              # Grid-arrange all top-level nodes
figma-use arrange --mode row --gap 60          # Horizontal row
figma-use arrange --mode squarify --gap 60     # Smart packing for mixed sizes
```

### Comments

```bash
figma-use comment watch --json   # Block until new comment appears
figma-use comment resolve <id>   # Mark comment as done
```

### Variables

```bash
figma-use variable list                              # All variables
figma-use variable get <id>                          # Variable details
figma-use variable set <id> --value "#FF0000"        # Update value
figma-use variable create --name "Primary" --collection "Colors" --value "#3B82F6"
```

### Other

```bash
figma-use node clone <id>                    # Duplicate a node
figma-use node delete <id>                   # Delete (ask user first!)
figma-use node move <id> --x 100 --y 200     # Move node
figma-use node resize <id> --width 400 --height 300
figma-use find text "Button"                 # Find by text content
figma-use find name "Header"                 # Find by node name
figma-use select <id>                        # Select node in Figma
figma-use viewport set --x 0 --y 0 --zoom 1 # Set viewport
figma-use page go "Page 2"                   # Switch page
figma-use import svg ./icon.svg              # Import SVG
figma-use path get <id>                      # Get vector path data
figma-use path set <id> "M 0 0 L 100 100 Z" # Set vector path
figma-use diff create --from <id1> --to <id2>  # Structural diff
figma-use diff visual --from <id1> --to <id2> --output diff.png  # Visual diff
```

---

## JSX Style Shorthands

### Size & Position

| Shorthand | Figma Property |
|-----------|---------------|
| `w` | width |
| `h` | height |
| `minW`, `maxW` | min/max width |
| `minH`, `maxH` | min/max height |
| `x`, `y` | position |

### Layout

| Shorthand | Figma Property |
|-----------|---------------|
| `flex: "col"` | VERTICAL auto layout |
| `flex: "row"` | HORIZONTAL auto layout |
| `gap` | itemSpacing |
| `p` | padding (all sides) |
| `px`, `py` | horizontal/vertical padding |
| `pt`, `pr`, `pb`, `pl` | individual padding |
| `align` | counterAxisAlignItems (MIN/CENTER/MAX) |
| `justify` | primaryAxisAlignItems (MIN/CENTER/MAX/SPACE_BETWEEN) |
| `wrap` | layoutWrap (WRAP/NO_WRAP) |

### Grid

| Shorthand | Figma Property |
|-----------|---------------|
| `display: "grid"` | Enable grid layout |
| `cols` | Column template ("1fr 1fr 1fr") |
| `rows` | Row template ("auto auto") |
| `colGap`, `rowGap` | Separate gap values |

### Appearance

| Shorthand | Figma Property |
|-----------|---------------|
| `bg` | fills (solid color) |
| `opacity` | opacity (0-1) |
| `visible` | visible |
| `stroke` | strokes color |
| `strokeWeight` | strokeWeight |
| `strokeAlign` | strokeAlign (INSIDE/OUTSIDE/CENTER) |

### Corners

| Shorthand | Figma Property |
|-----------|---------------|
| `rounded` | cornerRadius (all) |
| `roundedTL`, `roundedTR`, `roundedBL`, `roundedBR` | individual corners |

### Effects

| Shorthand | Figma Property |
|-----------|---------------|
| `shadow` | drop shadow ("x y blur color") |
| `innerShadow` | inner shadow |
| `blur` | layer blur |
| `bgBlur` | background blur |

### Text

| Shorthand | Figma Property |
|-----------|---------------|
| `size` | fontSize |
| `weight` | fontWeight ("bold", 600, etc.) |
| `family` | fontFamily |
| `color` | fills (text color) |
| `align` | textAlignHorizontal |
| `valign` | textAlignVertical |
| `lineHeight` | lineHeight |
| `letterSpacing` | letterSpacing |
| `decoration` | textDecoration (UNDERLINE/STRIKETHROUGH) |
| `truncate` | textTruncation (ENDING) |
| `maxLines` | maxLines |

---

## Icons

150,000+ icons from Iconify. Browse: https://icon-sets.iconify.design/

```bash
figma-use create icon mdi:home --size 24 --color "#3B82F6"
figma-use create icon lucide:star --size 48 --color "#F59E0B"
figma-use create icon tabler:settings --size 32
```

In JSX:
```tsx
<Icon icon="mdi:home" size={24} color="#3B82F6" />
<Icon icon="lucide:search" size={20} color="#666" />
```

**Popular sets:** `lucide`, `mdi`, `tabler`, `heroicons`, `phosphor`, `radix-icons`

---

## Images

```tsx
<Image src="https://example.com/photo.jpg" w={200} h={150} />
```

---

## Components & Variants

### Simple component (first call creates master, rest create instances):

```tsx
import { defineComponent, Frame, Text } from 'figma-use/render'

const Card = defineComponent('Card',
  <Frame style={{ p: 24, bg: '#FFF', rounded: 12 }}>
    <Text style={{ size: 18, color: '#000' }}>Card</Text>
  </Frame>
)

export default () => (
  <Frame style={{ gap: 16, flex: 'row' }}>
    <Card />
    <Card />
  </Frame>
)
```

### Component set with variants:

```tsx
import { defineComponentSet, Frame, Text } from 'figma-use/render'

const Button = defineComponentSet('Button',
  { variant: ['Primary', 'Secondary'] as const, size: ['Small', 'Large'] as const },
  ({ variant, size }) => (
    <Frame style={{
      p: size === 'Large' ? 16 : 8,
      bg: variant === 'Primary' ? '#3B82F6' : '#E5E7EB',
      rounded: 8
    }}>
      <Text style={{ color: variant === 'Primary' ? '#FFF' : '#111' }}>
        {variant} {size}
      </Text>
    </Frame>
  )
)
```

### Variables as tokens:

```tsx
import { defineVars, Frame, Text } from 'figma-use/render'

const colors = defineVars({
  bg: { name: 'Colors/Gray/50', value: '#F8FAFC' },
  text: { name: 'Colors/Gray/900', value: '#0F172A' }
})

export default () => (
  <Frame style={{ bg: colors.bg }}>
    <Text style={{ color: colors.text }}>Bound to variables</Text>
  </Frame>
)
```

---

## Best Practices

1. **Always verify after creating.** Use `figma-use node tree` or `figma-use node get <id>` to confirm what you built matches intent.

2. **Place new work in empty space.** Check existing node positions with `figma-use node tree` first. Offset new frames to avoid overlapping.

3. **Use `figma-use arrange` after batch creation.** When creating multiple frames, they often land at the same position. Run `arrange` to tidy up.

4. **Prefer JSX for complex layouts.** A single `render` call creates an entire tree atomically — faster and more reliable than dozens of individual create + set commands.

5. **Use node IDs from tool responses.** Every create command returns the new node's ID. Use it for subsequent operations. Don't guess IDs.

6. **Run `figma-use lint` before finishing.** Quick accessibility and consistency check.

7. **Use sections to organize.** Create sections for distinct design areas: `figma-use create section --name "Hero Variants"`.

8. **Variables over hardcoded colors.** Use `var:Colors/Primary` or `$Colors/Primary` in any color option to bind to Figma variables.

9. **Comment-driven workflow.** For async collaboration: `figma-use comment watch --json` blocks until a new Figma comment appears, then you can process and resolve it.

10. **Export JSX to bridge to code.** `figma-use export jsx <id> --pretty` converts any Figma node to JSX — useful for handoff.

---

## Architecture

```
Terminal                         Figma Desktop
  fig command                    (Electron/Chromium)
    |                                  |
    +-- Launches Figma with            |
    |   --remote-debugging-port=9222   |
    |                                  |
    +-- Starts MCP server ----CDP----> Port 9222
        (port 38451)                   |
           |                     Runtime.evaluate
           |                     (figma-use injects
    Claude Code <---MCP---+      RPC into Figma's
    (118 tools)            \     JS context)
                            \        |
                             +-------+
```

No plugins. No tokens. No bridge. Just CDP.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "fig: Figma failed to start" | Quit Figma completely (Cmd+Q), then run `fig` again |
| "fig: MCP server failed" | Run `cd ~/figma-use && bun install` then try again |
| Claude Code doesn't see figma tools | Make sure `fig` is running, then restart Claude Code |
| Tools show "disconnected" | Run `fig restart`, then restart Claude Code |
| "Command not found: fig" | Run `source ~/.zshrc` or open a new terminal |
| "Command not found: bun" | Run `curl -fsSL https://bun.sh/install | bash` then `source ~/.zshrc` |
| Figma tools were working but stopped | Run `fig restart` — the MCP server may have died |
| Need to find a specific tool | Check https://github.com/dannote/figma-use/blob/master/REFERENCE.md |
