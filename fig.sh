# fig — AI-assisted Figma design (figshift + figma-use + Claude Code)
# Source this file in your .zshrc: source /path/to/fig.sh
# Or copy the fig() function below into your .zshrc directly.

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
