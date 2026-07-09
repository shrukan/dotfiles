# Lemonade + Headroom shell functions
# https://lemonade-server.ai
# Local + paid Claude Code setup with compression

# Ensure headroom proxy is running (lemonade is managed via systemd)
claude-local-start() {
  pgrep -f "headroom proxy --port 8787" >/dev/null || \
    ANTHROPIC_TARGET_API_URL=http://localhost:13305 \
    nohup headroom proxy --port 8787 >/tmp/headroom.log 2>&1 &
}

# Claude Code with local model, compressed via Headroom
claude-local() {
  claude-local-start
  ANTHROPIC_BASE_URL=http://localhost:8787 headroom wrap claude -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
claude-cloud() {
  unset ANTHROPIC_BASE_URL
  headroom wrap claude -- "$@"
}
