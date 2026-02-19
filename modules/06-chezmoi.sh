#!/usr/bin/env bash
# modules/06-chezmoi.sh - Initialize chezmoi and deploy non-sensitive dotfiles
#
# On a fresh machine:
#   1. Initialises chezmoi from the dotfiles repo
#   2. Applies non-sensitive dotfiles (excludes encrypted/secret files)
#
# On an existing machine:
#   1. Updates chezmoi source from the remote
#   2. Re-applies dotfiles
#
# Sensitive files (SSH keys, etc.) are applied in Phase 2 (09-1password-secrets.sh)
# after 1Password is authenticated.

if ! command_exists chezmoi; then
  log_error "chezmoi is not installed. Run the Homebrew module first."
  return 1
fi

# ============================================
# Dotfiles repo URL
# ============================================
# Passed in from bootstrap.sh via DOTFILES_REPO env var
local dotfiles_repo="${DOTFILES_REPO:-https://github.com/shawnmix/dotfiles.git}"
local chezmoi_src="${HOME}/.local/share/chezmoi"

# ============================================
# Initialise or update chezmoi
# ============================================
if [[ ! -d "$chezmoi_src" ]]; then
  log_info "Initialising chezmoi from: ${dotfiles_repo}"
  chezmoi init "${dotfiles_repo}"
  log_success "chezmoi initialised"
else
  log_info "chezmoi already initialised — updating from remote"
  chezmoi update --apply=false
  log_success "chezmoi source updated"
fi

# ============================================
# Apply non-sensitive dotfiles
# ============================================
# We exclude 'encrypted' tagged files — those require 1Password (Phase 2).
# We also run with --no-tty so it doesn't prompt interactively here.
log_info "Applying dotfiles (non-sensitive)..."

chezmoi apply \
  --exclude=encrypted \
  --force \
  2>&1 | while IFS= read -r line; do
    log_substep "$line"
  done

log_success "Dotfiles deployed via chezmoi"
log_info "To edit managed dotfiles: chezmoi edit ~/.zshrc"
log_info "To see pending changes:   chezmoi diff"
log_info "To re-apply:              chezmoi apply"
