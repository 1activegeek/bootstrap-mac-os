#!/usr/bin/env bash
# lib/checks.sh - Verification and validation helpers
#
# Depends on lib/utils.sh being sourced first.

# ============================================
# Tool Checks
# ============================================

check_homebrew() {
  if command_exists brew; then
    log_success "Homebrew: $(brew --version | head -1)"
    return 0
  else
    log_error "Homebrew is not installed"
    return 1
  fi
}

check_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    log_success "Xcode Command Line Tools: installed"
    return 0
  else
    log_warn "Xcode Command Line Tools: not installed"
    return 1
  fi
}

check_op_installed() {
  if command_exists op; then
    log_success "1Password CLI: installed"
    return 0
  else
    log_warn "1Password CLI: not installed"
    return 1
  fi
}

# Verify 1Password CLI is authenticated (account is signed in)
check_op_auth() {
  if ! command_exists op; then
    log_warn "1Password CLI: not installed"
    return 1
  fi
  if op account list &>/dev/null 2>&1; then
    log_success "1Password CLI: authenticated"
    return 0
  else
    log_warn "1Password CLI: not authenticated (run 'op signin')"
    return 1
  fi
}

check_chezmoi() {
  if command_exists chezmoi; then
    log_success "chezmoi: $(chezmoi --version 2>/dev/null | head -1)"
    return 0
  else
    log_error "chezmoi is not installed"
    return 1
  fi
}

check_dockutil() {
  if command_exists dockutil; then
    log_success "dockutil: installed"
    return 0
  else
    log_error "dockutil is not installed"
    return 1
  fi
}

check_starship() {
  if command_exists starship; then
    log_success "starship: $(starship --version 2>/dev/null | head -1)"
    return 0
  else
    log_error "starship is not installed"
    return 1
  fi
}

# ============================================
# Application Checks
# ============================================

# Returns 0 if a .app bundle is found in standard locations
app_installed() {
  local app_name="$1"
  [[ -d "/Applications/${app_name}.app" ]] ||
  [[ -d "/System/Applications/${app_name}.app" ]] ||
  [[ -d "${HOME}/Applications/${app_name}.app" ]] ||
  [[ -d "/System/Applications/Utilities/${app_name}.app" ]]
}

# ============================================
# Environment Checks
# ============================================

check_not_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Do not run this script as root. It will request sudo when needed."
    exit 1
  fi
}

# Check macOS App Store sign-in status (required for MAS installs)
check_mas_signin() {
  if command_exists mas; then
    if mas account &>/dev/null 2>&1; then
      log_success "Mac App Store: signed in ($(mas account))"
      return 0
    else
      log_warn "Mac App Store: not signed in — MAS apps will likely fail"
      return 1
    fi
  else
    log_warn "mas CLI: not yet installed (will be available after brew bundle)"
    return 1
  fi
}

# Warn if minimum macOS version is not met
check_macos_version() {
  local minimum="${1:-14}"
  local current
  current="$(macos_major_version)"

  if [[ "$current" -ge "$minimum" ]]; then
    log_success "macOS: $(macos_version) (>= ${minimum} required)"
    return 0
  else
    log_warn "macOS $(macos_version) is below recommended minimum (${minimum})"
    return 1
  fi
}

# ============================================
# Preflight Summary
# ============================================

# Run all environment checks and display a summary.
# Does NOT exit on failure — modules handle their own hard requirements.
preflight_checks() {
  log_step "Preflight checks"

  check_not_root
  require_macos

  echo ""
  log_info "System : macOS $(macos_version) ($(uname -m))"
  log_info "User   : $(whoami)"
  log_info "Home   : ${HOME}"
  log_info "Shell  : ${SHELL}"
  log_info "Profile: ${MACHINE_PROFILE:-personal}"
  echo ""

  check_macos_version 14 || true
  check_xcode_cli      || true
  check_homebrew       || true
  check_op_installed   || true

  echo ""
}
