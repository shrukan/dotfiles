# Dockerfile for Neovim image with all the dependencies for offline use.
#
# GO_VERSION must be at least the highest `go` directive of every project you
# open in the container: gopls, golangci-lint and delve are built with it, and
# GOTOOLCHAIN=local forbids downloading a newer toolchain at run time.

FROM debian:trixie-slim

ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=Europe/Zurich

ENV PATH="/usr/local/go/bin:${PATH}"

ARG NVIM_VERSION='v0.12.6'
ARG GO_VERSION='1.27.3'
ARG GOPLS_VERSION='v0.24.0'
ARG GOLANGCI_LINT_VERSION='v2.15.0'
ARG DELVE_VERSION='v1.27.2'
ARG CHEZMOI_VERSION='v2.74.1'
ARG LAZYGIT_VERSION='0.62.2'
ARG NODE_VERSION='24.0.0'
ARG TEMPL_VERSION="0.3.1001"
ARG TREE_SITTER_VERSION='0.27.2'

# --- System Setup & Core Build Dependencies ---
RUN apt-get update && \
	apt-get -y install --no-install-recommends \
	build-essential \
	ca-certificates \
	cmake \
	curl \
	gettext \
	git \
	libtool \
	libtool-bin \
	autoconf \
	automake \
	ninja-build \
	pkg-config \
	g++ \
	libjemalloc-dev \
	libicu-dev \
	python3 \
	python3-pip \
	python3-venv \
	unzip \
	&& rm -rf /var/lib/apt/lists/*

# Set HOME environment variable for the root user
ENV HOME=/root

# --- Install Neovim from source ---
COPY scripts/nvim.sh /usr/local/bin/nvim.sh
RUN chmod +x /usr/local/bin/nvim.sh \
	&& nvim.sh /usr/local "${NVIM_VERSION}" \
	&& rm -rf /usr/local/bin/nvim.sh /tmp/nvim_build_source

# --- Install Neovim runtime dependencies (fzf, ripgrep, Go, Node.js, uv, lazygit, templ, tree-sitter-cli) ---
COPY scripts/nvim-deps.sh /usr/local/bin/nvim-deps.sh
RUN chmod +x /usr/local/bin/nvim-deps.sh
ENV GO_VERSION=${GO_VERSION} \
	LAZYGIT_VERSION=${LAZYGIT_VERSION} \
	NODE_VERSION=${NODE_VERSION} \
	TEMPL_VERSION=${TEMPL_VERSION} \
	TREE_SITTER_VERSION=${TREE_SITTER_VERSION}
RUN nvim-deps.sh \
	&& rm /usr/local/bin/nvim-deps.sh

# --- Go tools, built with the image's Go ---
# Installed here rather than by Mason, so they are pinned and built with the
# same Go as the projects they analyse. mason.lua skips tools already on PATH.
RUN GOBIN=/usr/local/bin go install golang.org/x/tools/gopls@${GOPLS_VERSION} \
	&& GOBIN=/usr/local/bin go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION} \
	&& GOBIN=/usr/local/bin go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} \
	&& go clean -modcache -cache

# --- Install chezmoi ---
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin -t "${CHEZMOI_VERSION}"

# --- Copy neovim config ---
COPY /dot_config/nvim /root/.config/nvim

# --- Neovim Config Setup ---
COPY ./nvim-docker/setup-nvim-in-container.sh /usr/local/bin/setup-nvim-in-container.sh
RUN chmod +x /usr/local/bin/setup-nvim-in-container.sh \
	&& setup-nvim-in-container.sh \
	&& rm /usr/local/bin/setup-nvim-in-container.sh

# --- Offline behaviour ---
# NVIM_OFFLINE stops lazy, Mason, Tree-sitter and windsurf from reaching the
# network. The Go settings make a missing module or toolchain an immediate
# error instead of a download attempt: modules come from the module cache
# mounted at /root/go/pkg/mod. Override GOPROXY with -e for an internal proxy.
ENV NVIM_OFFLINE=1 \
	GOTOOLCHAIN=local \
	GOPROXY=off \
	GOSUMDB=off

WORKDIR /root
CMD ["nvim"]
