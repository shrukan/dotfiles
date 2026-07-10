HEADROOM_PORT=8787
LEMONADE_URL=http://127.0.0.1:13305/v1

# Restart the lemonade server (managed via systemd)
ai_lemonade_restart() {
	echo "Restarting lemonade server..."
	systemctl --user restart lemond.service
	echo "Lemonade server restarted"
}

# Kill and restart the shared local headroom proxy so it always picks up
# whatever upstream target this invocation needs (headroom bakes the target
# in at proxy startup, not per-invocation, so a stale proxy from a previous
# local/cloud call would keep pointing at the old target). Extra args are
# forwarded to `headroom proxy` to set the upstream for this call.
ai_headroom_restart_proxy() {
	pkill -f "headroom proxy --port $HEADROOM_PORT" 2>/dev/null
	nohup headroom proxy --port "$HEADROOM_PORT" "$@" >/tmp/headroom.log 2>&1 &
	disown
	for _ in 1 2 3 4 5; do
		pgrep -f "headroom proxy --port $HEADROOM_PORT" >/dev/null && break
		sleep 0.2
	done
}

# Claude Code with local model, compressed via Headroom
ai_claude_local() {
	ai_lemonade_restart
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 ai_headroom_restart_proxy
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
ai_claude_cloud() {
	ai_headroom_restart_proxy
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# OpenCode: restarts Headroom pointed at Lemonade (the only local target
# the "headroom" provider in opencode.json ever needs -- the proxy's
# upstream is baked in at startup, so it's always forced here rather than
# reused, or a stale proxy with the wrong default upstream gets silently
# picked up, same failure mode as claude-local/claude-cloud). Switch
# between Lemonade (direct or headroom-compressed) and any other
# configured provider from OpenCode's own model picker at runtime.
ai_opencode_headroom() {
	ai_lemonade_restart
	ai_headroom_restart_proxy --openai-api-url "$LEMONADE_URL"
	opencode "$@"
}

# Crush with local model, compressed via Headroom
ai_crush_local() {
	ai_lemonade_restart
	ai_headroom_restart_proxy --openai-api-url "$LEMONADE_URL"
	crush "$@"
}
