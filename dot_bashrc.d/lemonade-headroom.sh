# Lemonade + Headroom shell functions
# https://lemonade-server.ai
# Local + paid Claude Code setup with compression

# Restart the lemonade server (managed via systemd)
claude-local-restart() {
	echo "Restarting lemonade server..."
	systemctl --user restart lemond.service
	echo "Lemonade server restarted"
}

# Claude Code with local model, compressed via Headroom
claude-local() {
	claude-local-restart
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 headroom wrap claude -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
claude-cloud() {
	unset ANTHROPIC_TARGET_API_URL
	headroom wrap claude -- "$@"
}
