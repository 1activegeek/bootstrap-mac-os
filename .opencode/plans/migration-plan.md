# Bootstrap macOS Migration Plan

## Complete Rewrite: Ansible → Pure Shell + Chezmoi + Brew Bundle

**Created:** 2026-02-18
**Status:** Planning
**Branch:** `v2` (to be created from `master`)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architectural Overview](#architectural-overview)
3. [Target Directory Structure](#target-directory-structure)
4. [Dependency Graph](#dependency-graph)
5. [Phase 0: Preparation & Research](#phase-0-preparation--research)
6. [Phase 1: Repository Scaffolding & Bootstrap Core](#phase-1-repository-scaffolding--bootstrap-core)
7. [Phase 2: Brewfile & Package Management](#phase-2-brewfile--package-management)
8. [Phase 3: macOS Defaults & System Configuration](#phase-3-macos-defaults--system-configuration)
9. [Phase 4: ZSH Configuration (Replace Oh My Zsh)](#phase-4-zsh-configuration-replace-oh-my-zsh)
10. [Phase 5: Chezmoi & Dotfiles Management](#phase-5-chezmoi--dotfiles-management)
11. [Phase 6: 1Password Integration & Secrets](#phase-6-1password-integration--secrets)
12. [Phase 7: Dock Configuration](#phase-7-dock-configuration)
13. [Phase 8: Interactive Menu & Machine Profiles](#phase-8-interactive-menu--machine-profiles)
14. [Phase 9: Modern CLI Tools Integration](#phase-9-modern-cli-tools-integration)
15. [Phase 10: Migration, Testing & GitHub Move](#phase-10-migration-testing--github-move)
16. [Risk Register](#risk-register)
17. [Research Items Index](#research-items-index)
18. [Rollback Strategy](#rollback-strategy)

---

## Executive Summary

This plan migrates the existing Ansible-based macOS bootstrap tool to a pure shell script architecture using `brew bundle`, `chezmoi`, and modular ZSH configuration. The migration preserves the current `master` branch untouched and develops all new work on a `v2` branch.

**Key architectural decisions:**
- Single `bootstrap.sh` entry point with two-phase execution (pre/post 1Password)
- `brew bundle` with a single `Brewfile` replaces all Ansible homebrew/mas tasks
- `chezmoi` with 1Password integration replaces Mackup for dotfile/secret management
- Modular `~/.zshrc.d/*.zsh` files replace Oh My Zsh
- Starship replaces the ZSH prompt
- Machine profiles (work/personal/homelab/minimal) drive conditional installation

**Estimated effort:** 10 phases, each independently testable.

---

## Architectural Overview

```
User runs bootstrap.sh (via curl | bash)
        │
        ▼
┌─────────────────────────┐
│   Interactive Menu       │
│   - Machine profile      │
│   - Hostname             │
│   - Module toggles       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────────────────────────┐
│  PHASE 1 (Unattended)                       │
│  1. Install Xcode CLI tools                 │
│  2. Install Homebrew                        │
│  3. brew bundle (Brewfile)                  │
│     - formulae, casks, mas apps             │
│     - includes 1password + 1password-cli    │
│  4. Set hostname (if provided)              │
│  5. Apply macOS defaults                    │
│  6. Configure Dock via dockutil             │
│  7. Deploy non-sensitive dotfiles           │
│     (chezmoi init from dotfiles repo)       │
│  8. ZSH configuration                       │
│     (.zshrc + .zshrc.d/ modules)            │
│  9. Create symlinks                         │
│  10. Configure Homebrew autoupdate           │
└──────────┬──────────────────────────────────┘
           │
           ▼
┌──────────────────────────┐
│  PAUSE                   │
│  "Sign into 1Password"   │
│  (GUI app + CLI auth)    │
│  Wait for user confirm   │
└──────────┬───────────────┘
           │
           ▼
┌─────────────────────────────────────────────┐
│  PHASE 2 (Unattended)                       │
│  1. Verify 1Password CLI auth               │
│  2. chezmoi apply (secrets)                 │
│     - SSH keys via 1Password templates      │
│     - .config/1password/                    │
│  3. Git configuration (signed commits etc)  │
│  4. Post-install validation                 │
│  5. Summary report                          │
└─────────────────────────────────────────────┘
```

---

## Target Directory Structure

### Bootstrap Repo Structure

```
bootstrap-mac-os/
├── bootstrap.sh                  # Single entry point
├── Brewfile                      # brew bundle file (all packages)
├── profiles/                     # Machine profile overrides
│   ├── work.sh                   # Work-specific config + Brewfile.work
│   ├── personal.sh               # Personal-specific config + Brewfile.personal
│   ├── homelab.sh                # Homelab-specific config + Brewfile.homelab
│   └── minimal.sh                # Minimal config + Brewfile.minimal
├── lib/                          # Shared shell library functions
│   ├── utils.sh                  # Logging, colors, error handling
│   ├── menu.sh                   # Interactive menu system
│   └── checks.sh                 # Verification/validation helpers
├── modules/                      # Modular install scripts
│   ├── 01-homebrew.sh            # Homebrew install + brew bundle
│   ├── 02-hostname.sh            # Set hostname via scutil
│   ├── 03-macos-defaults.sh      # All defaults write commands
│   ├── 04-dock.sh                # Dock configuration via dockutil
│   ├── 05-zsh.sh                 # ZSH setup (modules, starship)
│   ├── 06-chezmoi.sh             # Chezmoi init + apply (non-secrets)
│   ├── 07-symlinks.sh            # Create symlinks
│   ├── 08-homebrew-autoupdate.sh # Homebrew autoupdate tap config
│   ├── 09-1password-secrets.sh   # 1Password + chezmoi secrets (Phase 2)
│   └── 10-post-install.sh        # Validation + summary
├── config/                       # Configuration data files
│   ├── dock-remove.txt           # Apps to remove from dock (one per line)
│   ├── dock-add.txt              # Apps to add (name|path|pos|section)
│   └── macos-defaults.sh         # Extracted defaults commands for readability
├── dotfiles/                     # Reference: what chezmoi manages
│   └── README.md                 # Points to separate dotfiles repo
├── README.md
├── LICENSE
└── .gitignore
```

### Dotfiles Repo Structure (Separate Repo, Managed by Chezmoi)

```
dotfiles/                                  # github.com/shawnmix/dotfiles
├── .chezmoi.toml.tmpl                     # Chezmoi config template
├── .chezmoiignore                         # Platform/profile-specific ignores
├── dot_zshrc                              # .zshrc (loads modules + starship)
├── dot_zprofile                           # .zprofile (Homebrew shellenv)
├── dot_zshrc.d/                           # Modular ZSH config
│   ├── 01-history.zsh                     # History config (or atuin)
│   ├── 02-aliases.zsh                     # Generic aliases
│   ├── 03-git.zsh                         # Git aliases + helpers
│   ├── 04-brew.zsh                        # Homebrew aliases
│   ├── 05-macos.zsh                       # macOS helpers (showfiles etc)
│   ├── 06-docker.zsh                      # Docker shortcuts
│   ├── 07-1password.zsh                   # 1Password CLI helpers
│   ├── 08-extract.zsh                     # Universal archive extractor
│   ├── 09-colorize.zsh                    # Color testing
│   ├── 10-kubectl.zsh                     # Kubernetes aliases + completion
│   ├── 11-kube-ps1.zsh                    # K8s context in prompt
│   ├── 12-kubectx.zsh                     # kubectx/kubens aliases
│   ├── 13-sudo.zsh                        # Esc-Esc sudo widget
│   └── 14-fzf.zsh                         # fzf key bindings + completion
├── dot_gitconfig                          # .gitconfig (non-secret parts)
├── dot_config/                            # .config/ subdirectories
│   ├── starship.toml                      # Starship prompt config
│   ├── atuin/                             # Atuin config
│   ├── ghostty/                           # Ghostty config
│   ├── zellij/                            # Zellij config
│   ├── nvim/                              # Neovim config
│   └── ...                                # Other .config dirs
├── private_dot_ssh/                       # SSH (1Password templated)
│   ├── config.tmpl                        # chezmoi template with 1Password
│   └── ...
└── private_dot_config/
    └── 1password/                         # 1Password config (templated)
```

---

## Dependency Graph

```
Phase 0 (Research)
    │
    ▼
Phase 1 (Scaffolding) ─────────────────────────────┐
    │                                                │
    ├──► Phase 2 (Brewfile)                          │
    │        │                                       │
    │        ├──► Phase 3 (macOS Defaults)            │
    │        │                                       │
    │        ├──► Phase 4 (ZSH Config)               │
    │        │        │                              │
    │        │        └──► Phase 9 (Modern CLI)       │
    │        │                                       │
    │        ├──► Phase 7 (Dock)                     │
    │        │                                       │
    │        └──► Phase 5 (Chezmoi Non-Secrets)      │
    │                 │                              │
    │                 └──► Phase 6 (1Password)       │
    │                                                │
    └──► Phase 8 (Interactive Menu + Profiles)  ◄────┘
              │
              ▼
         Phase 10 (Testing + GitHub Migration)
```

**Key dependency rules:**
- Phase 1 must be complete before any other phase
- Phase 2 (Brewfile) is prerequisite for Phases 3, 4, 5, 7 (they need tools installed)
- Phase 5 (Chezmoi non-secrets) must precede Phase 6 (1Password secrets)
- Phase 8 (menu/profiles) integrates all previous modules; do it late
- Phase 9 (modern CLI) depends on Phase 4 (ZSH) for shell integration
- Phase 10 is final integration/validation

---

## Phase 0: Preparation & Research

**Goal:** Resolve unknowns and make design decisions before writing code.

**Duration:** 1-2 sessions

### Research Items

#### R1: Chezmoi + 1Password Integration Pattern
- [ ] Test `chezmoi` template syntax for 1Password secret retrieval
- [ ] Determine: `op read` vs `op inject` vs chezmoi's native `onepassword` template function
- [ ] Verify: Can chezmoi manage `~/.ssh/config` while leaving `id_gitea` unmanaged?
- [ ] Test: `chezmoiignore` patterns for conditional file deployment by machine profile
- [ ] Document: The exact flow for initial chezmoi setup on a fresh machine (no secrets yet)

**Key question:** Should the dotfiles repo be a separate GitHub repo (managed by `chezmoi init`) or embedded in the bootstrap repo? **Recommendation:** Separate repo. Chezmoi is designed to work with its own source repo, and this keeps bootstrap logic separate from dotfile content.

#### R2: Brewfile Strategy
- [ ] Test: `brew bundle --file=Brewfile` with MAS apps (does it need pre-auth?)
- [ ] Verify: Can `brew bundle` handle taps inline (e.g., `tap "hashicorp/tap"` then `brew "hashicorp/tap/terraform"`)?
- [ ] Test: Profile-specific Brewfiles (can you `brew bundle` multiple files, or use conditionals?)
- [ ] Verify: `dockutil` no longer needs the `hpedrorodrigues/tools` tap (per requirements)
- [ ] Check: Current state of `openscad` cask (noted as needing fix)

**Brewfile profile strategy options:**
1. Single Brewfile with comments marking profile sections, script filters at runtime
2. Base Brewfile + profile-specific Brewfile overlays (`Brewfile.work`, etc.)
3. Chezmoi-templated Brewfile

**Recommendation:** Option 2 — base + overlays. Run `brew bundle --file=Brewfile && brew bundle --file=Brewfile.${PROFILE}`.

#### R3: LuLu Automation
- [ ] Research: Can LuLu be silently configured post-install? (GitHub issue reference)
- [ ] Test: Does installing via cask + running a defaults write achieve silent mode?
- [ ] Fallback: Document as manual step if not automatable

#### R4: macOS Defaults for New Requirements
- [ ] Research: `defaults write` command for mouse cursor lighter color
- [ ] Research: Desktop wallpaper folder source + fit-to-screen via `defaults write` or `osascript`
- [ ] Research: Disabling screenshot shortcut (`defaults write com.apple.symbolichotkeys`)
- [ ] Research: Kap shortcut registration for Cmd+Shift+3
- [ ] Research: Catppuccin theme automation (which apps, what config format)
- [ ] Test: Natural scrolling ON command (reverse current `com.apple.swipescrolldirection false`)

#### R5: Atuin vs History.zsh
- [ ] Install atuin locally and test
- [ ] Determine: Does atuin fully replace ZSH history config, or do you still need `HISTSIZE`/`SAVEHIST`?
- [ ] Decision: Keep `history.zsh` as fallback, or replace entirely?

**Recommendation:** Keep `history.zsh` as a thin shim that sets `HISTSIZE`/`SAVEHIST` (still needed for ZSH's built-in `history` command) but let atuin handle the actual search/sync.

#### R6: SSH Key Strategy with 1Password
- [ ] Document: Which SSH keys live in 1Password vs. raw on disk
- [ ] Confirm: `id_gitea` stays raw (for Obsidian sync)
- [ ] Design: chezmoi template for `~/.ssh/config` that references 1Password agent vs raw keys
- [ ] Test: 1Password SSH agent with `IdentityAgent` in SSH config

#### R7: Starship Prompt Layout Switching
- [ ] Design: Easy way to switch prompt layouts (code, k8s, azure, aws contexts)
- [ ] Options: Multiple `starship.toml` presets + shell function to swap, or single config with conditional modules
- [ ] Test: Starship's `[env_var]` and conditional modules for context-aware display

### Tasks

- [ ] Create `v2` branch from `master`
- [ ] Set up a test environment (VM or secondary user account) for validation
- [ ] Complete all research items above and document decisions
- [ ] Create the separate `dotfiles` repo on GitHub (empty, private initially)

### Validation
- All research questions have documented answers
- Branch `v2` exists and `master` is untouched
- Test environment is available

---

## Phase 1: Repository Scaffolding & Bootstrap Core

**Goal:** Create the directory structure, library functions, and minimal `bootstrap.sh` that installs Homebrew.

**Dependencies:** Phase 0 complete
**Produces:** A working `bootstrap.sh` that installs Xcode CLI tools + Homebrew on a clean Mac.

### Tasks

#### 1.1 Create directory structure
```bash
mkdir -p lib modules profiles config dotfiles
```

#### 1.2 Implement `lib/utils.sh`
Shared functions used by all modules:

```bash
#!/usr/bin/env bash
# lib/utils.sh - Shared utility functions

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logging
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step()    { echo -e "\n${BOLD}${CYAN}==> $*${NC}"; }

# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Check if running on macOS
require_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script requires macOS."
    exit 1
  fi
}

# Check if running on Apple Silicon
is_apple_silicon() { [[ "$(uname -m)" == "arm64" ]]; }

# Homebrew prefix (differs between Intel and Apple Silicon)
brew_prefix() {
  if is_apple_silicon; then
    echo "/opt/homebrew"
  else
    echo "/usr/local"
  fi
}

# Ask for sudo upfront and keep alive
sudo_keepalive() {
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

# Run a module script
run_module() {
  local module="$1"
  local script="modules/${module}"
  if [[ -f "$script" ]]; then
    log_step "Running module: ${module}"
    source "$script"
  else
    log_error "Module not found: ${script}"
    return 1
  fi
}
```

#### 1.3 Implement `lib/checks.sh`
Validation and prerequisite checks:

```bash
#!/usr/bin/env bash
# lib/checks.sh - Verification helpers

# Verify Homebrew is installed and working
check_homebrew() {
  if command_exists brew; then
    log_success "Homebrew is installed: $(brew --version | head -1)"
    return 0
  else
    log_error "Homebrew is not installed"
    return 1
  fi
}

# Verify 1Password CLI is authenticated
check_op_auth() {
  if op account list &>/dev/null; then
    log_success "1Password CLI is authenticated"
    return 0
  else
    log_warn "1Password CLI is not authenticated"
    return 1
  fi
}

# Verify chezmoi is installed
check_chezmoi() {
  if command_exists chezmoi; then
    log_success "chezmoi is installed: $(chezmoi --version)"
    return 0
  else
    log_error "chezmoi is not installed"
    return 1
  fi
}

# Check if an app is installed (by bundle path)
app_installed() {
  local app_name="$1"
  [[ -d "/Applications/${app_name}.app" ]] || \
  [[ -d "/System/Applications/${app_name}.app" ]] || \
  [[ -d "$HOME/Applications/${app_name}.app" ]]
}
```

#### 1.4 Implement `bootstrap.sh` (minimal Phase 1 version)

```bash
#!/usr/bin/env bash
#
# bootstrap.sh - macOS Bootstrap Tool
# Single entry point for setting up a fresh macOS installation.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/shawnmix/bootstrap-mac-os/v2/bootstrap.sh | bash
#   OR
#   ./bootstrap.sh
#

set -euo pipefail

# Determine script directory (works for both local and piped execution)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Running via curl | bash — clone repo first
  BOOTSTRAP_DIR="$HOME/.bootstrap"
  if [[ -d "$BOOTSTRAP_DIR" ]]; then
    rm -rf "$BOOTSTRAP_DIR"
  fi
  git clone -b v2 https://github.com/shawnmix/bootstrap-mac-os.git "$BOOTSTRAP_DIR"
  exec "$BOOTSTRAP_DIR/bootstrap.sh"
fi

# Load libraries
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/checks.sh"

# Ensure macOS
require_macos

echo ""
echo "================================================"
echo "  macOS Bootstrap Tool"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================"
echo ""

# Will be replaced by interactive menu in Phase 8
# For now, hardcode defaults for testing
MACHINE_PROFILE="${MACHINE_PROFILE:-personal}"
NEW_HOSTNAME="${NEW_HOSTNAME:-}"
ENABLED_MODULES="homebrew,macos-defaults,dock,zsh,chezmoi,symlinks"

# Request sudo
log_step "Requesting administrator access..."
sudo_keepalive

# ========== PHASE 1: Core Setup ==========
log_step "Phase 1: Core Setup"

run_module "01-homebrew.sh"
[[ -n "$NEW_HOSTNAME" ]] && run_module "02-hostname.sh"
run_module "03-macos-defaults.sh"
run_module "04-dock.sh"
run_module "05-zsh.sh"
run_module "06-chezmoi.sh"
run_module "07-symlinks.sh"
run_module "08-homebrew-autoupdate.sh"

# ========== PAUSE: 1Password ==========
log_step "Phase 1 Complete!"
echo ""
log_warn "ACTION REQUIRED:"
echo "  1. Open 1Password and sign in"
echo "  2. Enable 1Password CLI integration in 1Password > Settings > Developer"
echo "  3. Run: op signin"
echo ""
read -rp "Press Enter when 1Password is configured, or 'q' to quit: " response
if [[ "$response" == "q" ]]; then
  log_info "Exiting. Run './bootstrap.sh --phase2' to continue later."
  exit 0
fi

# ========== PHASE 2: Secrets ==========
log_step "Phase 2: Secrets & Final Configuration"

run_module "09-1password-secrets.sh"
run_module "10-post-install.sh"

log_success "Bootstrap complete!"
```

#### 1.5 Implement `modules/01-homebrew.sh`

```bash
#!/usr/bin/env bash
# modules/01-homebrew.sh - Install Homebrew and run brew bundle

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &>/dev/null; then
  log_info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait for installation to complete
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  log_success "Xcode Command Line Tools installed"
else
  log_success "Xcode Command Line Tools already installed"
fi

# Install Homebrew if needed
if ! command_exists brew; then
  log_info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH for this session
  eval "$($(brew_prefix)/bin/brew shellenv)"
  log_success "Homebrew installed"
else
  log_success "Homebrew already installed"
fi

# Ensure brew is in PATH
eval "$($(brew_prefix)/bin/brew shellenv)"

# Disable analytics
brew analytics off

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Run brew bundle
log_info "Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile" --no-lock

# Run profile-specific Brewfile if it exists
local profile_brewfile="$SCRIPT_DIR/profiles/Brewfile.${MACHINE_PROFILE}"
if [[ -f "$profile_brewfile" ]]; then
  log_info "Installing profile-specific packages (${MACHINE_PROFILE})..."
  brew bundle --file="$profile_brewfile" --no-lock
fi

log_success "Homebrew packages installed"
```

#### 1.6 Implement `modules/02-hostname.sh`

```bash
#!/usr/bin/env bash
# modules/02-hostname.sh - Set machine hostname

if [[ -z "${NEW_HOSTNAME:-}" ]]; then
  log_info "No hostname specified, skipping."
  return 0
fi

log_info "Setting hostname to: ${NEW_HOSTNAME}"

sudo scutil --set ComputerName "${NEW_HOSTNAME}"
sudo scutil --set HostName "${NEW_HOSTNAME}"
sudo scutil --set LocalHostName "${NEW_HOSTNAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server \
  NetBIOSName -string "${NEW_HOSTNAME}"

log_success "Hostname set to: ${NEW_HOSTNAME}"
```

### Validation
- [ ] Run `bootstrap.sh` on a clean test user — Homebrew installs successfully
- [ ] Run `bootstrap.sh` on an existing setup — Homebrew detected as already installed, skips
- [ ] Module scripts source cleanly without errors when libraries are loaded
- [ ] `set -euo pipefail` catches errors correctly
- [ ] Hostname module sets all four hostname values when name provided
- [ ] Hostname module skips cleanly when no name provided

---

## Phase 2: Brewfile & Package Management

**Goal:** Create the complete Brewfile with all packages, casks, and MAS apps. Implement profile-specific overlays.

**Dependencies:** Phase 1 (Homebrew module works)
**Produces:** Running `brew bundle` installs all desired software.

### Tasks

#### 2.1 Create base `Brewfile`

The Brewfile consolidates everything from the current `config.yml` with all requested additions and removals applied.

```ruby
# Brewfile - macOS Bootstrap
# Base packages installed on all profiles

# ============================================
# Taps
# ============================================
tap "homebrew/bundle"
tap "homebrew/services"
tap "hashicorp/tap"
tap "anomalyco/tap"                    # opencode

# ============================================
# Formulae (CLI tools)
# ============================================

# Core utilities
brew "age"                              # Encryption
brew "awscli"                           # AWS CLI
brew "chroma"                           # Syntax highlighting
brew "duti"                             # Default app handler
brew "eza"                              # Modern ls replacement
brew "fastfetch"                        # System info (replaces neofetch)
brew "fzf"                              # Fuzzy finder
brew "mas"                              # Mac App Store CLI
brew "pinentry-mac"                     # GPG pinentry for Homebrew autoupdate
brew "pygments"                         # Syntax highlighting (Python)
brew "starship"                         # Cross-shell prompt
brew "switchaudio-osx"                  # Audio device switcher
brew "zoxide"                           # Smart cd replacement
brew "zsh-autosuggestions"              # ZSH autosuggestions
brew "zsh-syntax-highlighting"          # ZSH syntax highlighting

# Modern CLI tools
brew "atuin"                            # Shell history replacement
brew "zellij"                           # Terminal multiplexer (replaces tmux)

# DevOps / Infrastructure
brew "helm"                             # Kubernetes package manager
brew "k9s"                              # Kubernetes TUI
brew "kube-ps1"                         # K8s context in prompt
brew "kubectx"                          # Switch k8s contexts
brew "kubernetes-cli"                   # kubectl
brew "hashicorp/tap/terraform"          # Terraform (from HashiCorp tap)

# Dotfile management
brew "chezmoi"                          # Dotfile manager

# opencode
brew "anomalyco/tap/opencode"          # opencode CLI

# ============================================
# Casks (GUI applications)
# ============================================

# Productivity
cask "1password"
cask "1password-cli"
cask "clickup"
cask "notion"
cask "notion-calendar"
cask "notion-mail"
cask "pronotes"
cask "raycast"

# Browsers
cask "firefox"
cask "google-chrome"
cask "tor-browser"

# Communication
cask "discord"
cask "microsoft-teams"
cask "signal"
cask "slack"
cask "zoom"

# Development
cask "dockutil"                         # Dock management (no longer needs tap)
cask "docker"
cask "drawio"
cask "ghostty"                          # Terminal emulator
cask "postman"
cask "powershell"
cask "sequel-ace"
cask "visual-studio-code"

# Media
cask "handbrake"
cask "kap"                              # Screen recording (replaces screenshot shortcut)
cask "obs"
cask "subler"
cask "vlc"

# Utilities
cask "android-file-transfer"
cask "appcleaner"
cask "balenaetcher"
cask "browserosaurus"                   # Browser picker
cask "cyberduck"
cask "dash"
cask "disk-inventory-x"
cask "flux"
cask "jordanbaird-ice"                  # Menu bar manager
cask "keka"
cask "keyboard-cowboy"                  # Keyboard automation
cask "knockknock"
cask "latest"                           # App update checker
cask "leader-key"                       # Leader key shortcuts
cask "lunar"
cask "mactracker"
cask "mole"                             # SSH tunnel manager
cask "mullvadvpn"
cask "raspberry-pi-imager"
cask "session-manager-plugin"
cask "shottr"
cask "suspicious-package"
cask "taskexplorer"
cask "teamviewer"
cask "the-unarchiver"
cask "utm"

# AI
cask "chatgpt"
cask "lmstudio"
cask "ollama"
cask "anythinglm"                       # Verify exact cask name
cask "enconvo"                          # Verify exact cask name

# 3D Printing
cask "ankermake"
cask "ankerslicer"
cask "blender"
cask "openscad"                         # Verify current cask status
cask "orcaslicer"
cask "shapr3d"

# Networking / Security
cask "wireshark"
cask "lulu"                             # Firewall (install last — popups)
cask "blockblock"                       # Install last — popups

# Fonts
cask "font-jetbrains-mono-nerd-font"

# Orbstack (Docker alternative)
cask "orbstack"

# ============================================
# Mac App Store
# ============================================

# Safari Extensions
mas "1Password for Safari",       id: 1569813296
mas "Auto HD FPS for YouTube",    id: 1546729687
mas "DuckDuckGo Privacy",         id: 1482920575  # Also listed as cask below
mas "PayPal Honey",               id: 1472777122
mas "Raindrop.io",                id: 1549370672
mas "Userscripts",                id: 1463298887

# Apps
mas "Actions",                    id: 1586435171   # New
mas "Audible",                    id: 379693831    # New
mas "AudioBookBinder",            id: 413969927
mas "Data Jar",                   id: 1453273600   # New
mas "Disk Speed Test",            id: 425264550
mas "DuckDuckGo",                 id: 663592361    # New (browser)
mas "Exporter",                   id: 1099120373   # New
mas "Just Focus",                 id: 1142151959
mas "Microsoft Remote Desktop",   id: 1295203466
mas "Perplexity",                 id: 6714467650   # New - verify ID
mas "Presentify",                 id: 1507246666   # New
mas "Tailscale",                  id: 1475387142
mas "Twitter",                    id: 1482454543
mas "WireGuard",                  id: 1451685025
mas "Xcode",                      id: 497799835
```

**Removed from current config (per requirements):**
- `licecap` — removed
- `stats` — removed (replaced by jordanbaird-ice)
- `vanilla` — removed (replaced by jordanbaird-ice)
- `neofetch` — removed (replaced by fastfetch)
- `shuttle` — removed
- `altair-graphql-client` — removed
- `keybase` — removed
- `rocket-chat` — removed
- `1kc-razer` — removed
- `virtualbox` / `virtualbox-beta` — removed
- `icanhazshortcut` — removed
- `arc` — removed
- `tmux` — removed (replaced by zellij)
- `mackup` — removed (replaced by chezmoi)
- `ansible` — not needed
- `watch` — evaluate if still needed
- MAS `Amphetamine` (937984704) — removed
- MAS `Moom` (419330170) — removed (Moom Classic)
- MAS `Omnivore` (1564031042) — service shut down, remove

#### 2.2 Create profile-specific Brewfiles

**`profiles/Brewfile.work`**
```ruby
# Work-specific packages
cask "microsoft-teams"
# Add work-specific tools here
```

**`profiles/Brewfile.personal`**
```ruby
# Personal-specific packages
cask "handbrake"
cask "blender"
# 3D printing tools, media tools, etc.
```

**`profiles/Brewfile.homelab`**
```ruby
# Homelab-specific packages
brew "fluxcd/tap/flux"
brew "go-task/tap/go-task"
brew "direnv"
brew "ipcalc"
brew "jq"
brew "pre-commit"
brew "sops"
brew "kustomize"
brew "stern"
brew "yamllint"
```

**`profiles/Brewfile.minimal`**
```ruby
# Minimal: only essentials
# (base Brewfile will be filtered, not additive)
# This profile uses a stripped-down base
```

#### 2.3 Research: Verify cask names

Before finalizing, verify these cask tokens exist:
- [ ] `anythinglm` or `anythingllm` — run `brew info anythingllm`
- [ ] `enconvo` — run `brew search enconvo`
- [ ] `orcaslicer` — run `brew info orcaslicer`
- [ ] `shapr3d` — run `brew info shapr3d`
- [ ] `openscad` — verify current status
- [ ] `keyboard-cowboy` — verify exact token
- [ ] `leader-key` — verify exact token
- [ ] `mole` — verify exact token
- [ ] `notion-calendar` — verify exact token
- [ ] `notion-mail` — verify exact token
- [ ] `pronotes` — verify exact token
- [ ] `jordanbaird-ice` — verify exact token
- [ ] MAS ID for `Perplexity` — look up actual ID
- [ ] MAS ID for `Actions` — look up actual ID
- [ ] MAS ID for `Audible` — look up actual ID
- [ ] MAS ID for `Data Jar` — look up actual ID
- [ ] MAS ID for `DuckDuckGo` — look up actual ID
- [ ] MAS ID for `Exporter` — look up actual ID
- [ ] MAS ID for `Presentify` — look up actual ID

#### 2.4 Handle "Brewfile for minimal profile" strategy

For the `minimal` profile, instead of a separate Brewfile, use a tag/category approach:
- The bootstrap script will have a list of "essential" packages
- For minimal profile, only install those, skipping the full `brew bundle`
- Or: create `Brewfile.minimal` with just the essentials

**Decision needed in Phase 0 research.**

### Validation
- [ ] `brew bundle check --file=Brewfile` reports no errors in syntax
- [ ] `brew bundle --file=Brewfile --no-lock` on test machine installs all packages
- [ ] All cask tokens verified as valid
- [ ] All MAS IDs verified as correct
- [ ] Profile-specific Brewfiles work as overlays
- [ ] Removed apps confirmed not present in any Brewfile

---

## Phase 3: macOS Defaults & System Configuration

**Goal:** Translate all Ansible `osx_defaults` tasks to `defaults write` shell commands. Add new defaults from requirements.

**Dependencies:** Phase 2 (some defaults depend on apps being installed)
**Produces:** `modules/03-macos-defaults.sh` that configures all system preferences.

### Tasks

#### 3.1 Translate existing Ansible defaults

Map each `osx_defaults` task from `tasks/osx_defaults.yml` to a `defaults write` command:

```bash
#!/usr/bin/env bash
# modules/03-macos-defaults.sh - macOS system preferences

log_info "Configuring macOS defaults..."

# ============================================
# Dock
# ============================================
log_info "Configuring Dock..."
defaults write com.apple.dock tilesize -float 60
defaults write com.apple.dock largesize -float 80
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool true

# ============================================
# Trackpad
# ============================================
log_info "Configuring Trackpad..."
# CHANGED: Keep natural scrolling ON (was set to OFF)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ============================================
# Contacts
# ============================================
defaults write NSGlobalDomain NSPersonNameDefaultShouldPreferNicknamesPreference -int 0

# ============================================
# Safari
# ============================================
log_info "Configuring Safari..."
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# ============================================
# Finder
# ============================================
log_info "Configuring Finder..."
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Don't write .DS_Store on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# ============================================
# Audio
# ============================================
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 1

# ============================================
# NEW: Mouse cursor
# ============================================
# TODO: Research exact defaults for lighter cursor color
# defaults write ... CGDisableCursorLocationMagnification ...

# ============================================
# NEW: Desktop Wallpaper
# ============================================
# TODO: Research wallpaper folder sources + fit-to-screen
# May require osascript or desktoppicture.db manipulation

# ============================================
# NEW: Screenshot shortcuts
# ============================================
# Disable default screenshot shortcut (Cmd+Shift+3)
# TODO: Research symbolic hotkeys plist manipulation
# defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 ...

# ============================================
# NEW: Keyboard
# ============================================
# Enable keyboard navigation (Tab/Shift+Tab)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ============================================
# Restart affected services
# ============================================
log_info "Restarting affected services..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall Safari 2>/dev/null || true

log_success "macOS defaults configured"
```

#### 3.2 Research and implement new defaults

These require investigation (tracked in Phase 0 research):

| Default | Status | Notes |
|---------|--------|-------|
| Natural scrolling ON | Ready | `com.apple.swipescrolldirection true` |
| Mouse cursor lighter color | Research | May need accessibility settings |
| Desktop wallpaper folders | Research | `desktoppicture.db` or `osascript` |
| Wallpaper fit-to-screen | Research | Part of wallpaper config |
| Disable screenshot Cmd+Shift+3 | Research | Symbolic hotkeys plist |
| Kap shortcut Cmd+Shift+3 | Research | Kap preferences or system shortcuts |
| Catppuccin theme | Research | Per-app; Terminal/Ghostty/etc. |
| Keyboard navigation | Ready | `AppleKeyboardUIMode 3` |

#### 3.3 Profile-aware defaults

Some defaults may vary by profile (e.g., homelab might not need Dock customization). The module should check `$MACHINE_PROFILE` and skip irrelevant sections.

### Validation
- [ ] All existing Ansible defaults have a corresponding `defaults write`
- [ ] Natural scrolling is ON (changed from current OFF)
- [ ] New defaults that are ready are implemented
- [ ] Research-dependent defaults have clear TODO markers
- [ ] `killall` commands restart services to apply changes
- [ ] Script is idempotent (running twice produces same result)

---

## Phase 4: ZSH Configuration (Replace Oh My Zsh)

**Goal:** Create all modular ZSH configuration files and the loader `.zshrc`.

**Dependencies:** Phase 2 (Starship, zsh-autosuggestions, zsh-syntax-highlighting installed)
**Produces:** Complete ZSH setup that replaces Oh My Zsh.

### Tasks

#### 4.1 Create `.zprofile`

```zsh
# ~/.zprofile - Login shell configuration
# Loaded once per login session

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### 4.2 Create `.zshrc`

```zsh
# ~/.zshrc - Interactive shell configuration
# Loads modular configuration from ~/.zshrc.d/

# ============================================
# Load modular configuration files
# ============================================
if [[ -d "${HOME}/.zshrc.d" ]]; then
  for config_file in "${HOME}/.zshrc.d"/*.zsh(N); do
    source "$config_file"
  done
  unset config_file
fi

# ============================================
# Homebrew completions (must be before compinit)
# ============================================
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
autoload -Uz compinit && compinit

# ============================================
# Plugin loading (from Homebrew)
# ============================================
# zsh-autosuggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null

# zsh-syntax-highlighting (must be last)
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2>/dev/null

# ============================================
# Starship prompt (must be at end)
# ============================================
eval "$(starship init zsh)"
```

#### 4.3 Create modular ZSH files

Each file in `~/.zshrc.d/`:

**`01-history.zsh`** — History configuration (kept even with atuin)
```zsh
# History configuration
# Note: atuin handles search/sync, but ZSH still needs these for basic history
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # Write timestamps
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Don't store consecutive duplicates
setopt HIST_IGNORE_SPACE      # Don't store commands starting with space
setopt HIST_VERIFY            # Show before executing from history
setopt SHARE_HISTORY          # Share history across sessions
setopt APPEND_HISTORY         # Append rather than overwrite

# Atuin (replaces Ctrl+R)
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
fi
```

**`02-aliases.zsh`** — Generic aliases
```zsh
# Generic aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias l='eza --icons'
alias lt='eza --tree --icons --level=2'
alias reload='exec zsh'
alias cls='clear'
alias path='echo -e ${PATH//:/\\n}'
alias mkdir='mkdir -pv'
alias h='history'
alias j='jobs -l'
alias ports='lsof -i -n -P'
```

**`03-git.zsh`** — Git aliases and helpers
```zsh
# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gpl='git pull'
alias gf='git fetch --all --prune'
alias gb='git branch'
alias gbd='git branch -d'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grs='git reset'
alias grsh='git reset --hard'

# Git helpers
gclean() {
  git branch --merged | grep -v '\*\|main\|master' | xargs -n 1 git branch -d
}
```

**`04-brew.zsh`** — Homebrew aliases
```zsh
# Homebrew aliases
alias bi='brew install'
alias bic='brew install --cask'
alias bu='brew update && brew upgrade'
alias bs='brew search'
alias bl='brew list'
alias binfo='brew info'
alias bclean='brew cleanup --prune=all'
alias bdoctor='brew doctor'
alias bout='brew outdated'
alias bdump='brew bundle dump --file=~/Brewfile --force'
```

**`05-macos.zsh`** — macOS-specific helpers
```zsh
# macOS aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias emptytrash='rm -rf ~/.Trash/*'
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
alias lock='pmset displaysleepnow'

# Finder: open current dir
alias f='open -a Finder .'

# Defaults helper (for discovering new defaults)
alias da='defaults read > /tmp/defaults_a.txt'
alias db='defaults read > /tmp/defaults_b.txt'
alias ddif='diff /tmp/defaults_a.txt /tmp/defaults_b.txt'

# Quick Look
alias ql='qlmanage -p'
```

**`06-docker.zsh`** — Docker shortcuts
```zsh
# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dprune='docker system prune -af --volumes'
alias dlogs='docker logs -f'
```

**`07-1password.zsh`** — 1Password CLI helpers
```zsh
# 1Password CLI helpers
if command -v op &>/dev/null; then
  alias opsignin='eval $(op signin)'

  # Get a secret from 1Password
  opget() {
    op item get "$1" --fields "$2" 2>/dev/null
  }

  # SSH agent via 1Password
  export SSH_AUTH_SOCK="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi
```

**`08-extract.zsh`** — Universal archive extractor
```zsh
# Universal archive extractor
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.tar.xz)    tar xJf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *.xz)        xz -d "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
```

**`09-colorize.zsh`** — Color testing
```zsh
# Color test function
colortest() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}m%3d " "$i"
    if (( (i + 1) % 16 == 0 )); then
      printf "\n"
    fi
  done
  printf "\x1b[0m\n"
}

# True color test
truecolortest() {
  awk 'BEGIN{
    s="          "; s=s s s s s s s s;
    for (colession=0; colession<77; colession++) {
      r = 255-(colession*255/76);
      g = (colession*510/76);
      b = (colession*255/76);
      if (g>255) g = 510-g;
      printf "\033[48;2;%d;%d;%dm", r,g,b;
      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
      printf "%s\033[0m", substr(s,1,1);
    }
    printf "\n";
  }'
}
```

**`10-kubectl.zsh`** — Kubernetes aliases + completion
```zsh
# Kubernetes aliases
if command -v kubectl &>/dev/null; then
  alias k='kubectl'
  alias kg='kubectl get'
  alias kgp='kubectl get pods'
  alias kgs='kubectl get svc'
  alias kgn='kubectl get nodes'
  alias kga='kubectl get all'
  alias kd='kubectl describe'
  alias kdp='kubectl describe pod'
  alias kds='kubectl describe svc'
  alias kdn='kubectl describe node'
  alias kl='kubectl logs'
  alias klf='kubectl logs -f'
  alias kex='kubectl exec -it'
  alias kaf='kubectl apply -f'
  alias kdf='kubectl delete -f'
  alias kns='kubectl config set-context --current --namespace'
  alias kcx='kubectl config use-context'

  # Load kubectl completion
  source <(kubectl completion zsh)
  # Make aliases work with completion
  compdef k=kubectl
fi
```

**`11-kube-ps1.zsh`** — K8s context in prompt
```zsh
# kube-ps1 (from Homebrew on Apple Silicon)
KUBE_PS1_FILE="$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh"
if [[ -f "$KUBE_PS1_FILE" ]]; then
  source "$KUBE_PS1_FILE"
  # Don't auto-enable — controlled by starship or toggle
  kubeoff 2>/dev/null
fi
```

**`12-kubectx.zsh`** — kubectx/kubens aliases
```zsh
# kubectx / kubens
if command -v kubectx &>/dev/null; then
  alias kctx='kubectx'
  alias kns='kubens'
fi
```

**`13-sudo.zsh`** — Esc-Esc sudo widget
```zsh
# Esc-Esc to prepend sudo
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey '\e\e' sudo-command-line
```

**`14-fzf.zsh`** — fzf key bindings
```zsh
# fzf configuration
if command -v fzf &>/dev/null; then
  # Use fd if available, otherwise find
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'

  # Load fzf key bindings and completion
  source <(fzf --zsh) 2>/dev/null
fi
```

**`15-zoxide.zsh`** — Zoxide smart cd
```zsh
# Zoxide (smart cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
```

#### 4.4 Create `modules/05-zsh.sh` (bootstrap module)

```bash
#!/usr/bin/env bash
# modules/05-zsh.sh - ZSH configuration setup

# Remove Oh My Zsh if present
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_warn "Oh My Zsh detected. It will be preserved but unused."
  log_info "To remove: rm -rf ~/.oh-my-zsh"
fi

# Create .zshrc.d directory
mkdir -p "${HOME}/.zshrc.d"

# Note: Actual ZSH files are deployed by chezmoi (Phase 5/6)
# This module ensures the directory structure exists and
# sets zsh as the default shell if it isn't already.

# Ensure zsh is the default shell
if [[ "$SHELL" != */zsh ]]; then
  log_info "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  log_success "Default shell set to zsh"
else
  log_success "zsh is already the default shell"
fi

log_success "ZSH configuration prepared"
```

#### 4.5 Create Starship configuration

**`starship.toml`** (managed by chezmoi)

```toml
# Starship prompt configuration
# https://starship.rs/config/

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$kubernetes\
$aws\
$azure\
$terraform\
$docker_context\
$python\
$nodejs\
$golang\
$rust\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[directory]
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
format = '([$all_status$ahead_behind]($style) )'

[kubernetes]
disabled = false
format = '[$symbol$context( \($namespace\))]($style) '
symbol = "☸ "
# Toggle this based on profile
detect_env_vars = ["KUBECONFIG"]

[aws]
disabled = true
format = '[$symbol($profile )(\($region\) )]($style)'

[azure]
disabled = true
format = '[$symbol($subscription)]($style) '

[cmd_duration]
min_time = 2000
format = "[$duration]($style) "

[docker_context]
disabled = true
```

### Validation
- [ ] Source `.zshrc` in a new terminal — no errors
- [ ] All 15 module files load without errors
- [ ] Tab completion works (kubectl, git, brew)
- [ ] Starship prompt renders correctly
- [ ] `Esc-Esc` toggles sudo prefix
- [ ] `extract` function works on a .tar.gz
- [ ] `atuin` search works with Ctrl+R
- [ ] `zoxide` intercepts `cd` command
- [ ] `eza` aliases display files with icons
- [ ] `fzf` Ctrl+T file finder works
- [ ] Oh My Zsh removal is non-destructive (warns but doesn't delete)

---

## Phase 5: Chezmoi & Dotfiles Management

**Goal:** Set up chezmoi for non-sensitive dotfile management. Create the dotfiles repo structure.

**Dependencies:** Phase 2 (chezmoi installed), Phase 4 (ZSH files exist to manage)
**Produces:** `chezmoi apply` deploys all non-sensitive dotfiles.

### Tasks

#### 5.1 Create dotfiles repo on GitHub

```bash
# Create the repo
gh repo create dotfiles --private --description "Dotfiles managed by chezmoi"
```

#### 5.2 Initialize chezmoi source directory

```bash
chezmoi init --apply https://github.com/shawnmix/dotfiles.git
```

#### 5.3 Create `.chezmoi.toml.tmpl`

```toml
# chezmoi configuration
# This template is processed during `chezmoi init`

{{- $profile := promptStringOnce . "profile" "Machine profile (work/personal/homelab/minimal)" -}}
{{- $email := promptStringOnce . "email" "Git email address" -}}
{{- $name := promptStringOnce . "name" "Git full name" -}}

[data]
  profile = {{ $profile | quote }}
  email = {{ $email | quote }}
  name = {{ $name | quote }}

[onepassword]
  command = "op"

[edit]
  command = "code"
  args = ["--wait"]
```

#### 5.4 Create `.chezmoiignore`

```
# Ignore patterns based on profile and OS
{{- if ne .chezmoi.os "darwin" }}
dot_zshrc.d/
dot_config/ghostty/
{{- end }}

# Profile-based ignores
{{- if eq .profile "minimal" }}
dot_zshrc.d/10-kubectl.zsh
dot_zshrc.d/11-kube-ps1.zsh
dot_zshrc.d/12-kubectx.zsh
dot_config/k9s/
{{- end }}

README.md
LICENSE
```

#### 5.5 Add all non-sensitive dotfiles to chezmoi

```bash
# ZSH configuration
chezmoi add ~/.zshrc
chezmoi add ~/.zprofile
chezmoi add ~/.zshrc.d/

# Git
chezmoi add ~/.gitconfig

# Starship
chezmoi add ~/.config/starship.toml

# Application configs
chezmoi add ~/.config/atuin/
chezmoi add ~/.config/ghostty/
chezmoi add ~/.config/zellij/
chezmoi add ~/.config/nvim/
chezmoi add ~/.config/gh/
chezmoi add ~/.config/zoxide/

# Others from requirements
chezmoi add ~/.config/chezmoi/
chezmoi add ~/.config/claude/
chezmoi add ~/.config/fabric/
chezmoi add ~/.config/keyboardcowboy/
chezmoi add ~/.config/leaderkey/
chezmoi add ~/.config/opencode/
chezmoi add ~/.config/pai/
chezmoi add ~/.config/raycast/
```

#### 5.6 Create `modules/06-chezmoi.sh`

```bash
#!/usr/bin/env bash
# modules/06-chezmoi.sh - Initialize chezmoi and deploy non-sensitive dotfiles

if ! command_exists chezmoi; then
  log_error "chezmoi is not installed (should have been installed by Homebrew)"
  return 1
fi

DOTFILES_REPO="https://github.com/shawnmix/dotfiles.git"

if [[ ! -d "${HOME}/.local/share/chezmoi" ]]; then
  log_info "Initializing chezmoi..."
  chezmoi init "$DOTFILES_REPO"
else
  log_info "chezmoi already initialized, updating..."
  chezmoi update --apply=false
fi

# Apply non-secret dotfiles
# Secrets will be applied in Phase 2 after 1Password auth
log_info "Applying dotfiles (non-sensitive)..."
chezmoi apply --exclude=encrypted

log_success "Dotfiles deployed via chezmoi"
```

#### 5.7 Create `modules/07-symlinks.sh`

```bash
#!/usr/bin/env bash
# modules/07-symlinks.sh - Create required symlinks

log_info "Creating symlinks..."

# ln -s ~/1Projects -> ~/projects (if source exists)
# Note: iCloud path has spaces - handle carefully
ICLOUD_PROJECTS="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Documents/1 Projects"
if [[ -d "$ICLOUD_PROJECTS" ]] && [[ ! -L "${HOME}/projects" ]]; then
  ln -s "$ICLOUD_PROJECTS" "${HOME}/projects"
  log_success "Created ~/projects symlink"
fi

# ln -s .claude -> .config/claude
if [[ -d "${HOME}/.config/claude" ]] && [[ ! -L "${HOME}/.claude" ]]; then
  ln -s "${HOME}/.config/claude" "${HOME}/.claude"
  log_success "Created ~/.claude symlink"
fi

log_success "Symlinks created"
```

### Validation
- [ ] `chezmoi init` works from scratch on a clean machine
- [ ] `chezmoi apply` deploys all non-sensitive files correctly
- [ ] `.chezmoiignore` correctly excludes files based on profile
- [ ] `chezmoi diff` shows no unexpected changes after apply
- [ ] Symlinks are created correctly and are not duplicated on re-run
- [ ] Running `chezmoi apply` twice is idempotent
- [ ] Chezmoi doesn't try to deploy secrets without 1Password auth

---

## Phase 6: 1Password Integration & Secrets

**Goal:** Configure chezmoi to deploy sensitive files (SSH keys, configs) via 1Password.

**Dependencies:** Phase 5 (chezmoi working), 1Password installed and signed in
**Produces:** SSH keys and sensitive configs deployed from 1Password.

### Tasks

#### 6.1 Design 1Password vault structure

```
Vault: "Development" (or "SSH Keys")
├── SSH Key - Personal (id_ed25519)
│   ├── private key (field)
│   └── public key (field)
├── SSH Key - Work (id_work)
│   ├── private key (field)
│   └── public key (field)
├── SSH Config
│   └── config content (secure note)
└── Git Signing Key
    └── key (field)
```

**Important exception:** `id_gitea` stays raw on disk (not in 1Password) for Obsidian sync.

#### 6.2 Create chezmoi templates for SSH

**`private_dot_ssh/config.tmpl`**
```
# SSH Configuration
# Managed by chezmoi + 1Password

Host *
  AddKeysToAgent yes
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Personal GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519

# Gitea (raw key for Obsidian sync)
Host git.thegeekybits.com
  HostName git.thegeekybits.com
  User git
  IdentityFile ~/.ssh/id_gitea

{{ if eq .profile "work" -}}
# Work-specific hosts
Host *.internal.work.com
  User {{ .name }}
  IdentityFile ~/.ssh/id_work
{{ end -}}

# Template for adding new hosts:
# Host <alias>
#   HostName <ip-or-hostname>
#   User <username>
#   Port <port>
#   IdentityFile ~/.ssh/<key>
```

**`private_dot_ssh/id_ed25519.tmpl`** (1Password-templated)
```
{{- onepasswordRead "op://Development/SSH Key - Personal/private key" -}}
```

**`private_dot_ssh/id_ed25519.pub.tmpl`**
```
{{- onepasswordRead "op://Development/SSH Key - Personal/public key" -}}
```

#### 6.3 Create `modules/09-1password-secrets.sh`

```bash
#!/usr/bin/env bash
# modules/09-1password-secrets.sh - Deploy secrets via chezmoi + 1Password

# Verify 1Password CLI is authenticated
if ! check_op_auth; then
  log_error "1Password CLI is not authenticated."
  log_info "Please run: eval \$(op signin)"
  log_info "Then re-run: ./bootstrap.sh --phase2"
  return 1
fi

log_info "Deploying secrets via chezmoi + 1Password..."

# Apply all dotfiles including secrets
chezmoi apply

# Set correct permissions on SSH files
chmod 700 "${HOME}/.ssh"
chmod 600 "${HOME}/.ssh/id_"* 2>/dev/null || true
chmod 644 "${HOME}/.ssh/id_"*.pub 2>/dev/null || true
chmod 644 "${HOME}/.ssh/config"

# Handle id_gitea separately (raw key, not from 1Password)
if [[ ! -f "${HOME}/.ssh/id_gitea" ]]; then
  log_warn "~/.ssh/id_gitea not found. This key must be manually placed for Obsidian sync."
fi

# Configure git with 1Password signing
log_info "Configuring git commit signing..."
git config --global user.signingkey "$(op read 'op://Development/Git Signing Key/public key')" 2>/dev/null || \
  log_warn "Could not configure git signing key from 1Password"

log_success "Secrets deployed"
```

#### 6.4 Create helper for adding new SSH hosts

```bash
# Function to add to 07-1password.zsh
ssh-add-host() {
  local alias host user port
  read -rp "SSH alias: " alias
  read -rp "Hostname/IP: " host
  read -rp "User [$(whoami)]: " user
  user="${user:-$(whoami)}"
  read -rp "Port [22]: " port
  port="${port:-22}"

  cat >> "${HOME}/.ssh/config" <<EOF

Host ${alias}
  HostName ${host}
  User ${user}
  Port ${port}
EOF

  echo "Added SSH host: ${alias}"
  echo "Note: Run 'chezmoi re-add ~/.ssh/config' to update chezmoi source."
}
```

### Validation
- [ ] `chezmoi apply` with 1Password authenticated deploys SSH keys
- [ ] SSH key permissions are correct (600 for private, 644 for public)
- [ ] `ssh -T git@github.com` succeeds
- [ ] `id_gitea` is NOT managed by chezmoi (stays raw)
- [ ] Git commit signing works
- [ ] `chezmoi apply` without 1Password auth skips secrets gracefully
- [ ] `ssh-add-host` helper creates valid config entries

---

## Phase 7: Dock Configuration

**Goal:** Replace Ansible dock tasks with shell script using `dockutil`.

**Dependencies:** Phase 2 (dockutil installed via Brewfile)
**Produces:** Dock is configured with correct apps in correct positions.

### Tasks

#### 7.1 Create `modules/04-dock.sh`

```bash
#!/usr/bin/env bash
# modules/04-dock.sh - Configure Dock via dockutil

if ! command_exists dockutil; then
  log_error "dockutil not installed"
  return 1
fi

log_info "Configuring Dock..."

# ============================================
# Remove unwanted items
# ============================================
DOCK_REMOVE=(
  "Launchpad"
  "Maps"
  "FaceTime"
  "Contacts"
  "Notes"
  "Freeform"
  "TV"
  "News"
  "Numbers"
  "Keynote"
  "Pages"
  "App Store"
  "System Settings"
  "TickTick"
  "Obsidian"
  "iPhone Mirroring"
  "Arc"
  "TeamViewer"
)

for item in "${DOCK_REMOVE[@]}"; do
  if dockutil --find "$item" &>/dev/null; then
    dockutil --remove "$item" --no-restart
    log_info "Removed: $item"
  fi
done

# ============================================
# Add items in order
# ============================================
# Format: name|path|position|section
DOCK_ADD=(
  "Music|/System/Applications/Music.app|1|apps"
  "Podcasts|/System/Applications/Podcasts.app|2|apps"
  "Books|/System/Applications/Books.app|3|apps"
  "Photos|/System/Applications/Photos.app|4|apps"
  "Shortcuts|/System/Applications/Shortcuts.app|5|apps"
  "Safari|/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app|6|apps"
  "Google Chrome|/Applications/Google Chrome.app|7|apps"
  "Mail|/System/Applications/Mail.app|8|apps"
  "Calendar|/System/Applications/Calendar.app|9|apps"
  "zoom.us|/Applications/zoom.us.app|10|apps"
  "Slack|/Applications/Slack.app|11|apps"
  "Discord|/Applications/Discord.app|12|apps"
  "Messages|/System/Applications/Messages.app|13|apps"
  "Visual Studio Code|/Applications/Visual Studio Code.app|14|apps"
  "Ghostty|/Applications/Ghostty.app|15|apps"
  "Terminal|/System/Applications/Utilities/Terminal.app|16|apps"
)

# Others section
DOCK_OTHERS=(
  "Applications|/Applications|folder|grid|1"
  "Downloads|${HOME}/Downloads|folder|list|2"
)

for entry in "${DOCK_ADD[@]}"; do
  IFS='|' read -r name path pos section <<< "$entry"
  if [[ -e "$path" ]]; then
    if ! dockutil --find "$name" &>/dev/null; then
      dockutil --add "$path" --label "$name" --position "$pos" --section "$section" --no-restart
      log_info "Added: $name at position $pos"
    else
      # Move to correct position
      dockutil --move "$name" --position "$pos" --no-restart
    fi
  else
    log_warn "App not found, skipping: $name ($path)"
  fi
done

for entry in "${DOCK_OTHERS[@]}"; do
  IFS='|' read -r name path display view pos <<< "$entry"
  if [[ -e "$path" ]]; then
    if ! dockutil --find "$name" &>/dev/null; then
      dockutil --add "$path" --label "$name" --display "$display" --view "$view" \
        --section others --position "$pos" --no-restart
      log_info "Added (others): $name"
    fi
  fi
done

# Restart Dock once at the end
killall Dock

log_success "Dock configured"
```

#### 7.2 Key changes from current dock config
- Removed: TickTick, Obsidian, iPhone Mirroring, Arc, TeamViewer
- Added: Ghostty (position 15)
- Removed Arc from position 8, Mail moves up
- Using `--no-restart` for batch changes, single `killall Dock` at end (much faster than 7-second pauses)

### Validation
- [ ] All unwanted items removed from dock
- [ ] All desired items present in correct order
- [ ] "Others" section has Applications and Downloads folders
- [ ] Script handles missing apps gracefully (warns, doesn't fail)
- [ ] Running twice is idempotent (no duplicate entries)
- [ ] Single dock restart at end (not per-item)

---

## Phase 8: Interactive Menu & Machine Profiles

**Goal:** Build the interactive menu system that collects all user decisions upfront.

**Dependencies:** All modules (Phases 1-7) working individually
**Produces:** Full interactive bootstrap experience.

### Tasks

#### 8.1 Create `lib/menu.sh`

```bash
#!/usr/bin/env bash
# lib/menu.sh - Interactive menu system

# Display the welcome banner
show_banner() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║          macOS Bootstrap Tool v2.0           ║"
  echo "║                                              ║"
  echo "║  Automated macOS setup & configuration       ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

# Prompt for machine profile
select_profile() {
  echo "Select machine profile:"
  echo ""
  echo "  1) personal  - Full personal setup (default)"
  echo "  2) work      - Work-focused tools + personal base"
  echo "  3) homelab   - Kubernetes/infrastructure focus"
  echo "  4) minimal   - Bare essentials only"
  echo ""
  read -rp "Profile [1]: " choice
  case "${choice:-1}" in
    1|personal)  MACHINE_PROFILE="personal" ;;
    2|work)      MACHINE_PROFILE="work" ;;
    3|homelab)   MACHINE_PROFILE="homelab" ;;
    4|minimal)   MACHINE_PROFILE="minimal" ;;
    *)           MACHINE_PROFILE="personal" ;;
  esac
  echo "  Selected: ${MACHINE_PROFILE}"
  echo ""
}

# Prompt for hostname
prompt_hostname() {
  read -rp "Hostname (leave blank to skip): " NEW_HOSTNAME
  if [[ -n "$NEW_HOSTNAME" ]]; then
    echo "  Hostname will be set to: ${NEW_HOSTNAME}"
  else
    echo "  Skipping hostname configuration"
  fi
  echo ""
}

# Module toggle menu
select_modules() {
  echo "Module configuration (all enabled by default):"
  echo ""

  # Default all on
  MOD_HOMEBREW=true
  MOD_MACOS_DEFAULTS=true
  MOD_DOCK=true
  MOD_ZSH=true
  MOD_CHEZMOI=true
  MOD_SYMLINKS=true
  MOD_AUTOUPDATE=true

  echo "  [H] Homebrew + packages    : ${MOD_HOMEBREW}"
  echo "  [M] macOS defaults         : ${MOD_MACOS_DEFAULTS}"
  echo "  [D] Dock configuration     : ${MOD_DOCK}"
  echo "  [Z] ZSH setup              : ${MOD_ZSH}"
  echo "  [C] Chezmoi dotfiles       : ${MOD_CHEZMOI}"
  echo "  [S] Symlinks               : ${MOD_SYMLINKS}"
  echo "  [A] Homebrew autoupdate    : ${MOD_AUTOUPDATE}"
  echo ""
  echo "  Press Enter to accept defaults, or type letters to toggle (e.g., 'MD' disables macOS defaults and Dock):"
  read -rp "  Toggle: " toggles

  for (( i=0; i<${#toggles}; i++ )); do
    case "${toggles:$i:1}" in
      [Hh]) MOD_HOMEBREW=false ;;
      [Mm]) MOD_MACOS_DEFAULTS=false ;;
      [Dd]) MOD_DOCK=false ;;
      [Zz]) MOD_ZSH=false ;;
      [Cc]) MOD_CHEZMOI=false ;;
      [Ss]) MOD_SYMLINKS=false ;;
      [Aa]) MOD_AUTOUPDATE=false ;;
    esac
  done

  echo ""
  echo "  Final module selection:"
  echo "    Homebrew:        ${MOD_HOMEBREW}"
  echo "    macOS defaults:  ${MOD_MACOS_DEFAULTS}"
  echo "    Dock:            ${MOD_DOCK}"
  echo "    ZSH:             ${MOD_ZSH}"
  echo "    Chezmoi:         ${MOD_CHEZMOI}"
  echo "    Symlinks:        ${MOD_SYMLINKS}"
  echo "    Autoupdate:      ${MOD_AUTOUPDATE}"
  echo ""
}

# Confirmation before proceeding
confirm_proceed() {
  echo "═══════════════════════════════════════"
  echo "  Profile:    ${MACHINE_PROFILE}"
  echo "  Hostname:   ${NEW_HOSTNAME:-<skip>}"
  echo "  Modules:    $(enabled_modules_list)"
  echo "═══════════════════════════════════════"
  echo ""
  read -rp "Proceed? [Y/n]: " confirm
  if [[ "${confirm,,}" == "n" ]]; then
    echo "Aborted."
    exit 0
  fi
}

# Helper to list enabled modules
enabled_modules_list() {
  local modules=()
  $MOD_HOMEBREW && modules+=("homebrew")
  $MOD_MACOS_DEFAULTS && modules+=("macos-defaults")
  $MOD_DOCK && modules+=("dock")
  $MOD_ZSH && modules+=("zsh")
  $MOD_CHEZMOI && modules+=("chezmoi")
  $MOD_SYMLINKS && modules+=("symlinks")
  $MOD_AUTOUPDATE && modules+=("autoupdate")
  echo "${modules[*]}"
}
```

#### 8.2 Update `bootstrap.sh` to use menu

Replace the hardcoded variables with the interactive menu:

```bash
# Interactive setup (unless --unattended flag)
if [[ "${1:-}" != "--unattended" ]] && [[ "${1:-}" != "--phase2" ]]; then
  source "$SCRIPT_DIR/lib/menu.sh"
  show_banner
  select_profile
  prompt_hostname
  select_modules
  confirm_proceed
fi

# Run enabled modules
$MOD_HOMEBREW       && run_module "01-homebrew.sh"
[[ -n "$NEW_HOSTNAME" ]] && run_module "02-hostname.sh"
$MOD_MACOS_DEFAULTS && run_module "03-macos-defaults.sh"
$MOD_DOCK           && run_module "04-dock.sh"
$MOD_ZSH            && run_module "05-zsh.sh"
$MOD_CHEZMOI        && run_module "06-chezmoi.sh"
$MOD_SYMLINKS       && run_module "07-symlinks.sh"
$MOD_AUTOUPDATE     && run_module "08-homebrew-autoupdate.sh"
```

#### 8.3 Create profile configuration files

**`profiles/work.sh`**
```bash
#!/usr/bin/env bash
# profiles/work.sh - Work profile overrides

# Additional macOS defaults for work
work_macos_defaults() {
  # Example: different dock size, specific network settings
  :
}

# Work-specific post-install
work_post_install() {
  log_info "Work profile: Remember to configure VPN and corporate tools"
}
```

**`profiles/personal.sh`** (default, no overrides needed)
**`profiles/homelab.sh`** (k8s-focused additions)
**`profiles/minimal.sh`** (strips down to essentials)

#### 8.4 Add `--phase2` and `--unattended` flags

```bash
# CLI argument handling
case "${1:-}" in
  --phase2)
    source "$SCRIPT_DIR/lib/utils.sh"
    source "$SCRIPT_DIR/lib/checks.sh"
    run_module "09-1password-secrets.sh"
    run_module "10-post-install.sh"
    exit 0
    ;;
  --unattended)
    # Use environment variables or defaults
    MACHINE_PROFILE="${MACHINE_PROFILE:-personal}"
    NEW_HOSTNAME="${NEW_HOSTNAME:-}"
    MOD_HOMEBREW=true MOD_MACOS_DEFAULTS=true MOD_DOCK=true
    MOD_ZSH=true MOD_CHEZMOI=true MOD_SYMLINKS=true MOD_AUTOUPDATE=true
    ;;
esac
```

### Validation
- [ ] Interactive menu displays correctly
- [ ] Profile selection works for all 4 options
- [ ] Hostname prompt allows blank (skip) entry
- [ ] Module toggles correctly enable/disable modules
- [ ] Confirmation screen shows correct summary
- [ ] `--unattended` flag bypasses menu
- [ ] `--phase2` flag runs only secrets phase
- [ ] Profile-specific Brewfiles are included
- [ ] Disabled modules are actually skipped

---

## Phase 9: Modern CLI Tools Integration

**Goal:** Ensure all modern CLI tools are properly configured and integrated with ZSH.

**Dependencies:** Phase 4 (ZSH modules), Phase 2 (tools installed)
**Produces:** All modern tools working with proper shell integration.

### Tasks

#### 9.1 Atuin configuration

**`~/.config/atuin/config.toml`** (managed by chezmoi)
```toml
# Atuin configuration
# https://docs.atuin.sh/configuration/config/

[settings]
dialect = "us"
auto_sync = true
update_check = true
sync_frequency = "5m"
search_mode = "fuzzy"
filter_mode = "global"
style = "compact"
show_preview = true
```

#### 9.2 Zellij configuration

**`~/.config/zellij/config.kdl`** (managed by chezmoi)
```kdl
// Zellij configuration
// Replaces tmux

keybinds {
    // Add custom keybindings here
}

theme "catppuccin-mocha"
default_layout "compact"
```

#### 9.3 Ghostty configuration

**`~/.config/ghostty/config`** (managed by chezmoi)
```
# Ghostty terminal configuration
theme = catppuccin-mocha
font-family = JetBrainsMono Nerd Font
font-size = 14
window-padding-x = 8
window-padding-y = 8
```

#### 9.4 Create `modules/08-homebrew-autoupdate.sh`

```bash
#!/usr/bin/env bash
# modules/08-homebrew-autoupdate.sh - Configure Homebrew autoupdate

log_info "Configuring Homebrew autoupdate..."

# Install homebrew-autoupdate tap if not already
if ! brew tap | grep -q "homebrew/autoupdate"; then
  brew tap homebrew/autoupdate
fi

# Start autoupdate (every 24 hours, with notifications)
brew autoupdate start 86400 --upgrade --cleanup --enable-notification

log_success "Homebrew autoupdate configured (24h interval)"
```

#### 9.5 Create `modules/10-post-install.sh`

```bash
#!/usr/bin/env bash
# modules/10-post-install.sh - Post-install validation and summary

log_step "Running post-install validation..."

# Check key tools
local checks=(
  "brew:Homebrew"
  "chezmoi:Chezmoi"
  "starship:Starship"
  "atuin:Atuin"
  "zoxide:Zoxide"
  "eza:Eza"
  "fzf:FZF"
  "zellij:Zellij"
  "op:1Password CLI"
  "dockutil:Dockutil"
  "fastfetch:Fastfetch"
)

echo ""
echo "Tool Status:"
echo "─────────────────────────"
for check in "${checks[@]}"; do
  IFS=':' read -r cmd name <<< "$check"
  if command_exists "$cmd"; then
    log_success "$name"
  else
    log_warn "$name - not found"
  fi
done

echo ""
echo "─────────────────────────"
echo "Bootstrap Summary"
echo "─────────────────────────"
echo "  Profile:  ${MACHINE_PROFILE}"
echo "  Hostname: $(scutil --get ComputerName 2>/dev/null || echo 'unchanged')"
echo "  Shell:    ${SHELL}"
echo "  Chezmoi:  $(chezmoi status 2>/dev/null | wc -l | tr -d ' ') managed files"
echo ""

# Display fastfetch if available
if command_exists fastfetch; then
  fastfetch
fi

echo ""
log_info "Manual steps remaining:"
echo "  - Open 1Password and verify SSH agent is working"
echo "  - Sign into iCloud and verify sync"
echo "  - Open Raycast and import settings"
echo "  - Configure app-specific settings (Slack, Discord, etc.)"
echo "  - Place id_gitea key for Obsidian sync"
echo ""
log_success "Bootstrap complete! Restart your terminal for all changes to take effect."
```

### Validation
- [ ] Atuin syncs history and Ctrl+R search works
- [ ] Zellij launches with correct theme and layout
- [ ] Ghostty uses correct font and theme
- [ ] Homebrew autoupdate is running (`brew autoupdate status`)
- [ ] Post-install summary is accurate
- [ ] All listed tools pass the status check

---

## Phase 10: Migration, Testing & GitHub Move

**Goal:** Final integration testing, documentation, and migration from Gitea to GitHub.

**Dependencies:** All previous phases
**Produces:** Public GitHub repo, validated bootstrap process.

### Tasks

#### 10.1 Integration testing

**Test matrix:**

| Test | Environment | Expected Result |
|------|------------|-----------------|
| Fresh install (personal) | Clean macOS VM | Full setup, all tools working |
| Fresh install (minimal) | Clean macOS VM | Only essential tools |
| Fresh install (work) | Clean macOS VM | Work tools + base |
| Re-run (idempotent) | Existing setup | No errors, no duplicates |
| Phase 2 only | Post-1Password | Secrets deployed correctly |
| Unattended mode | Any | Runs without prompts |
| Module skip | Any | Disabled modules don't run |

#### 10.2 Create GitHub repository

```bash
# Create public repo on GitHub
gh repo create bootstrap-mac-os --public \
  --description "Automated macOS setup with brew bundle, chezmoi, and modular ZSH" \
  --homepage "https://github.com/shawnmix/bootstrap-mac-os"

# Add GitHub as a new remote
git remote add github https://github.com/shawnmix/bootstrap-mac-os.git

# Push v2 branch
git push github v2

# Push master for historical reference
git push github master
```

#### 10.3 Update bootstrap URL

In `bootstrap.sh`, update the clone URL:
```bash
# Old
git clone https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git
# New
git clone -b v2 https://github.com/shawnmix/bootstrap-mac-os.git
```

#### 10.4 Write README.md

New README covering:
- Quick start (one-liner curl command)
- What it does (architecture diagram)
- Machine profiles explained
- Module list
- Brewfile customization
- Chezmoi + 1Password setup
- ZSH modules list
- How to customize
- Manual steps after bootstrap
- Contributing (if public)

#### 10.5 Update curl one-liner

```bash
# New bootstrap command:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/shawnmix/bootstrap-mac-os/v2/bootstrap.sh)"
```

#### 10.6 Merge strategy

```bash
# After validation, merge v2 into master on GitHub
git checkout master
git merge v2 --no-ff -m "v2: Complete rewrite - shell scripts, chezmoi, brew bundle"
git tag v2.0.0

# Push to GitHub
git push github master --tags

# Optionally set GitHub as default remote
git remote set-url origin https://github.com/shawnmix/bootstrap-mac-os.git
```

#### 10.7 Clean up

- [ ] Remove Ansible files from master after merge (or keep for history)
- [ ] Update Gitea repo description to point to GitHub
- [ ] Archive Gitea repo (read-only)
- [ ] Verify curl one-liner works from a fresh machine

### Validation
- [ ] All test matrix scenarios pass
- [ ] GitHub repo is public and accessible
- [ ] Curl one-liner works from scratch
- [ ] README is complete and accurate
- [ ] v2.0.0 tag exists
- [ ] Old Gitea URL still works (redirects or archived)

---

## Risk Register

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| R1 | Brew cask names change or are unavailable | Medium | Medium | Verify all cask tokens before finalizing Brewfile. Use `brew search` and `brew info`. |
| R2 | MAS apps require auth that's not available during bootstrap | High | High | Ensure user signs into App Store before running. Add pre-check. MAS apps installed after Homebrew packages. |
| R3 | 1Password CLI integration breaks between versions | High | Low | Pin chezmoi template syntax to documented API. Test on each macOS update. |
| R4 | macOS defaults keys change between macOS versions | Medium | Medium | Test on target macOS version. Document which macOS version each default was tested on. |
| R5 | chezmoi and 1Password integration is complex to debug | Medium | Medium | Keep secrets minimal. Provide clear error messages. Support `--phase2` for retry. |
| R6 | Oh My Zsh removal causes user to lose custom config | Low | Low | Don't auto-remove OMZ. Warn and leave in place. User manually removes when ready. |
| R7 | `dockutil` behavior changes (has happened before) | Medium | Low | Pin to known working version in Brewfile if needed. Test dock module independently. |
| R8 | iCloud Drive path differs across macOS versions | Low | Low | Use `~/Library/Mobile Documents/com~apple~CloudDocs` which is stable. Check before symlinking. |
| R9 | Running on Intel Mac fails (Apple Silicon assumed) | Medium | Low | `brew_prefix()` helper handles both. Test core path on both architectures. |
| R10 | Public GitHub repo accidentally exposes secrets | High | Low | Never commit secrets. Use `.gitignore`. Chezmoi templates reference 1Password, not raw values. Audit before making public. |

---

## Research Items Index

Quick reference for all items requiring investigation:

| ID | Item | Phase | Priority | Status |
|----|------|-------|----------|--------|
| R1 | Chezmoi + 1Password integration pattern | 0 | High | Pending |
| R2 | Brewfile strategy (profiles, MAS auth) | 0 | High | Pending |
| R3 | LuLu automation feasibility | 0 | Low | Pending |
| R4 | macOS defaults: cursor color | 0, 3 | Medium | Pending |
| R5 | macOS defaults: wallpaper folders | 0, 3 | Medium | Pending |
| R6 | macOS defaults: screenshot shortcut | 0, 3 | Medium | Pending |
| R7 | Kap shortcut for Cmd+Shift+3 | 0, 3 | Medium | Pending |
| R8 | Catppuccin theme automation | 0, 9 | Low | Pending |
| R9 | Atuin vs history.zsh coexistence | 0, 4 | Medium | Pending |
| R10 | SSH key strategy with 1Password | 0, 6 | High | Pending |
| R11 | Starship prompt layout switching | 0, 4 | Medium | Pending |
| R12 | Verify all Brewfile cask tokens | 2 | High | Pending |
| R13 | Verify all MAS app IDs | 2 | High | Pending |
| R14 | Homebrew autoupdate tap status | 9 | Low | Pending |
| R15 | Minimal profile Brewfile strategy | 2 | Medium | Pending |

---

## Rollback Strategy

Every phase produces incremental, testable results. If any phase fails:

1. **Branch safety:** `master` is never modified until Phase 10 merge. All work is on `v2`.
2. **Module independence:** Each module can be disabled via the menu. A broken module doesn't block others.
3. **Chezmoi safety:** `chezmoi diff` before `chezmoi apply`. Use `--dry-run` first.
4. **macOS defaults:** Can be reversed by running `defaults delete <domain> <key>` for each setting.
5. **Dock:** `dockutil --remove --all` resets to default, then re-run module.
6. **ZSH:** Keep Oh My Zsh on disk. To revert: change `.zshrc` back to OMZ loader.
7. **Full rollback:** Delete `~/.bootstrap`, restore from Time Machine or re-run current Ansible playbook from `master`.

---

## Execution Order Summary

```
Week 1:  Phase 0 (Research) + Phase 1 (Scaffolding)
Week 2:  Phase 2 (Brewfile) + Phase 3 (macOS Defaults)
Week 3:  Phase 4 (ZSH) + Phase 7 (Dock)
Week 4:  Phase 5 (Chezmoi) + Phase 6 (1Password)
Week 5:  Phase 8 (Menu) + Phase 9 (Modern CLI)
Week 6:  Phase 10 (Testing + GitHub Migration)
```

Each "week" is approximate — could be faster or slower depending on research outcomes and testing time. The key is that each phase is independently completable and testable.
