#!/usr/bin/env bash
# lib/utils.sh - Shared utility functions for bootstrap
#
# Source this file to get logging, color output, and common helpers.
# All modules depend on this library being sourced first.

# ============================================
# Colors
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# ============================================
# Logging
# ============================================
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[ OK ]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERR ]${NC} $*" >&2; }
log_step()    { echo -e "\n${BOLD}${CYAN}==> $*${NC}"; }
log_substep() { echo -e "  ${DIM}-->  $*${NC}"; }
log_debug()   {
  if [[ "${BOOTSTRAP_DEBUG:-false}" == "true" ]]; then
    echo -e "${MAGENTA}[DBG ]${NC} $*"
  fi
}

# ============================================
# Environment Detection
# ============================================

# Check if a command exists on PATH
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Ensure we're running on macOS
require_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script requires macOS. Detected: $(uname)"
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

# Get the current macOS version string
macos_version() { sw_vers -productVersion; }

# Get the current macOS major version number (e.g., 15 for Sequoia)
macos_major_version() { sw_vers -productVersion | cut -d. -f1; }

# ============================================
# Sudo Handling
# ============================================

# Ask for sudo upfront and keep the session alive in background
sudo_keepalive() {
  sudo -v

  # Refresh sudo every 60s so it doesn't expire during long installs
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
}

# Stop the sudo keepalive background process
sudo_stop() {
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    unset SUDO_KEEPALIVE_PID
  fi
}

# ============================================
# Module Runner
# ============================================

# Source a module script by name (relative to modules/)
# Usage: run_module "01-homebrew.sh"
run_module() {
  local module="$1"
  local script="${SCRIPT_DIR}/modules/${module}"

  if [[ -f "$script" ]]; then
    log_step "Module: ${module%.sh}"
    # shellcheck source=/dev/null
    source "$script"
  else
    log_error "Module not found: ${script}"
    return 1
  fi
}

# ============================================
# User Interaction
# ============================================

# Prompt yes/no — returns 0 for yes, 1 for no
# Usage: confirm "Are you sure?" && do_thing
confirm() {
  local prompt="${1:-Continue?}"
  local response
  read -rp "${prompt} [y/N]: " response
  [[ "$(echo "$response" | tr '[:upper:]' '[:lower:]')" =~ ^(yes|y)$ ]]
}

# Wait for user to press Enter
pause() {
  local message="${1:-Press Enter to continue...}"
  read -rp "$message"
}

# ============================================
# File / Path Helpers
# ============================================

# Ensure a directory exists, creating it if needed
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log_debug "Created directory: $dir"
  fi
}

# Create a symlink safely — skips if already correct, warns if conflict
# Usage: safe_symlink "/source/path" "/link/path"
safe_symlink() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    local current_target
    current_target="$(readlink "$target")"
    if [[ "$current_target" == "$source" ]]; then
      log_success "Symlink already correct: $target -> $source"
      return 0
    else
      log_warn "Symlink exists but points elsewhere: $target -> $current_target"
      log_info "Updating symlink: $target -> $source"
      rm "$target"
    fi
  elif [[ -e "$target" ]]; then
    log_warn "$target exists and is not a symlink — skipping"
    return 1
  fi

  ln -s "$source" "$target"
  log_success "Created symlink: $target -> $source"
}

# ============================================
# Error Handling
# ============================================

# Generic ERR trap — shows line number and exits
on_error() {
  local exit_code=$?
  local line_no="${1:-unknown}"
  log_error "Script failed at line ${line_no} with exit code ${exit_code}"
  sudo_stop
  exit "$exit_code"
}

# Register traps (call once from bootstrap.sh)
setup_traps() {
  trap 'on_error ${LINENO}' ERR
  trap sudo_stop EXIT
}
