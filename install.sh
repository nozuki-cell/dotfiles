#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║    Minimalistic Hyprland Dotfiles - Installation Script     ║
# ║          Cross-platform (Arch & Debian/Ubuntu)              ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Colors ─────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ── Symbols ────────────────────────────────
CHECK="✔"
CROSS="✘"
ARROW="➜"
INFO="●"
WARN="⚠"

# ── Helpers ────────────────────────────────
print_banner() {
    echo -e "${PURPLE}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║     Minimalistic Hyprland Dotfiles       ║"
    echo "  ║        Installation Script               ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info()    { echo -e "${BLUE}  ${INFO}  ${NC}$1"; }
log_success() { echo -e "${GREEN}  ${CHECK}  ${NC}$1"; }
log_warn()    { echo -e "${YELLOW}  ${WARN}  ${NC}$1"; }
log_error()   { echo -e "${RED}  ${CROSS}  ${NC}$1"; }
log_step()    { echo -e "\n${BOLD}${CYAN}  $1${NC}"; }

confirm() {
    local msg="${1:-Continue?}"
    echo -ne "${YELLOW}  ${WARN}  ${msg} [Y/n]: ${NC}"
    read -r answer
    [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
}

# ── Detect Distro ──────────────────────────
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID,,}"
        DISTRO_LIKE="${ID_LIKE,,}"
    else
        log_error "Cannot detect distribution"
        exit 1
    fi

    if [[ "$DISTRO_ID" == "arch" || "$DISTRO_LIKE" == *"arch"* ]]; then
        PKG_MANAGER="arch"
    elif [[ "$DISTRO_ID" == "ubuntu" || "$DISTRO_ID" == "debian" || "$DISTRO_LIKE" == *"debian"* ]]; then
        PKG_MANAGER="debian"
    else
        log_error "Unsupported distribution: $DISTRO_ID"
        log_info "This script supports Arch Linux and Debian/Ubuntu"
        exit 1
    fi

    log_info "Detected distribution: ${BOLD}$DISTRO_ID${NC} (${PKG_MANAGER} based)"
}

# ── Check Root ─────────────────────────────
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Do not run this script as root!"
        log_info "The script will ask for sudo when needed."
        exit 1
    fi
}

