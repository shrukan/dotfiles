# Local + paid AI coding CLI setup (Claude Code / OpenCode / Crush)
# with compression via Headroom and local models via Lemonade
# https://lemonade-server.ai

HEADROOM_PORT=8787
LEMONADE_URL=http://127.0.0.1:13305/v1

# Restart the lemonade server (managed via systemd)
lemonade-restart() {
	echo "Restarting lemonade server..."
	systemctl --user restart lemond.service
	echo "Lemonade server restarted"
}

# Kill and restart the shared local headroom proxy so it always picks up
# whatever upstream target this invocation needs (headroom bakes the target
# in at proxy startup, not per-invocation, so a stale proxy from a previous
# local/cloud call would keep pointing at the old target). Extra args are
# forwarded to `headroom proxy` to set the upstream for this call.
headroom-restart-proxy() {
	pkill -f "headroom proxy --port $HEADROOM_PORT" 2>/dev/null
	nohup headroom proxy --port "$HEADROOM_PORT" "$@" >/tmp/headroom.log 2>&1 &
	disown
	for _ in 1 2 3 4 5; do
		pgrep -f "headroom proxy --port $HEADROOM_PORT" >/dev/null && break
		sleep 0.2
	done
}

# Start the shared local headroom proxy only if it isn't already running.
# Used when the caller doesn't need to force a specific upstream target
# (e.g. OpenCode picks its provider at runtime, not proxy-startup time).
headroom-ensure-proxy() {
	pgrep -f "headroom proxy --port $HEADROOM_PORT" >/dev/null && return
	nohup headroom proxy --port "$HEADROOM_PORT" >/tmp/headroom.log 2>&1 &
	disown
	for _ in 1 2 3 4 5; do
		pgrep -f "headroom proxy --port $HEADROOM_PORT" >/dev/null && break
		sleep 0.2
	done
}

# Claude Code with local model, compressed via Headroom
claude-local() {
	lemonade-restart
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 headroom-restart-proxy
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
claude-cloud() {
	headroom-restart-proxy
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# OpenCode: ensures Headroom + Lemonade are up, then launches OpenCode.
# Switch between local (Lemonade, direct or headroom-compressed) and any
# other configured provider from OpenCode's own model picker at runtime.
opencode-headroom() {
	lemonade-restart
	headroom-ensure-proxy
	opencode "$@"
}

# Crush with local model, compressed via Headroom
crush-local() {
	lemonade-restart
	headroom-restart-proxy --openai-api-url "$LEMONADE_URL" --openai-api-key your-api-key
	crush "$@"
}
