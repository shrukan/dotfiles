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
#   --workspace DIR   directory to mount (default: NVIM_ENV_WORKSPACE, else the
#                     current directory)
#   --image NAME      image to run (default: nvim-env)
#
# Installed under the name nvim (e.g. ~/.local/bin/nvim), every argument goes
# to nvim in the container, so it replaces nvim for the shell, git and $EDITOR;
# set NVIM_ENV_WORKSPACE to the directory holding go.work.
# Files given to nvim must lie inside the workspace: anything else is refused,
# since the container cannot see it and a save would be lost with the container.
#
# Go environment:
#   The Go settings of the calling shell are forwarded when set: GOPROXY,
#   GOSUMDB, GOFLAGS, GOWORK, GOPRIVATE, GONOSUMDB, GONOPROXY, GOTOOLCHAIN,
#   CGO_ENABLED. Unset ones keep the image defaults (GOPROXY=off, GOSUMDB=off,
#   GOTOOLCHAIN=local). So an internal module proxy, or the env file of a
#   vendored offline bundle, works by setting it in the shell before calling
#   this script. GOROOT and PATH are not forwarded: the image brings its own Go.
#   GOWORK must point inside the workspace.
#
# Other environment:
#   NVIM_ENV_WORKSPACE  default workspace
#   NVIM_ENV_OFFLINE    1 behaves like --offline
#   GOMODCACHE_HOST   Go module cache to mount (default: go env GOMODCACHE, else
#                     ~/go/pkg/mod); skipped when the directory does not exist
#   CONTAINER_ENGINE  podman or docker (default: podman when installed)
#
# Also forwarded, for git: the ssh agent (SSH_AUTH_SOCK), which must hold the
# keys (ssh-add); from ~/.ssh only config, known_hosts and *.pub, read-only, so
# host aliases, ports and IdentityFile entries work without private key files;
# the git config (~/.gitconfig, ~/.config/git) for name and email; and the
# host's CA bundle (SSL_CERT_FILE, else the system bundle), so an
# internal proxy or git server signed by an in-house CA is trusted.
# With rootless podman, container root is you, so files written stay yours.

set -euo pipefail

usage() {
	sed -n '2,/^$/s/^# \{0,1\}//p' "$0"
	exit "${1:-0}"
}

offline=false
[ "${NVIM_ENV_OFFLINE:-}" = 1 ] && offline=true
workspace="${NVIM_ENV_WORKSPACE:-$PWD}"
image="nvim-env"

if [ "$(basename "$0")" = nvim ]; then
	set -- -- nvim "$@"
fi

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

# Refuse file arguments of nvim that the container cannot see. Options and the
# values of options that take one are skipped; relative paths resolve against
# the current directory, as nvim on the host would.
if [ "$1" = nvim ]; then
	skip_next=false
	for a in "${@:2}"; do
		if $skip_next; then
			skip_next=false
			continue
		fi
		case "$a" in
		-c | --cmd | -u | -i | -S | -s | -w | -W | -t | -q | --listen | --startuptime)
			skip_next=true
			continue
			;;
		-* | +*) continue ;;
		/*) p="$a" ;;
		*) p="$here/$a" ;;
		esac
		p="$(realpath -m "$p")"
		case "$p/" in
		"$workspace"/*) ;;
		*)
			echo "nvim-env: $a is outside the workspace $workspace; the container cannot see it" >&2
			echo "nvim-env: use the host's nvim for it, or set NVIM_ENV_WORKSPACE / --workspace" >&2
			exit 1
			;;
		esac
	done
fi

engine="${CONTAINER_ENGINE:-}"
if [ -z "$engine" ]; then
	if command -v podman >/dev/null; then engine=podman; else engine=docker; fi
fi

modcache="${GOMODCACHE_HOST:-}"
if [ -z "$modcache" ]; then
	modcache="$(go env GOMODCACHE 2>/dev/null || true)"
	modcache="${modcache:-$HOME/go/pkg/mod}"
fi

if [ -n "${GOWORK:-}" ] && [ "$GOWORK" != off ]; then
	case "$GOWORK" in
	"$workspace"/*) ;;
	*) echo "warning: GOWORK=$GOWORK is outside the workspace $workspace and not visible in the container" >&2 ;;
	esac
fi

cabundle="${SSL_CERT_FILE:-}"
if [ -z "$cabundle" ]; then
	for f in /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt; do
		if [ -f "$f" ]; then
			cabundle="$f"
			break
		fi
	done
fi

# --init: nvim does not reap orphaned processes, so as PID 1 it collects
# zombies until the container's pids limit stops Go from creating threads.
# nvim-env-cache keeps the Go build, gopls and golangci-lint caches across
# runs; a cold gopls load of a large workspace costs about ten times the memory.
args=(
	--rm
	--init
	--security-opt label=disable
	-v "$workspace:$workspace"
	-w "$workdir"
	-v nvim-env-cache:/root/.cache
	-e TERM -e COLORTERM
)
# a terminal only when there is one, so the script also runs from scripts and CI
if [ -t 0 ] && [ -t 1 ]; then args+=(-it); fi
if $offline; then args+=(--network none); fi
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
	args+=(-v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
fi
# Only the public parts of ~/.ssh: private keys stay in the agent, so code
# running in the container can use them while it runs but never read them.
# IdentityFile entries keep working through their .pub files.
for f in "$HOME"/.ssh/config "$HOME"/.ssh/known_hosts "$HOME"/.ssh/*.pub; do
	if [ -f "$f" ]; then
		args+=(-v "$f:/root/.ssh/$(basename "$f"):ro")
	fi
done
if [ -f "$HOME/.gitconfig" ]; then
	args+=(-v "$HOME/.gitconfig:/root/.gitconfig:ro")
fi
if [ -d "$HOME/.config/git" ]; then
	args+=(-v "$HOME/.config/git:/root/.config/git:ro")
fi
if [ -d "$modcache" ]; then
	args+=(-v "$modcache:/root/go/pkg/mod")
fi
# Go, git and curl read the system path; Node and Python tools keep their own
# lists unless pointed at it.
if [ -n "$cabundle" ] && [ -f "$cabundle" ]; then
	args+=(
		-v "$(readlink -f "$cabundle"):/etc/ssl/certs/ca-certificates.crt:ro"
		-e SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
		-e NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
	)
fi
for v in GOPROXY GOSUMDB GOFLAGS GOWORK GOPRIVATE GONOSUMDB GONOPROXY GOTOOLCHAIN CGO_ENABLED; do
	if [ -n "${!v+x}" ]; then args+=(-e "$v=${!v}"); fi
done

exec "$engine" run "${args[@]}" "$image" "$@"
