#!/usr/bin/env bash
# modules/01-homebrew.sh - Install Homebrew and run brew bundle
#
# Steps:
#   1. Install Xcode Command Line Tools (if missing)
#   2. Install Homebrew (if missing)
#   3. Configure Homebrew (analytics off, update)
#   4. Run brew bundle with the base Brewfile
#   5. Run profile-specific Brewfile overlay (if present)
#   6. Run brew cleanup

# ============================================
# 1. Xcode Command Line Tools
# ============================================
if ! xcode-select -p &>/dev/null; then
  log_info "Installing Xcode Command Line Tools..."
  xcode-select --install

  log_info "Waiting for Xcode CLI tools to finish installing..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  log_success "Xcode Command Line Tools installed"
else
  log_success "Xcode Command Line Tools: already installed"
fi

# ============================================
# 2. Homebrew
# ============================================
if ! command_exists brew; then
  log_info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  eval "$("$(brew_prefix)/bin/brew" shellenv)"
  log_success "Homebrew installed"
else
  log_success "Homebrew: already installed"
fi

# Ensure brew is on PATH for the rest of this script
eval "$("$(brew_prefix)/bin/brew" shellenv)"

# ============================================
# 3. Homebrew Configuration
# ============================================
log_substep "Disabling Homebrew analytics"
brew analytics off

log_substep "Updating Homebrew"
brew update --quiet

# Skip quarantine prompts for cask installs
export HOMEBREW_CASK_OPTS="--no-quarantine"
# Don't auto-update during bundle (we already updated above)
export HOMEBREW_NO_AUTO_UPDATE=1

# ============================================
# 4. Base Brewfile
# ============================================
local brewfile="${SCRIPT_DIR}/Brewfile"
if [[ -f "$brewfile" ]]; then
  log_info "Installing packages from Brewfile..."
  brew bundle --file="$brewfile" 2>&1 | \
    grep -v "^Using " | \
    while IFS= read -r line; do
      [[ -n "$line" ]] && log_substep "$line"
    done
  log_success "Base packages installed"
else
  log_error "Brewfile not found: ${brewfile}"
  return 1
fi

# ============================================
# 5. Profile-Specific Brewfile Overlay
# ============================================
if [[ -n "${MACHINE_PROFILE:-}" ]]; then
  local profile_brewfile="${SCRIPT_DIR}/profiles/Brewfile.${MACHINE_PROFILE}"
  if [[ -f "$profile_brewfile" ]]; then
    log_info "Installing profile overlay (${MACHINE_PROFILE})..."
    brew bundle --file="$profile_brewfile" 2>&1 | \
      grep -v "^Using " | \
      while IFS= read -r line; do
        [[ -n "$line" ]] && log_substep "$line"
      done
    log_success "Profile overlay installed (${MACHINE_PROFILE})"
  else
    log_warn "Profile Brewfile not found: ${profile_brewfile}"
  fi
else
  log_info "No profile overlay selected — base Brewfile only"
fi

# ============================================
# 6. Cleanup
# ============================================
log_substep "Running brew cleanup"
brew cleanup --prune=all -q 2>/dev/null || true

log_success "Homebrew module complete"
