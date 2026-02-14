# FigShift

Control Figma with AI. One command to start, Claude Code does the rest.

FigShift wraps [figma-use](https://github.com/mds/figma-use) with a clean setup experience, a Claude Code skill for ongoing design guidance, and a `fig` shell command for daily use. No plugins, no tokens, no bridge.

## What You Get

- **`fig`** — one command to launch Figma with AI access and start the MCP server
- **118+ tools** — create, query, style, render JSX, lint, export, analyze designs
- **Claude Code skill** — inline tool reference so Claude knows how to use every tool without looking anything up
- **Safeguards** — rules that prevent Claude from deleting your work or touching the wrong file

## How It Works

```
Terminal: fig
  → Launches Figma with Chrome DevTools Protocol (port 9222)
  → Starts MCP server (port 38451)
  → Claude Code connects automatically
  → 118 tools available: create, query, style, render, export, lint
```

No Figma plugins. No personal access tokens. No bridge apps. Just CDP.

## Setup (5 minutes)

**Requirements:** Mac, Figma Desktop (signed in), Claude Code (with Max subscription or API key)

### Option A: Paste the setup prompt into Claude Code

1. Open Claude Code in any terminal
2. Copy the contents of [`setup-prompt.md`](./setup-prompt.md) and paste it in
3. Claude handles everything — installs dependencies, adds the `fig` command, registers the MCP server
4. Done

### Option B: Manual setup

1. Install prerequisites: Node.js, [Bun](https://bun.sh), git

2. Install figma-use and clone the repo:
```bash
npm install -g figma-use
git clone --depth 1 https://github.com/mds/figma-use.git ~/figma-use
cd ~/figma-use && bun install
```

3. Add the `fig` command to your shell — copy [`fig.sh`](./fig.sh) into your `~/.zshrc`:
```bash
cat fig.sh >> ~/.zshrc && source ~/.zshrc
```

4. Register the MCP server with Claude Code:
```bash
claude mcp add -s user --transport http figma-use http://localhost:38451/mcp
```

5. Remove any conflicting Figma MCP servers:
```bash
# Check for existing Figma servers
claude mcp list 2>&1 | grep -i figma
# Remove any found (figma-use replaces them all):
# claude mcp remove figma-console -s user
# claude mcp remove figma -s user
```

6. Install the Claude Code skill — copy [`skill/SKILL.md`](./skill/SKILL.md) into your project's `.claude/skills/fig/` directory.

## Daily Use

**Before each session:**
- Make sure you're signed into Figma
- If Figma is open, let saves finish first
- Close Claude Code if it's already running — reopen it after `fig` starts

**Start:**
```bash
fig                # Launches Figma + MCP server
```

**Open Claude Code** and tell it what to design:
- "Create a hero section with a heading, subtext, and CTA button"
- "Build a pricing table with 3 tiers"
- "Lint this page for accessibility issues"
- "Export that frame as JSX"
- "Render this JSX in Figma: `<Frame>...</Frame>`"

**Stop:**
```bash
fig stop           # Stops the MCP server (Figma stays open)
```

**Other commands:**
```bash
fig status         # Check what's running
fig restart        # Stop and restart everything
```

## What's in This Repo

| File | What it does |
|------|-------------|
| [`README.md`](./README.md) | You're reading it |
| [`setup-prompt.md`](./setup-prompt.md) | Paste into Claude Code for zero-config setup |
| [`skill/SKILL.md`](./skill/SKILL.md) | Claude Code skill — inline tool reference, JSX shorthands, icons, components, best practices, safeguards, troubleshooting |
| [`fig.sh`](./fig.sh) | The `fig` shell function (sourceable) |

## Safeguards

FigShift gives Claude Code **full read/write access** to your open Figma files. That includes the ability to delete things.

**Protect yourself:**
- Work in a **dedicated Figma file** for AI design — not your production files
- Cmd+Z works for AI actions, same as manual ones
- Version history in Figma lets you restore any previous state

**The skill file protects you too** — it instructs Claude to:
- Never delete without asking first
- Always describe changes before making them
- Stay in the current file and page
- Prefer creating new frames over modifying existing ones

## Documentation

- **figma-use README:** https://github.com/mds/figma-use/blob/master/README.md
- **Full command reference (118+ tools):** https://github.com/mds/figma-use/blob/master/REFERENCE.md
- **MCP server setup:** https://github.com/mds/figma-use/blob/master/MCP.md
- **figma-use skill (upstream):** https://github.com/mds/figma-use/blob/master/SKILL.md

## Architecture

FigShift is a UX layer on top of [figma-use](https://github.com/mds/figma-use). figma-use does the heavy lifting — 118+ MCP tools that control Figma via Chrome DevTools Protocol. FigShift adds:

1. **Setup prompt** — one paste gets everything installed
2. **Skill file** — ongoing guidance so Claude uses the tools well
3. **fig command** — daily driver that handles Figma launch, MCP server, and connection management
4. **Safeguards** — rules to prevent destructive actions

```
┌──────────────────────────────────────────────┐
│  FigShift (this repo)                        │
│  Setup prompt + Skill + fig command          │
├──────────────────────────────────────────────┤
│  figma-use (engine)                          │
│  118+ MCP tools, JSX rendering, CDP          │
├──────────────────────────────────────────────┤
│  Figma Desktop                               │
│  Chrome DevTools Protocol (port 9222)        │
└──────────────────────────────────────────────┘
```

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
| Need to find a specific tool | Check https://github.com/mds/figma-use/blob/master/REFERENCE.md |

## Known Issues

- **MCP server must run from source** — figma-use has a packaging bug (`import.meta.dir` is Bun-only). The setup clones the repo and uses Bun as a workaround. When fixed upstream, this simplifies to `npx figma-use mcp serve`.
- **macOS only** — uses `open -a Figma`, `pgrep`, `pkill` which are macOS-specific. Windows/Linux support depends on figma-use upstream.

## License

MIT
