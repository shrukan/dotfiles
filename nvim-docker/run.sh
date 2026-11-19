#!/bin/bash
# Start the nvim-env container for the current directory.
#
#   nvim-docker/run.sh [--offline] [--workspace DIR] [--image NAME] [--] [cmd...]
#
# The workspace (default: the current directory) is mounted at its own absolute
# path, so relative go.work entries, gopls and error messages see the same
# paths as on the host. Mount the directory holding go.work, not just a module.
# The container starts in the current directory when it lies inside the
# workspace, else in the workspace. The default command is nvim.
#
# Options:
#   --offline         run without network (--network none), as on an airgapped system
#   --workspace DIR   directory to mount (default: current directory)
#   --image NAME      image to run (default: nvim-env)
#
# Environment:
#   GOMODCACHE_HOST   Go module cache to mount (default: go env GOMODCACHE,
#                     else ~/go/pkg/mod); on the airgapped system the unpacked
#                     gomodcache.tar.gz
#   GOPROXY_OVERRIDE  an internal Go module proxy to use instead of GOPROXY=off
#   CONTAINER_ENGINE  podman or docker (default: podman when installed)
#
# The ssh agent (SSH_AUTH_SOCK) and ~/.ssh/known_hosts are forwarded for git.
# With rootless podman, container root is you, so files written stay yours.

set -euo pipefail

usage() {
	sed -n '2,/^$/s/^# \{0,1\}//p' "$0"
	exit "${1:-0}"
}

offline=false
workspace="$PWD"
image="nvim-env"

while [ $# -gt 0 ]; do
	case "$1" in
	--offline) offline=true ;;
	--workspace)
		workspace="${2:?--workspace needs a directory}"
		shift
		;;
	--image)
		image="${2:?--image needs a name}"
		shift
		;;
	-h | --help) usage ;;
	--)
		shift
		break
		;;
	*) break ;;
	esac
	shift
done

[ $# -gt 0 ] || set -- nvim

workspace="$(cd "$workspace" && pwd -P)"
here="$(pwd -P)"
case "$here/" in
"$workspace"/*) workdir="$here" ;;
*) workdir="$workspace" ;;
esac

engine="${CONTAINER_ENGINE:-}"
if [ -z "$engine" ]; then
	if command -v podman >/dev/null; then engine=podman; else engine=docker; fi
fi

modcache="${GOMODCACHE_HOST:-}"
if [ -z "$modcache" ]; then
	modcache="$(go env GOMODCACHE 2>/dev/null || true)"
	modcache="${modcache:-$HOME/go/pkg/mod}"
fi
if [ ! -d "$modcache" ]; then
	echo "Go module cache $modcache does not exist; set GOMODCACHE_HOST" >&2
	exit 1
fi

args=(
	--rm
	--security-opt label=disable
	-v "$workspace:$workspace"
	-w "$workdir"
	-v "$modcache:/root/go/pkg/mod"
	-v nvim-env-gocache:/root/.cache/go-build
	-e TERM -e COLORTERM
)
# a terminal only when there is one, so the script also runs from scripts and CI
if [ -t 0 ] && [ -t 1 ]; then args+=(-it); fi
if $offline; then args+=(--network none); fi
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
	args+=(-v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
fi
if [ -f "$HOME/.ssh/known_hosts" ]; then
	args+=(-v "$HOME/.ssh/known_hosts:/root/.ssh/known_hosts:ro")
fi
if [ -n "${GOPROXY_OVERRIDE:-}" ]; then
	args+=(-e GOPROXY="$GOPROXY_OVERRIDE" -e GOSUMDB=off)
fi

exec "$engine" run "${args[@]}" "$image" "$@"
