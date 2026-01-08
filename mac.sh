#!/usr/bin/env bash
set -euo pipefail

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                     DOTFILES SETUP - macOS                                ║
# ║              Idempotent bootstrap script for macOS                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim tmux zsh starship ghostty aerospace)

# ─── State Tracking ──────────────────────────────────────────────────────────
STOW_SUCCESS=()
STOW_FAILED=()
BACKUPS_CREATED=()

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                            HELPER FUNCTIONS                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() {
    command -v "$1" &>/dev/null
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                          BACKUP FUNCTIONS                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

backup_if_exists() {
    local target="$1"
    
    # Skip if target doesn't exist
    [[ ! -e "$target" ]] && return 0
    
    # Skip if it's already a symlink (stow will handle it)
    [[ -L "$target" ]] && return 0
    
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    
    mv "$target" "$backup"
    log_warn "Backed up: $target -> $backup"
    BACKUPS_CREATED+=("$backup")
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                        INSTALLATION FUNCTIONS                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session (Apple Silicon)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

install_dependencies() {
    log_info "Installing dependencies via Homebrew..."
    
    local packages=(stow neovim tmux starship)
    local casks=(ghostty font-jetbrains-mono-nerd-font)
    
    log_info "Installing packages: ${packages[*]}"
    brew install "${packages[@]}"
    
    log_info "Installing casks: ${casks[*]}"
    brew install --cask "${casks[@]}"
    
    log_info "Installing aerospace"
    brew install nikitabobko/tap/aerospace
    
    log_success "Dependencies installed"
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh-My-Zsh already installed"
        return 0
    fi
    
    log_info "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh-My-Zsh installed"
}

install_bun() {
    if command_exists bun; then
        log_success "Bun already installed"
        return 0
    fi
    
    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    log_success "Bun installed"
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                            STOW FUNCTIONS                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

get_stow_target() {
    local package="$1"
    case "$package" in
        zsh)       echo "$HOME/.zshrc" ;;
        nvim)      echo "$HOME/.config/nvim" ;;
        tmux)      echo "$HOME/.config/tmux" ;;
        starship)  echo "$HOME/.config/starship.toml" ;;
        ghostty)   echo "$HOME/.config/ghostty" ;;
        aerospace) echo "$HOME/.config/aerospace" ;;
    esac
}

stow_package() {
    local package="$1"
    local target
    target=$(get_stow_target "$package")
    
    log_info "Stowing $package..."
    
    # Backup existing files/dirs
    backup_if_exists "$target"
    
    if stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$package" 2>/dev/null; then
        log_success "Stowed $package"
        STOW_SUCCESS+=("$package")
    else
        log_error "Failed to stow $package"
        STOW_FAILED+=("$package")
    fi
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                              SUMMARY                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

print_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "                           SUMMARY                                 "
    echo "═══════════════════════════════════════════════════════════════════"
    
    if [[ ${#STOW_SUCCESS[@]} -gt 0 ]]; then
        log_success "Stowed: ${STOW_SUCCESS[*]}"
    fi
    
    if [[ ${#STOW_FAILED[@]} -gt 0 ]]; then
        log_error "Failed: ${STOW_FAILED[*]}"
    fi
    
    if [[ ${#BACKUPS_CREATED[@]} -gt 0 ]]; then
        log_warn "Backups created:"
        for backup in "${BACKUPS_CREATED[@]}"; do
            echo "    - $backup"
        done
    fi
    
    echo "═══════════════════════════════════════════════════════════════════"
}

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                               MAIN                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

main() {
    echo "═══════════════════════════════════════════════════════════════════"
    echo "                    DOTFILES SETUP - macOS                         "
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    
    # Install dependencies
    install_homebrew
    install_dependencies
    install_oh_my_zsh
    install_bun
    
    # Ensure .config exists
    mkdir -p "$HOME/.config"
    
    # Stow all packages
    for package in "${PACKAGES[@]}"; do
        stow_package "$package"
    done
    
    print_summary
}

main
