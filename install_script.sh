#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# Dev Environment Setup Script
# Installs: base tools, Node.js 22, Neovim, Lazygit, Tmux, Docker
# Targets: Ubuntu/Debian Linux (VMs and local machines)
#
# Usage:
#   chmod +x install_script.sh
#   ./install_script.sh
# ═══════════════════════════════════════════════════════════════

# ── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

export TERM=tmux-256color

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

# ── Detect architecture ────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  NVIM_ASSET="nvim-linux-x86_64.tar.gz" ;;
  aarch64) NVIM_ASSET="nvim-linux-aarch64.tar.gz" ;;
  *) echo -e "${RED}Unsupported arch: $ARCH${NC}"; exit 1 ;;
esac

# ═══════════════════════════════════════════════════════════════
# 1. Base packages
# ═══════════════════════════════════════════════════════════════
info "Installing base packages..."

sudo apt-get update
sudo apt-get install -y \
  git \
  gcc \
  g++ \
  make \
  ripgrep \
  fd-find \
  unzip \
  curl \
  xclip \
  vim \
  tmux \
  libreadline-dev


# fd-find installs as 'fdfind' on Debian/Ubuntu; symlink to 'fd' for nvim compatibility
if command -v fd &>/dev/null; then
  ok "'fd' already available"
elif ! [ -L /usr/local/bin/fd ] && ! [ -f /usr/local/bin/fd ]; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  ok "Symlinked 'fdfind' → 'fd'"
fi

ok "Base packages installed"
# ═══════════════════════════════════════════════════════════════
# TMUX CONFIG
# ═══════════════════════════════════════════════════════════════
info "Setting up tmux config..."

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    ok "TPM installed"
fi

TMUX_CONF_DIR="$(dirname "$(readlink -f "$0")")/dotfiles"

if [ -f "$TMUX_CONF_DIR/tmux.conf" ]; then
    ln -sf "$TMUX_CONF_DIR/tmux.conf" "$HOME/.tmux.conf"
    ok "tmux config linked to ~/.tmux.conf"
else
    warn "tmux.conf not found in dotfiles/, skipping"
fi



# ═══════════════════════════════════════════════════════════════
# 2. Node.js 22 (required for Copilot in Neovim)
# ═══════════════════════════════════════════════════════════════
info "Checking Node.js..."

NEEDED_NODE=false
if ! command -v node &>/dev/null; then
  NEEDED_NODE=true
elif [ "$(node -v | cut -dv -f1 | cut -d. -f1 | tr -d 'v')" -lt 22 ] 2>/dev/null; then
  NEEDED_NODE=true
fi

if [ "$NEEDED_NODE" = true ]; then
  info "Installing Node.js 22..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  ok "Node.js $(node -v) already satisfies requirements"
fi
ok "Node.js ready: $(node -v)"

# ═══════════════════════════════════════════════════════════════
# 3. Neovim (latest stable from GitHub)
# ═══════════════════════════════════════════════════════════════
info "Installing imagemagick..."

sudo apt update
sudo apt install libmagickwand-dev luajit luarocks pkgconf
sudo luarocks install magick
sudo -n apt-get install -y imagemagick

info "Installing Neovim..."
curl -LO "https://github.com/neovim/neovim/releases/latest/download/$NVIM_ASSET"
sudo tar -C /usr/local -xzf "$NVIM_ASSET"
rm "$NVIM_ASSET"
NVIM_DIR="${NVIM_ASSET%.tar.gz}"
sudo ln -sf "/usr/local/$NVIM_DIR/bin/nvim" /usr/local/bin/nvim

ok "Neovim installed: $(nvim --version | head -1)"

# ═══════════════════════════════════════════════════════════════
# 4. Lazygit
# ═══════════════════════════════════════════════════════════════
info "Installing Lazygit..."

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/' -e 's/x86_64/x86_64/')

curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm -f lazygit lazygit.tar.gz

ok "Lazygit ${LAZYGIT_VERSION} installed"

# ═══════════════════════════════════════════════════════════════
# 5. Neovim config
# ═══════════════════════════════════════════════════════════════
info "Setting up Neovim config..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG_DIR" ]; then
  warn "Neovim config already exists at $NVIM_CONFIG_DIR"
  warn "Skipping clone. To overwrite: rm -rf $NVIM_CONFIG_DIR && re-run."
else
  if command -v gh &>/dev/null; then
    gh repo clone FrejaThoresen/nvim-config "$NVIM_CONFIG_DIR"
  elif command -v git &>/dev/null; then
    git clone https://github.com/FrejaThoresen/nvim-config.git "$NVIM_CONFIG_DIR"
  else
    warn "Neither 'gh' nor 'git' available — skipping config clone."
  fi
  ok "Neovim config cloned to $NVIM_CONFIG_DIR"
fi

# First launch to bootstrap plugins
info "Bootstrapping Neovim plugins (this may take a moment)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "Plugin sync needs interactive launch — run 'nvim' manually after script completes."

# ═══════════════════════════════════════════════════════════════
# 6. Docker
# ═══════════════════════════════════════════════════════════════
# ═══════════════════════════════════════════════════════════════
# 6. Docker (with no-sudo setup)
# ═══════════════════════════════════════════════════════════════
info "Setting up Docker..."

DOCKER_INSTALLED=false
if command -v docker &>/dev/null; then
  DOCKER_INSTALLED=true
  ok "Docker already installed: $(docker --version | cut -d' ' -f3)"
fi

if [ "$DOCKER_INSTALLED" = false ]; then
  info "Installing Docker via official method..."
  
  # Prerequisites
  sudo apt-get install -y ca-certificates gnupg lsb-release
  
  # Add Docker's official GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  
  # Add Docker repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(. /etc/os-release; echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Install Docker packages
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  ok "Docker installed: $(docker --version | cut -d' ' -f3)"
fi

# Verify Docker service is running
if systemctl is-active --quiet docker; then
  ok "Docker service is running"
else
  warn "Docker service not active. Starting..."
  sudo systemctl start docker
  sudo systemctl enable docker
  ok "Docker service started and enabled"
fi

# Post-install: allow running docker without sudo
if id -nG "$USER" | grep -qw docker; then
  ok "User '$USER' already in docker group"
  
  # Quick test
  if docker ps &>/dev/null; then
    ok "Docker works without sudo ✓"
  else
    warn "Docker group configured but needs a RELOG or REBOOT to take effect"
  fi
else
  info "Adding $USER to docker group..."
  sudo usermod -aG docker "$USER"
  warn "⚠️  Requires REBOOT or relogin for changes to take effect"
  warn "   After reboot, verify with: docker ps (should work without sudo)"
fi

# ═══════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo -e "  1. ${BOLD}Reboot${NC} (required for docker group):"
echo "       sudo reboot"
echo ""
echo -e "  2. ${BOLD}Verify docker works without sudo${NC}:"
echo "       docker ps"
echo ""
echo -e "  3. ${BOLD}Start opencode${NC} (from your project dir with docker-compose.yml):"
echo "       docker compose build --no-cache"
echo "       docker compose up --build -d"
echo "       docker compose exec -it opencode /bin/bash"
echo "       opencode auth login"
echo "       opencode"
echo ""
echo -e "  4. ${BOLD}Launch Neovim${NC}:"
echo "       nvim"
echo "       (plugins will auto-install on first launch if not already)"
echo ""
echo -e "  5. ${BOLD}Start tmux${NC}:"
echo "       tmux"
echo "       (Prefix: Ctrl+b, then ? for help)"
echo ""
