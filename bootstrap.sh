#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh - macOS Bootstrap Tool v2
# =============================================================================
#
# Single entry point for setting up a fresh macOS installation.
# Replaces the previous Ansible-based approach with pure shell scripts.
#
# Usage (local):
#   ./bootstrap.sh [--unattended] [--phase2] [--debug]
#
# Usage (fresh machine via curl):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/1activegeek/bootstrap-mac-os/v2/bootstrap.sh)"
#
# Flags:
#   --unattended   Skip interactive menu; use env vars or built-in defaults
#   --phase2       Run Phase 2 only (secrets deployment after 1Password setup)
#   --debug        Enable verbose debug logging
#
# Environment variables (useful with --unattended):
#   MACHINE_PROFILE   default | "" — profile overlay (default: default)
#   NEW_HOSTNAME      desired ComputerName (default: skip)
#   DOTFILES_REPO     chezmoi dotfiles repo URL
#   MOD_*             true|false to enable/disable individual modules
#
# =============================================================================

set -euo pipefail

# =============================================================================
# Determine SCRIPT_DIR
# When piped via `curl | bash`, BASH_SOURCE[0] is empty — clone repo first.
# =============================================================================
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Running via curl | bash — clone the repo to ~/.bootstrap first
  BOOTSTRAP_REPO="https://github.com/1activegeek/bootstrap-mac-os.git"
  BOOTSTRAP_DIR="${HOME}/.bootstrap"

  echo "[INFO] Cloning bootstrap repo to ${BOOTSTRAP_DIR}..."

  # Ensure git is available (Xcode CLT provides it; trigger install if needed)
  if ! command -v git &>/dev/null; then
    echo "[INFO] Installing Xcode Command Line Tools (required for git)..."
    xcode-select --install
    until command -v git &>/dev/null; do sleep 5; done
  fi

  rm -rf "${BOOTSTRAP_DIR}"
  git clone -b v2 "${BOOTSTRAP_REPO}" "${BOOTSTRAP_DIR}"

  echo "[INFO] Re-executing bootstrap from ${BOOTSTRAP_DIR}..."
  exec "${BOOTSTRAP_DIR}/bootstrap.sh" "$@"
fi

# =============================================================================
# Load shared libraries
# =============================================================================
# shellcheck source=lib/utils.sh
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck source=lib/checks.sh
source "${SCRIPT_DIR}/lib/checks.sh"
# shellcheck source=lib/menu.sh
source "${SCRIPT_DIR}/lib/menu.sh"

# =============================================================================
# Parse CLI flags
# =============================================================================
UNATTENDED=false
PHASE2_ONLY=false
BOOTSTRAP_DEBUG="${BOOTSTRAP_DEBUG:-false}"

for arg in "$@"; do
  case "$arg" in
    --unattended) UNATTENDED=true ;;
    --phase2)     PHASE2_ONLY=true ;;
    --debug)      BOOTSTRAP_DEBUG=true ;;
  esac
done
export BOOTSTRAP_DEBUG

# =============================================================================
# Configuration defaults
# (Overridden by interactive menu or env vars in --unattended mode)
# =============================================================================
MACHINE_PROFILE="${MACHINE_PROFILE:-default}"
NEW_HOSTNAME="${NEW_HOSTNAME:-}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/1activegeek/dotfiles.git}"

# Module toggles — all enabled by default
MOD_HOMEBREW="${MOD_HOMEBREW:-true}"
MOD_MACOS_DEFAULTS="${MOD_MACOS_DEFAULTS:-true}"
MOD_DOCK="${MOD_DOCK:-true}"
MOD_ZSH="${MOD_ZSH:-true}"
MOD_CHEZMOI="${MOD_CHEZMOI:-true}"
MOD_SYMLINKS="${MOD_SYMLINKS:-true}"
MOD_AUTOUPDATE="${MOD_AUTOUPDATE:-true}"

export SCRIPT_DIR MACHINE_PROFILE NEW_HOSTNAME DOTFILES_REPO

# =============================================================================
# --phase2 shortcut: resume secrets deployment after 1Password is configured
# =============================================================================
if [[ "$PHASE2_ONLY" == "true" ]]; then
  log_step "Phase 2: Secrets & Final Configuration"
  run_module "09-1password-secrets.sh"
  run_module "10-post-install.sh"
  log_success "Phase 2 complete!"
  exit 0
fi

# =============================================================================
# Preflight: basic sanity checks
# =============================================================================
require_macos
check_not_root
setup_traps

# =============================================================================
# Interactive menu (skipped with --unattended)
# =============================================================================
if [[ "$UNATTENDED" == "false" ]]; then
  run_menu
  # run_menu populates: MACHINE_PROFILE, NEW_HOSTNAME, MOD_*
  export MACHINE_PROFILE NEW_HOSTNAME
