# Lemonade + Headroom shell functions
# https://lemonade-server.ai
# Local + paid Claude Code setup with compression

# Claude Code with local model, compressed via Headroom
claude-local() {
	ANTHROPIC_TARGET_API_URL=http://localhost:13305 headroom wrap claude -- "$@"
}

# Claude Code with paid Anthropic API, compressed via Headroom
claude-cloud() {
	unset ANTHROPIC_TARGET_API_URL
	headroom wrap claude -- "$@"
}
