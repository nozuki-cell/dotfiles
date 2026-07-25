<div align="center">

# ── Minimalistic Hyprland Dotfiles ──

**A clean, transparent, and minimal Hyprland rice with Catppuccin Mocha colors**

![Hyprland](https://img.shields.io/badge/Hyprland-blue?style=flat-square&logo=hyprland)
![Arch](https://img.shields.io/badge/Arch%20Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)

</div>

---

## What's Included

| Category | Package | Description |
|----------|---------|-------------|
| **Compositor** | Hyprland | Dynamic tiling Wayland compositor |
| **Bar** | Waybar | Status bar with music, clock, system tray |
| **Launcher** | Wofi | Application launcher |
| **Terminal** | Kitty | GPU-accelerated terminal emulator |
| **Shell** | Zsh + Starship | Fast shell with beautiful prompt |
| **Editor** | Neovim | Modal text editor with LSP support |
| **System** | Fastfetch | System info fetch |
| **Monitoring** | Btop + Cava | System monitor + audio visualizer |

## Features

- **Fully transparent** windows and bar with blur effects
- **Catppuccin Mocha** color scheme throughout
- **Music integration** - now playing on waybar via playerctl
- **Audio visualizer** - live cava display on waybar
- **Minimal keybinds** - clean and memorable
- **Cross-platform** - Works on Arch and Debian/Ubuntu

## Keybindings

| Key | Action |
|-----|--------|
| `Super + Enter` | Open terminal |
| `Super + Q` | Close window |
| `Super + D` | App launcher |
| `Super + E` | File manager |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + Shift + H/J/K/L` | Move window |
| `Print` | Screenshot (area) |
| `Super + Print` | Screenshot (full) |
| `Super + Shift + V` | Clipboard history |

## Installation

### One-line install

```bash
git clone https://github.com/nozuki-cell/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

### Supported Systems

- **Arch Linux** and derivatives (Manjaro, EndeavourOS, etc.)
- **Ubuntu 22.04+** / **Debian 12+**

The installer will:
1. Detect your distribution automatically
2. Install all required packages
3. Install JetBrainsMono Nerd Font and Bibata cursor theme
4. Back up any existing configs
5. Deploy all configuration files
6. Set Zsh as default shell

## Manual Installation

<details>
<summary>Click to expand manual install instructions</summary>

### Arch Linux

```bash
sudo pacman -S hyprland waybar wofi kitty zsh neovim \
    xdg-desktop-portal-hyprland grimblast-git wl-clipboard \
    cliphist brightnessctl playerctl fastfetch btop cava \
    bat ripgrep fzf starship
```

### Ubuntu / Debian

```bash
# Hyprland PPA
sudo add-apt-repository ppa:aslatter/ppa
sudo apt update
sudo apt install hyprland waybar wofi kitty zsh neovim \
    wl-clipboard brightnessctl playerctl pavucontrol fzf

# Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Fonts
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv
```

### Deploy configs

```bash
cp -r hyprland/* ~/.config/hypr/
cp -r hyprland/waybar/* ~/.config/waybar/
cp kitty/kitty.conf ~/.config/kitty/
cp wlogout/* ~/.config/wlogout/
cp starship/starship.toml ~/.config/starship.toml
cp zsh/.zshrc ~/.zshrc
cp -r nvim/* ~/.config/nvim/
```

</details>

## Configuration Files

```
.
├── hyprland/
│   ├── hyprland.conf        # Main Hyprland config
│   └── waybar/
│       ├── config.jsonc     # Waybar layout and modules
│       └── style.css        # Waybar styling
├── kitty/
│   └── kitty.conf           # Terminal config
├── nvim/
│   └── init.lua             # Neovim config (Lazy.nvim)
├── wlogout/
│   ├── layout               # Power menu layout
│   └── style.css            # Power menu styling
├── starship/
│   └── starship.toml        # Shell prompt config
├── zsh/
│   └── .zshrc               # Shell config
├── install.sh               # Installation script
└── README.md
```

## Customization

### Colors

All configs use **Catppuccin Mocha** palette. Key colors:

| Color | Hex | Usage |
|-------|-----|-------|
| Base | `#11111B` | Backgrounds |
| Text | `#CDD6F4` | Primary text |
| Blue | `#89B4FA` | Clock, active elements |
| Mauve | `#CBA6F7` | Music player, accents |
| Teal | `#94E2D5` | Cava, git branch |
| Red | `#F38BA8` | Power button, errors |

### Transparency

Adjust window opacity in `hypr.conf`:

```ini
decoration {
    active_opacity = 0.92    # Active windows
    inactive_opacity = 0.85  # Inactive windows
    blur {
        size = 8             # Blur radius
        passes = 3           # Blur quality
    }
}
```

### Waybar Modules

Edit `waybar/config.jsonc` to add/remove modules. Current layout:

- **Left**: Music player + Cava visualizer
- **Center**: Clock
- **Right**: Volume, WiFi, Battery, Tray, Power

## Uninstall

```bash
# Remove configs (backups are in ~/.config-backup-*)
rm -rf ~/.config/{hypr,waybar,kitty,wlogout}
rm -f ~/.config/starship.toml
rm -f ~/.zshrc

# Remove fonts
rm -rf ~/.local/share/fonts/{JetBrainsMono*,Symbols*}
fc-cache -fv
```

## Credits

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Color scheme
- [Hyprland](https://github.com/hyprwm/Hyprland) - Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Status bar
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) - Icons

---

<div align="center">

**Made with care for the minimal desktop experience**

</div>