fi

# =============================================================================
# Pre-flight: Required manual steps before installation begins
# =============================================================================
echo ""
echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
echo -e "${BOLD}${YELLOW}  PRE-INSTALL: Complete these steps first      ${NC}"
echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
echo ""
echo "  Before the bootstrap installs anything, ensure the following"
echo "  are done — some cannot be automated:"
echo ""
echo "  [ ] Sign into the Mac App Store"
echo "        Open App Store → sign in with your Apple ID"
echo "        (Required for MAS apps like Xcode, Raycast Companion, etc.)"
echo ""
echo "  [ ] Sign into iCloud (if not already)"
echo "        System Settings → Apple ID"
echo ""
echo "  Press Enter when ready, or 'q' + Enter to quit."
echo ""
read -rp "  Ready to begin? [Enter / q to quit]: " preflight_input
if [[ "${preflight_input,,}" == "q" ]]; then
  log_info "Exiting. Re-run ./bootstrap.sh when ready."
  exit 0
fi
echo ""

# =============================================================================
# Request sudo and keep alive for the duration of Phase 1
# =============================================================================
log_step "Requesting administrator access"
sudo_keepalive

# =============================================================================
# PHASE 1: Core Setup
# All steps run unattended after the menu.
# =============================================================================
log_step "Phase 1: Core Setup  [profile overlay: ${MACHINE_PROFILE:-none}]"
echo ""

preflight_checks

# Homebrew + packages (base Brewfile + profile overlay)
[[ "$MOD_HOMEBREW" == "true" ]]       && run_module "01-homebrew.sh"

# Hostname (skipped if NEW_HOSTNAME is empty)
[[ -n "${NEW_HOSTNAME:-}" ]]          && run_module "02-hostname.sh"

# macOS system defaults
[[ "$MOD_MACOS_DEFAULTS" == "true" ]] && run_module "03-macos-defaults.sh"

# Dock layout via dockutil
[[ "$MOD_DOCK" == "true" ]]           && run_module "04-dock.sh"

# ZSH modular config + Starship setup
[[ "$MOD_ZSH" == "true" ]]            && run_module "05-zsh.sh"

# Chezmoi: initialize and deploy non-sensitive dotfiles
[[ "$MOD_CHEZMOI" == "true" ]]        && run_module "06-chezmoi.sh"

# Symlinks (~/projects, ~/.claude)
[[ "$MOD_SYMLINKS" == "true" ]]       && run_module "07-symlinks.sh"

# Homebrew autoupdate daemon
[[ "$MOD_AUTOUPDATE" == "true" ]]     && run_module "08-homebrew-autoupdate.sh"

# =============================================================================
# PAUSE: 1Password sign-in
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}==============================${NC}"
echo -e "${BOLD}${GREEN}  Phase 1 Complete!           ${NC}"
echo -e "${BOLD}${GREEN}==============================${NC}"
echo ""
echo -e "${BOLD}${YELLOW}ACTION REQUIRED — Sign into 1Password${NC}"
echo ""
echo "  Phase 2 deploys SSH keys and other secrets via chezmoi + 1Password."
echo "  Before continuing, please complete these steps:"
echo ""
echo "  1. Open 1Password and sign in to your account"
echo "  2. Enable CLI integration:"
echo "       1Password > Settings > Developer > Enable CLI Integration"
echo "  3. Authenticate the 1Password CLI:"
echo "       Run in a new terminal: op signin"
echo ""
echo "  When ready, press Enter to run Phase 2 (secrets deployment)."
echo "  Press 'q' + Enter to quit and run Phase 2 later with:"
echo "       ./bootstrap.sh --phase2"
echo ""

read -rp "  Continue with Phase 2? [Enter / q to quit]: " phase2_input

if [[ "${phase2_input,,}" == "q" ]]; then
  echo ""
  log_info "Pausing after Phase 1."
  log_info "Run './bootstrap.sh --phase2' when 1Password is configured."
  sudo_stop
  exit 0
fi

# =============================================================================
# PHASE 2: Secrets & Final Configuration
# =============================================================================
log_step "Phase 2: Secrets & Final Configuration"

run_module "09-1password-secrets.sh"
run_module "10-post-install.sh"

sudo_stop

echo ""
echo -e "${BOLD}${GREEN}======================================${NC}"
echo -e "${BOLD}${GREEN}  Bootstrap complete!                 ${NC}"
echo -e "${BOLD}${GREEN}  Open a new terminal to get started. ${NC}"
echo -e "${BOLD}${GREEN}======================================${NC}"
echo ""
