# Lemonade + Headroom shell functions
# https://lemonade-server.ai
# Local + paid Claude Code setup with compression

LEMONADE_HEADROOM_PORT=8788

# Restart the lemonade server (managed via systemd)
claude-local-restart() {
	echo "Restarting lemonade server..."
	systemctl --user restart lemond.service
	echo "Lemonade server restarted"
}

# Kill and restart the local headroom proxy so it always picks up a fresh
# ANTHROPIC_TARGET_API_URL (headroom bakes the target in at proxy startup,
# not per-invocation, so a stale proxy would keep pointing at the old target)
claude-local-start() {
	pkill -f "headroom proxy --port $LEMONADE_HEADROOM_PORT" 2>/dev/null
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 \
		nohup headroom proxy --port "$LEMONADE_HEADROOM_PORT" >/tmp/headroom-local.log 2>&1 &
	disown
	for _ in 1 2 3 4 5; do
		pgrep -f "headroom proxy --port $LEMONADE_HEADROOM_PORT" >/dev/null && break
		sleep 0.2
	done
}

# Claude Code with local model, compressed via Headroom
claude-local() {
	claude-local-restart
	claude-local-start
	headroom wrap claude --port "$LEMONADE_HEADROOM_PORT" -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
claude-cloud() {
	headroom wrap claude -- "$@"
}
