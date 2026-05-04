# Dockerfile for Neovim image with all the dependencies for offline use. 

FROM debian:trixie-slim

ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=Europe/Zurich

ENV PATH="/usr/local/go/bin:${PATH}"

ARG GO_VERSION='1.26.0'
ARG PYTHON_VERSION='3.12.0' 
ARG LAZYGIT_VERSION='0.61.1'
ARG NODE_VERSION='24.0.0' 
ARG TEMPL_VERSION="0.3.1001"

# --- System Setup & Core Dependencies ---
RUN apt-get update && \
	apt-get -y install --no-install-recommends \
	curl \
	tar \
	fzf \
	ripgrep \
	tree \
	git \
	xclip \
	tzdata \
	openssh-client \
	# Additional dependencies for pyenv to build various Python versions
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	libffi-dev \
	liblzma-dev \
	libgdbm-dev \
	libncursesw5-dev \
	uuid-dev \
	tk-dev \
	libexpat1-dev \
	&& rm -rf /var/lib/apt/lists/* 

# Set HOME environment variable for the root user 
ENV HOME=/root

# --- Install Neovim from Source using the dedicated script ---
COPY scripts/install-neovim-from-source.sh /usr/local/bin/install-neovim-from-source.sh
RUN chmod +x /usr/local/bin/install-neovim-from-source.sh
RUN install-neovim-from-source.sh "/usr/local" "stable" \
	&& rm /usr/local/bin/install-neovim-from-source.sh 

# Install chezmoi 
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# --- Install Pyenv and Specific Python Version ---
ENV PYENV_ROOT=/opt/pyenv 
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT" \
	&& "$PYENV_ROOT/bin/pyenv" init --path | sh \
	&& "$PYENV_ROOT/bin/pyenv" install "$PYTHON_VERSION" \
	&& "$PYENV_ROOT/bin/pyenv" global "$PYTHON_VERSION" 

# --- Install uv ---
RUN curl -fsSL https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# --- Install Specific Node.js --- 
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
	| tar -xJ --strip-components=1 -C /usr/local/bin

RUN curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
	&& tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" \
	--strip-components=1 -C /usr/local \
	&& rm "node-v${NODE_VERSION}-linux-x64.tar.xz"

# Install lazygit
RUN curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz \
	&& tar xf lazygit.tar.gz lazygit \
	&& install lazygit /usr/local/bin \
	&& rm lazygit lazygit.tar.gz

# --- Install Go ---
RUN curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
	&& tar -C /usr/local -xzf /tmp/go.tar.gz \
	&& rm /tmp/go.tar.gz

# --- Install templ ---
RUN curl -Lo templ.tar.gz "https://github.com/a-h/templ/releases/download/v${TEMPL_VERSION}/templ_Linux_x86_64.tar.gz" \
	&& tar xf templ.tar.gz templ \
	&& install templ /usr/local/bin \
	&& rm templ templ.tar.gz

# --- Install tree-sitter-cli ---
RUN npm i -g tree-sitter-cli

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
