# FigShift Setup Prompt

Copy everything below the line and paste it into Claude Code. It will set up everything you need to control Figma with AI.

**Before you start, you need:**
- A Mac (macOS only)
- Figma Desktop installed and signed in (https://figma.com/downloads)
- Claude Code installed with an active Anthropic Max subscription or API key (https://claude.ai/download)

**You do NOT need** the official Figma MCP plugin, figma-console, or any other Figma bridge. This replaces all of them.

**WARNING:** This gives Claude Code full read/write access to your Figma files — it can create, edit, move, and **delete** anything. Always work in a dedicated Figma file for AI work, not your production designs. See the Safeguards section at the bottom.

---

Set up my Mac so I can control Figma with AI. After setup, I should be able to type `fig` in any terminal to start everything, then use Claude Code to design. Follow these instructions exactly.

## What to install

1. **Check prerequisites.** I need: Node.js, Bun, git, Figma Desktop, Claude Code. Check each one:
   - Node.js: run `node --version`. If missing, tell me to download it from https://nodejs.org (click the big green LTS button) and wait for me to confirm.
   - Bun: run `bun --version`. If missing, install it with `curl -fsSL https://bun.sh/install | bash` then immediately run `export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"` so it's available in this session.
   - git: run `git --version`. If missing, run `xcode-select --install` and wait for me to complete the system dialog.
   - Figma: check `ls /Applications/Figma.app`. If missing, tell me to download from https://figma.com/downloads and make sure I'm signed in.
   - Claude Code: run `claude --version`. If missing, run `npm install -g @anthropic-ai/claude-code`. I'll need an active Anthropic Max subscription ($20/month at claude.ai) or an API key with credits.
   - Don't continue until everything is confirmed installed.

2. **Install figma-use CLI.** Run `npm install -g figma-use`.

3. **Clone the figma-use repo.** The MCP server needs to run from source right now (packaging bug). If `~/figma-use` already exists, skip the clone and just run `cd ~/figma-use && git pull && bun install`. Otherwise run `git clone --depth 1 https://github.com/dannote/figma-use.git ~/figma-use && cd ~/figma-use && bun install`.

4. **Add the `fig` command to my shell.** Check if a `fig()` function already exists in `~/.zshrc`. If it does, replace it. If not, append it. Here's the exact function to add:

```bash
# fig — AI-assisted Figma design (figshift + figma-use + Claude Code)
fig() {
  case "${1:-start}" in
    stop)
      if lsof -ti:38451 &>/dev/null; then
        lsof -ti:38451 | xargs kill 2>/dev/null
        echo "fig: stopped"
      else
        echo "fig: nothing running"
      fi
      ;;
    restart)
      fig stop
      sleep 1
      fig
      ;;
    status)
      local f="off" m="off"
      curl -s http://localhost:9222/json/version &>/dev/null && f="on"
      lsof -ti:38451 &>/dev/null && m="on"
      echo "fig: Figma CDP=$f  MCP server=$m"
      ;;
    start|"")
      # Kill Figma if running without CDP
      if pgrep -x Figma &>/dev/null && ! curl -s http://localhost:9222/json/version &>/dev/null; then
        echo "fig: restarting Figma with AI access..."
        pkill -x Figma 2>/dev/null
        sleep 2
      fi
      # Launch Figma with CDP
      if ! curl -s http://localhost:9222/json/version &>/dev/null; then
        echo "fig: launching Figma..."
        open -a Figma --args --remote-debugging-port=9222
        local i=0
        while ! curl -s http://localhost:9222/json/version &>/dev/null; do
          sleep 1; i=$((i+1))
          [ $i -ge 15 ] && echo "fig: Figma failed to start" && return 1
        done
      fi
      echo "fig: Figma ready"
      # Start MCP server
      if ! lsof -ti:38451 &>/dev/null; then
        (cd ~/figma-use && "$HOME/.bun/bin/bun" packages/cli/src/index.ts mcp serve --port 38451 &>/dev/null &)
        sleep 2
        lsof -ti:38451 &>/dev/null || { echo "fig: MCP server failed"; return 1; }
      fi
      echo "fig: ready — Claude Code has Figma access"
      ;;
    *) echo "Usage: fig [stop|restart|status]" ;;
  esac
}
```

After adding to `~/.zshrc`, run `source ~/.zshrc`.

5. **Register the MCP server with Claude Code globally.** Run `claude mcp add -s user --transport http figma-use http://localhost:38451/mcp`. This makes the Figma tools available in every Claude Code project, not just one.

6. **Remove any conflicting Figma MCP servers.** Check `claude mcp list` for any existing Figma servers (like `figma-console` or `figma`). If found, remove them with `claude mcp remove <name> -s user` — figma-use replaces them.

7. **Test it.** Run `fig` to start everything, then run `fig status` to confirm both show "on", then run `claude mcp list 2>&1 | grep figma-use` to confirm Claude Code sees it.

8. **When done, tell me clearly:**

**Preflight checklist (every session, before typing `fig`):**
- Make sure you're signed into your Figma account
- If Figma is open, let any saves finish (Figma auto-saves to the cloud, but give it a moment) — `fig` will restart Figma if needed
- Close Claude Code if it's already running (you'll reopen it after `fig`)

**How to use:**
1. Open terminal
2. Type `fig` — wait for "fig: ready"
3. Open Claude Code
4. Tell Claude what to design — it has full Figma read/write access (118+ tools)
5. When done, type `fig stop`

**Quick reference:**
- `fig` — start everything
- `fig stop` — stop the MCP server
- `fig restart` — stop and restart everything
- `fig status` — check what's running

**Troubleshooting:**

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

**Important:**
- This is macOS only
- You do NOT need the official Figma MCP plugin or any other Figma bridge — this replaces all of them
- Full tool documentation: https://github.com/dannote/figma-use/blob/master/README.md
- Full command reference: https://github.com/dannote/figma-use/blob/master/REFERENCE.md

## Safeguards

This setup gives Claude Code full read/write access to Figma. That means it can create, edit, move, resize, restyle, and DELETE anything in any open Figma file. Follow these rules to stay safe:

**For you (the human):**
- Always work in a **dedicated Figma file** for AI design work — never point Claude at your production design files
- Create a new Figma file (e.g., "AI Workspace") and do all AI-assisted design there
- Copy finished work from the AI file into your real project files manually
- If Claude does something wrong, Cmd+Z (undo) works in Figma — you can undo AI actions just like manual ones
- Version history in Figma lets you restore any previous state if needed

**For Claude (these are instructions for you, the AI):**
- NEVER delete pages, frames, or components without explicitly asking the user first
- NEVER navigate to or modify a different Figma file than the one the user is working in
- ALWAYS describe what you're about to create or change BEFORE executing the action
- ALWAYS work on the current page unless the user specifically asks to switch pages
- When creating new elements, place them in empty canvas space — don't overlap existing work
- If the user shares a Figma file URL, only work within that specific file
- If you're unsure whether an action is destructive, ask before doing it
- Prefer creating NEW frames over modifying existing ones — let the user decide what to keep