# ── Package Installation ───────────────────
install_packages_arch() {
    local packages=("$@")
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

install_packages_debian() {
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${packages[@]}"
}

# ── Core Packages ──────────────────────────
install_core_packages() {
    log_step "Installing core Hyprland packages..."

    if [ "$PKG_MANAGER" == "arch" ]; then
        install_packages_arch \
            hyprland \
            hyprpaper \
            hyprlock \
            hypridle \
            xdg-desktop-portal-hyprland \
            xdg-desktop-portal-gtk \
            waybar \
            wofi \
            wlogout \
            grimblast-git \
            wl-clipboard \
            cliphist \
            brightnessctl \
            playerctl \
            nm-applet \
            pavucontrol
    else
        # Debian/Ubuntu - use PPA or alternative packages
        sudo add-apt-repository -y ppa:aslatter/ppa 2>/dev/null || true
        sudo apt-get update -qq

        install_packages_debian \
            hyprland \
            xdg-desktop-portal-hyprland \
            waybar \
            wofi \
            wl-clipboard \
            brightnessctl \
            playerctl \
            pavucontrol

        # Install packages that may not be in default repos
        local extra_pkgs=(
            "grimblast" "cliphist" "wlogout"
            "nm-applet" "hyprpaper"
        )
        for pkg in "${extra_pkgs[@]}"; do
            if ! command -v "$pkg" &>/dev/null; then
                log_warn "$pkg not found in repos, skipping..."
            fi
        done
    fi
}

# ── Terminal & Shell ───────────────────────
install_terminal_shell() {
    log_step "Installing terminal and shell..."

    if [ "$PKG_MANAGER" == "arch" ]; then
        install_packages_arch \
            kitty \
            zsh \
            starship \
            neovim
    else
        # Kitty
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

        # Zsh
        install_packages_debian zsh

        # Starship
        curl -sS https://starship.rs/install.sh | sh -s -- -y

        # Neovim (latest from appimage)
        if ! command -v nvim &>/dev/null; then
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
            chmod ux nvim-linux-x86_64.appimage
            sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
        fi
    fi
}

# ── CLI Tools ──────────────────────────────
install_cli_tools() {
    log_step "Installing CLI tools..."

    if [ "$PKG_MANAGER" == "arch" ]; then
        install_packages_arch \
            fastfetch \
            btop \
            cava \
            bat \
            ripgrep \
            fd \
            fzf \
            unzip \
            wget \
            curl
    else
        install_packages_debian \
            curl \
            wget \
            unzip \
            fzf

        # Fastfetch
        if ! command -v fastfetch &>/dev/null; then
            sudo apt-get install -y fastfetch 2>/dev/null || {
                log_info "Installing fastfetch from source..."
                sudo apt-get install -y cmake libvulkan-dev libwayland-dev libxkbcommon-dev libpci-dev
                git clone --depth 1 https://github.com/fastfetch-cli/fastfetch.git /tmp/fastfetch
                cd /tmp/fastfetch
                cmake -B build -DCMAKE_INSTALL_PREFIX=/usr/local
                cmake --build build
                sudo cmake --install build
                cd -
                rm -rf /tmp/fastfetch
            }
        fi

        # Btop
        if ! command -v btop &>/dev/null; then
            sudo apt-get install -y btop 2>/dev/null || {
                log_warn "btop not available in repos, installing from GitHub..."
                BTOP_VERSION=$(curl -s "https://api.github.com/repos/aristocratos/btop/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
                curl -Lo /tmp/btop.tar.gz "https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/btop-x86_64-linux-musl.tbz"
                tar -xf /tmp/btop.tar.gz -C /tmp
                sudo mv /tmp/btop/bin/btop /usr/local/bin/
                rm -rf /tmp/btop /tmp/btop.tar.gz
            }
        fi

        # Cava
        if ! command -v cava &>/dev/null; then
            log_warn "cava may need to be built from source on Debian/Ubuntu"
            sudo apt-get install -y libfftw3-dev libasound2-dev libpulse-dev libiniparser-dev
            git clone --depth 1 https://github.com/karlstav/cava.git /tmp/cava
            cd /tmp/cava
            ./autogen.sh
            ./configure
            make
            sudo make install
            cd -
            rm -rf /tmp/cava
        fi

        # Bat
        if ! command -v bat &>/dev/null; then
            sudo apt-get install -y bat
            # Fix for Debian/Ubuntu where binary might be named batcat
            if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
                sudo ln -sf "$(which batcat)" /usr/local/bin/bat
            fi
        fi

        # Ripgrep
        if ! command -v rg &>/dev/null; then
            sudo apt-get install -y ripgrep
        fi

        # fd
        if ! command -v fd &>/dev/null; then
            sudo apt-get install -y fd-find
            if ! command -v fd &>/dev/null; then
                sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            fi
        fi
    fi
}

# ── Fonts ──────────────────────────────────
install_fonts() {
    log_step "Installing fonts..."

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # JetBrainsMono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        log_info "Downloading JetBrainsMono Nerd Font..."
        curl -fLo /tmp/JetBrainsMono.zip \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        unzip -o /tmp/JetBrainsMono.zip -d "$font_dir"
        rm /tmp/JetBrainsMono.zip
    fi

    # Symbols Nerd Font
    if ! fc-list | grep -qi "Symbols Nerd Font"; then
        log_info "Downloading Symbols Nerd Font..."
        curl -fLo /tmp/Symbols.zip \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SymbolsOnly.zip"
        unzip -o /tmp/Symbols.zip -d "$font_dir"
        rm /tmp/Symbols.zip
    fi

    # Bibata cursor theme
    if [ ! -d "$HOME/.local/share/icons/Bibata-Modern-Classic" ]; then
        log_info "Downloading Bibata cursor theme..."
        curl -fLo /tmp/Bibata.zip \
            "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.zip"
        unzip -o /tmp/Bibata.zip -d "$HOME/.local/share/icons/"
        rm /tmp/Bibata.zip
    fi

    fc-cache -fv
    log_success "Fonts installed"
}

# ── Wallpaper ──────────────────────────────
setup_wallpaper() {
    log_step "Setting up wallpaper..."

    local wallpaper_dir="$HOME/Pictures"
    mkdir -p "$wallpaper_dir"

    if [ ! -f "$HOME/wallpaper.jpg" ]; then
        log_info "Downloading default wallpaper..."
        curl -fLo "$HOME/wallpaper.jpg" \
            "https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/lock-screen/catppuccin-mocha-wallpaper.png" 2>/dev/null || \
        curl -fLo "$HOME/wallpaper.jpg" \
            "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1920&q=80" 2>/dev/null || \
        log_warn "Could not download wallpaper. Set your own at ~/wallpaper.jpg"
    fi
}

# ── Deploy Configs ────────────────────────
deploy_configs() {
    log_step "Deploying configuration files..."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Backup existing configs
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    local backed_up=false

    local config_dirs=("hypr" "waybar" "kitty" "wlogout" "starship")
    for dir in "${config_dirs[@]}"; do
        if [ -d "$HOME/.config/$dir" ]; then
            if [ "$backed_up" = false ]; then
                mkdir -p "$backup_dir"
                backed_up=true
                log_info "Backing up existing configs to $backup_dir"
            fi
            cp -r "$HOME/.config/$dir" "$backup_dir/"
        fi
    done

    # Hyprland
    mkdir -p "$HOME/.config/hypr"
    cp -r "$SCRIPT_DIR/hyprland/"* "$HOME/.config/hypr/"

    # Waybar
    mkdir -p "$HOME/.config/waybar"
    cp "$SCRIPT_DIR/hyprland/waybar/"* "$HOME/.config/waybar/"

    # Kitty
    mkdir -p "$HOME/.config/kitty"
    cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"

    # Wlogout
    mkdir -p "$HOME/.config/wlogout"
    cp "$SCRIPT_DIR/wlogout/"* "$HOME/.config/wlogout/"

    # Starship
    mkdir -p "$HOME/.config"
    cp "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

    # Zsh
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # Neovim
    mkdir -p "$HOME/.config/nvim"
    cp -r "$SCRIPT_DIR/nvim/"* "$HOME/.config/nvim/"

    log_success "Configs deployed"
}

# ── Post-Install ──────────────────────────
post_install() {
    log_step "Post-installation setup..."

    # Set Zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting Zsh as default shell..."
        chsh -s "$(which zsh)" 2>/dev/null || log_warn "Could not change shell automatically. Run: chsh -s \$(which zsh)"
    fi

    # Enable Cava config
    mkdir -p "$HOME/.config/cava"
    cat > "$HOME/.config/cava/config.ini" << 'CAVA_EOF'
[general]
framerate = 60
bars = 8
bar_width = 2
bar_spacing = 0
bar_height = 12
lower_cutoff_freq = 50
higher_cutoff_freq = 10000
sensitivity = 100
autosens = 1
monstercat = 0
waves = 0
noise = 0

[input]
source = auto

[output]
method = auto
CAVA_EOF

    log_success "Post-installation complete"
}

# ── Print Summary ──────────────────────────
print_summary() {
    echo ""
    echo -e "${PURPLE}  ╔══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}  ║         Installation Complete!           ║${NC}"
    echo -e "${PURPLE}  ╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Installed packages:${NC}"
    echo -e "    ${INFO} Hyprland + Waybar + Wofi + Wlogout"
    echo -e "    ${INFO} Kitty + Zsh + Starship + Neovim"
    echo -e "    ${INFO} Fastfetch + Btop + Cava + Bat"
    echo ""
    echo -e "  ${BOLD}Keybindings:${NC}"
    echo -e "    ${CYAN}Mod + Enter${NC}     → Terminal (Kitty)"
    echo -e "    ${CYAN}Mod + Q${NC}         → Close window"
    echo -e "    ${CYAN}Mod + D${NC}         → App launcher (Wofi)"
    echo -e "    ${CYAN}Mod + E${NC}         → File manager"
    echo -e "    ${CYAN}Mod + F${NC}         → Fullscreen"
    echo -e "    ${CYAN}Mod + V${NC}         → Toggle floating"
    echo -e "    ${CYAN}Mod + 1-9${NC}       → Switch workspace"
    echo -e "    ${CYAN}Print${NC}           → Screenshot"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "    1. Log out and select Hyprland from your display manager"
    echo -e "    2. Place a wallpaper at ~/wallpaper.jpg"
    echo -e "    3. Edit ~/.config/hypr/hyprland.conf for personal tweaks"
    echo -e "    4. Enjoy your minimalistic setup!"
    echo ""
    if [ -d "$backup_dir" ]; then
        echo -e "  ${BOLD}Backup:${NC} Previous configs saved at:"
        echo -e "    ${CYAN}$backup_dir${NC}"
        echo ""
    fi
}

# ── Main ────────────────────────────────────
main() {
    print_banner
    check_not_root
    detect_distro

    echo ""
    log_info "This will install the following:"
    echo -e "    ${INFO} Hyprland, Waybar, Wofi, Wlogout"
    echo -e "    ${INFO} Kitty, Zsh, Starship, Neovim"
    echo -e "    ${INFO} Fastfetch, Btop, Cava, Bat, Ripgrep, fd, fzf"
    echo -e "    ${INFO} JetBrainsMono Nerd Font, Bibata cursor"
    echo -e "    ${INFO} All configuration files"
    echo ""

    if ! confirm "Proceed with installation?"; then
        log_info "Installation cancelled."
        exit 0
    fi

    install_core_packages
    install_terminal_shell
    install_cli_tools
    install_fonts
    setup_wallpaper
    deploy_configs
    post_install
    print_summary
}

main "$@"
