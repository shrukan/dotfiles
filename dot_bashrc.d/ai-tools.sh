HEADROOM_PORT=8787
LOCAL_HEADROOM_PORT=8790
LEMONADE_URL=http://127.0.0.1:13305/v1

# Restart the lemonade server (managed via systemd)
ai_lemonade_restart() {
	echo "Restarting lemonade server..."
	systemctl restart lemond.service
	echo "Lemonade server restarted"
}

# Kill and restart a standalone headroom proxy on the given port so it always
# picks up whatever upstream target this invocation needs (headroom bakes the
# target in at proxy startup, not per-invocation, so a stale proxy from a
# previous call would keep pointing at the old target). Extra args are
# forwarded to `headroom proxy` to set the upstream for this call. Kills by
# port (fuser), not by cmdline pattern -- a `headroom` process started via
# `python -m headroom.cli proxy --port N` (e.g. through uv tool run) never
# matches a `pkill -f "headroom proxy --port N"` pattern and would survive
# every restart, silently keeping traffic routed at the wrong upstream.
#
# HEADROOM_PORT (claude, via `headroom wrap`) and LOCAL_HEADROOM_PORT
# (opencode/crush) are deliberately separate ports: `headroom wrap` owns and
# auto-heals its own proxy for the lifetime of the wrapped claude session, so
# a live ai_claude_local/ai_claude_cloud terminal will keep reclaiming a
# shared port out from under opencode/crush the moment they restart it.
ai_headroom_restart_proxy() {
	local port="$1"
	shift
	fuser -k "${port}/tcp" 2>/dev/null
	for _ in 1 2 3 4 5; do
		fuser "${port}/tcp" >/dev/null 2>&1 || break
		sleep 0.2
	done
	nohup headroom proxy --port "$port" "$@" >/tmp/headroom.log 2>&1 &
	disown
	for _ in 1 2 3 4 5; do
		fuser "${port}/tcp" >/dev/null 2>&1 && break
		sleep 0.2
	done
}

# Claude Code with local model, compressed via Headroom
ai_claude_local() {
	ai_lemonade_restart
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 ai_headroom_restart_proxy "$HEADROOM_PORT"
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
ai_claude_cloud() {
	ai_headroom_restart_proxy "$HEADROOM_PORT"
	headroom wrap claude --port "$HEADROOM_PORT" -- "$@"
}

# OpenCode: restarts Headroom pointed at Lemonade (the only local target
# the "headroom" provider in opencode.json ever needs -- the proxy's
# upstream is baked in at startup, so it's always forced here rather than
# reused, or a stale proxy with the wrong default upstream gets silently
# picked up, same failure mode as claude-local/claude-cloud). Runs on its own
# port (LOCAL_HEADROOM_PORT), not HEADROOM_PORT, so it never fights a live
# ai_claude_local/ai_claude_cloud terminal for the same socket. Switch
# between Lemonade (direct or headroom-compressed) and any other
# configured provider from OpenCode's own model picker at runtime.
ai_opencode_headroom() {
	ai_lemonade_restart
	ai_headroom_restart_proxy "$LOCAL_HEADROOM_PORT" --openai-api-url "$LEMONADE_URL"
	opencode "$@"
}

# Crush with local model, compressed via Headroom
ai_crush_local() {
	ai_lemonade_restart
	ai_headroom_restart_proxy "$LOCAL_HEADROOM_PORT" --openai-api-url "$LEMONADE_URL"
	crush "$@"
}
