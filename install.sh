#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================="
echo "   🚀 DEV ENVIRONMENT SETUP"
echo "========================================="
echo -e "${NC}"

# =========================================
# HELPERS
# =========================================
install_msg() { echo -e "${GREEN}[INSTALLING]${NC} $1"; }
skip_msg() { echo -e "${YELLOW}[SKIP]${NC} $1 already installed"; }
error_msg() { echo -e "${RED}[ERROR]${NC} $1"; }
section_msg() { echo -e "\n${BLUE}═══ $1 ═══${NC}\n"; }

command_exists() { command -v "$1" &>/dev/null; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =========================================
# SYSTEM UPDATE
# =========================================
section_msg "SYSTEM UPDATE"
sudo apt update && sudo apt upgrade -y

# =========================================
# BASIC DEPENDENCIES
# =========================================
section_msg "BASIC DEPENDENCIES"
sudo apt install -y git curl wget build-essential software-properties-common apt-transport-https gnupg ca-certificates

# =========================================
# ZSH + OH MY ZSH
# =========================================
section_msg "ZSH + OH MY ZSH + POWERLEVEL10K"

if command_exists zsh; then
    skip_msg "zsh"
else
    install_msg "zsh"
    sudo apt install -y zsh
    chsh -s $(which zsh)
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    skip_msg "oh-my-zsh"
else
    install_msg "oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Powerlevel10k
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    skip_msg "powerlevel10k"
else
    install_msg "powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# Nerd Fonts (MesloLGS NF)
install_msg "MesloLGS NF fonts"
mkdir -p ~/.local/share/fonts
wget -qP ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf 2>/dev/null || true
wget -qP ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf 2>/dev/null || true
wget -qP ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf 2>/dev/null || true
wget -qP ~/.local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf 2>/dev/null || true
fc-cache -fv &>/dev/null

# =========================================
# ZSH PLUGINS
# =========================================
section_msg "ZSH PLUGINS"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
)

