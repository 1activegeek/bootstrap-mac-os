#!/usr/bin/env bash
# modules/08-homebrew-autoupdate.sh - Configure Homebrew autoupdate
#
# Sets up brew-autoupdate to run daily in the background.
# This uses the 'homebrew/autoupdate' tap which provides:
#   brew autoupdate start <seconds> [flags]
#
# The launchd agent runs every 86400 seconds (24 hours).

if ! command_exists brew; then
  log_error "Homebrew is not installed — skipping autoupdate setup"
  return 1
fi

# ============================================
# Ensure homebrew/autoupdate tap is present
# ============================================
if ! brew tap | grep -q "homebrew/autoupdate"; then
  log_info "Tapping homebrew/autoupdate..."
  brew tap homebrew/autoupdate
fi

# ============================================
# Start autoupdate
# ============================================
# Arguments:
#   86400           = update interval in seconds (24 hours)
#   --upgrade       = also upgrade outdated packages
#   --cleanup       = run brew cleanup after upgrading
#   (no notification flag; keep this quiet/background-only)
log_info "Configuring Homebrew autoupdate (24-hour interval)..."

autoupdate_ok=true
if ! brew autoupdate start 86400 --upgrade --cleanup 2>&1 | \
  while IFS= read -r line; do
    log_substep "$line"
  done; then
  autoupdate_ok=false
  log_warn "Homebrew autoupdate setup failed; continuing bootstrap"
fi

if [[ "$autoupdate_ok" == "true" ]]; then
  log_success "Homebrew autoupdate configured (runs every 24 hours)"
else
  log_warn "Homebrew autoupdate is not active; run 'brew autoupdate start 86400 --upgrade --cleanup' later"
fi
log_info "Commands: baustart / baukill / baustatus (defined in 04-brew.zsh)"
