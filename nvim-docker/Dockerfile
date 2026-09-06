# Dockerfile for Neovim image with all the dependencies for offline use. 

FROM debian:trixie-slim

ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=Europe/Zurich

ENV PATH="/usr/local/go/bin:${PATH}"

ARG GO_VERSION='1.26.0'
ARG LAZYGIT_VERSION='0.62.2'
ARG NODE_VERSION='24.0.0'
ARG TEMPL_VERSION="0.3.1001"

# --- System Setup & Core Build Dependencies ---
RUN apt-get update && \
	apt-get -y install --no-install-recommends \
	build-essential \
	cmake \
	git \
	libtool \
	libtool-bin \
	autoconf \
	automake \
	pkg-config \
	g++ \
	libjemalloc-dev \
	libicu-dev \
	python3 \
	python3-pip \
	python3-venv \
	&& rm -rf /var/lib/apt/lists/* 

# Set HOME environment variable for the root user 
ENV HOME=/root

# --- Install Neovim runtime dependencies (fzf, ripgrep, Go, Node.js, uv, lazygit, templ, tree-sitter-cli) ---
COPY scripts/nvim-deps.sh /usr/local/bin/nvim-deps.sh
RUN chmod +x /usr/local/bin/nvim-deps.sh
ENV GO_VERSION=${GO_VERSION} \
	LAZYGIT_VERSION=${LAZYGIT_VERSION} \
	NODE_VERSION=${NODE_VERSION} \
	TEMPL_VERSION=${TEMPL_VERSION}
RUN nvim-deps.sh \
	&& rm /usr/local/bin/nvim-deps.sh

# --- Install chezmoi ---
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# --- Copy neovim config ---
COPY /dot_config/nvim /root/.config/nvim

# --- Neovim Config Setup ---
COPY ./nvim-docker/setup-nvim-in-container.sh /usr/local/bin/setup-nvim-in-container.sh
RUN chmod +x /usr/local/bin/setup-nvim-in-container.sh
WORKDIR /usr/local/bin
RUN setup-nvim-in-container.sh \
	&& rm setup-nvim-in-container.sh 

# --- Final Touches ---
RUN mkdir -p /root/workspace
WORKDIR /root/workspace
CMD ["nvim"]