for plugin in "${!plugins[@]}"; do
    if [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
        skip_msg "$plugin"
    else
        install_msg "$plugin"
        git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
    fi
done

# =========================================
# CLI TOOLS
# =========================================
section_msg "CLI TOOLS (apt)"

apt_packages=(eza flameshot terminator)
for pkg in "${apt_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg"; then
        skip_msg "$pkg"
    else
        install_msg "$pkg"
        sudo apt install -y "$pkg"
    fi
done

# =========================================
# ALBERT (launcher)
# =========================================
section_msg "ALBERT"

if command_exists albert; then
    skip_msg "albert"
else
    install_msg "albert"
    echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_24.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
    curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_24.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null
    sudo apt update
    sudo apt install -y albert || error_msg "albert failed, install manually"
fi

# =========================================
# PYTHON TOOLS
# =========================================
section_msg "PYTHON TOOLS"

pip_packages=(ruff pre-commit py-spy)
for pkg in "${pip_packages[@]}"; do
    if command_exists "$pkg"; then
        skip_msg "$pkg"
    else
        install_msg "$pkg"
        pip install "$pkg" --break-system-packages
    fi
done

# UV
if command_exists uv; then
    skip_msg "uv"
else
    install_msg "uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# =========================================
# NODE.JS (via nvm)
# =========================================
section_msg "NODE.JS"

if command_exists node; then
    skip_msg "node $(node --version)"
else
    install_msg "nvm + node"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# =========================================
# DOCKER
# =========================================
section_msg "DOCKER"

if command_exists docker; then
    skip_msg "docker"
else
    install_msg "docker"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

if command_exists docker-compose || docker compose version &>/dev/null; then
    skip_msg "docker compose"
else
    install_msg "docker compose"
    sudo apt install -y docker-compose-plugin
fi

# Lazydocker
if command_exists lazydocker; then
    skip_msg "lazydocker"
else
    install_msg "lazydocker"
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazydocker.tar.gz lazydocker
    sudo install lazydocker /usr/local/bin
    rm lazydocker lazydocker.tar.gz
fi

# =========================================
# HADOLINT
# =========================================
section_msg "HADOLINT"

if command_exists hadolint; then
    skip_msg "hadolint"
else
    install_msg "hadolint"
    sudo wget -qO /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
    sudo chmod +x /usr/local/bin/hadolint
fi

# =========================================
# TRIVY
# =========================================
section_msg "TRIVY"

if command_exists trivy; then
    skip_msg "trivy"
else
    install_msg "trivy"
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb noble main" | sudo tee /etc/apt/sources.list.d/trivy.list
    sudo apt update
    sudo apt install -y trivy
fi

# =========================================
# CLAUDE CODE
# =========================================
section_msg "CLAUDE CODE"

if command_exists claude; then
    skip_msg "claude code"
else
    install_msg "claude code"
    curl -fsSL https://claude.ai/install.sh | bash
fi

# =========================================
# AZURE CLI
# =========================================
section_msg "AZURE CLI"

if command_exists az; then
    skip_msg "azure-cli"
else
    install_msg "azure-cli"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# =========================================
# BRUNO (API Client)
# =========================================
section_msg "BRUNO"

if command_exists bruno || dpkg -l | grep -q bruno; then
    skip_msg "bruno"
else
    install_msg "bruno (.deb)"
    BRUNO_VERSION=$(curl -s "https://api.github.com/repos/usebruno/bruno/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    wget -qO bruno.deb "https://github.com/usebruno/bruno/releases/latest/download/bruno_${BRUNO_VERSION}_amd64_linux.deb"
    sudo dpkg -i bruno.deb || sudo apt --fix-broken install -y
    rm -f bruno.deb
fi

# =========================================
# PLAYWRIGHT (browsers for MCP)
# =========================================
section_msg "PLAYWRIGHT"
install_msg "playwright browsers"
npx playwright install 2>/dev/null || true

# =========================================
# DOCKER SERVICES (pull images)
# =========================================
section_msg "DOCKER IMAGES (pull)"

install_msg "pulling service images via docker compose"
docker compose -f "$SCRIPT_DIR/docker/docker-compose.services.yml" pull 2>/dev/null || error_msg "failed to pull images (docker might need restart)"

# =========================================
# COPY CONFIGS
# =========================================
section_msg "COPYING CONFIGS"

# .zshrc
if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
    install_msg "copying .zshrc"
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

# help.zsh
if [ -f "$SCRIPT_DIR/zsh/help.zsh" ]; then
    install_msg "copying help.zsh"
    mkdir -p "$HOME/.oh-my-zsh/custom"
    cp "$SCRIPT_DIR/zsh/help.zsh" "$HOME/.oh-my-zsh/custom/help.zsh"
fi

# p10k
if [ -f "$SCRIPT_DIR/zsh/.p10k.zsh" ]; then
    install_msg "copying .p10k.zsh"
    cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

# Cursor MCP
if [ -f "$SCRIPT_DIR/cursor/mcp.json" ]; then
    install_msg "copying cursor mcp.json"
    mkdir -p "$HOME/.cursor"
    cp "$SCRIPT_DIR/cursor/mcp.json" "$HOME/.cursor/mcp.json"
fi

# Terminator
if [ -f "$SCRIPT_DIR/terminator/config" ]; then
    install_msg "copying terminator config"
    mkdir -p "$HOME/.config/terminator"
    cp "$SCRIPT_DIR/terminator/config" "$HOME/.config/terminator/config"
fi

# =========================================
# DONE
# =========================================
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✅ SETUP COMPLETE!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}MANUAL STEPS:${NC}"
echo "  1. Restart terminal or run: source ~/.zshrc"
echo "  2. Run: p10k configure (to setup prompt)"
echo "  3. Set terminal font to: MesloLGS NF"
echo "  4. Install Cursor from: https://cursor.com"
echo "  5. Install Zen Browser from: https://zen-browser.app"
echo "  6. Configure SonarQube token at: http://localhost:9000"
echo "  7. Configure Apidog token at: https://apidog.com"
echo "  8. Start Docker services: docker compose -f docker/docker-compose.services.yml up -d"
echo ""
