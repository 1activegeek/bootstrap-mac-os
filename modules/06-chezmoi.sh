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
local dotfiles_repo="${DOTFILES_REPO:-https://github.com/1activegeek/dotfiles.git}"
local chezmoi_src="${HOME}/.local/share/chezmoi"
local dry_run="${DRY_RUN:-false}"

patch_promptstringonce_compat() {
  local template_file="$1"
  [[ ! -f "$template_file" ]] && return 0
  if ! grep -q "promptStringOnce" "$template_file"; then
    return 0
  fi

  log_warn "Detected unsupported promptStringOnce in ${template_file}"
  if [[ "$dry_run" == "true" ]]; then
    log_info "[dry-run] Would patch template to use promptString compatibility mode"
    return 0
  fi

  python3 - "$template_file" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = re.sub(
    r'promptStringOnce\s+\.\s+"[^"]+"\s+"([^"]+)"',
    r'promptString "\1"',
    text,
)
path.write_text(text)
PY

  log_success "Patched chezmoi template compatibility: ${template_file}"
}

# ============================================
# Initialise or update chezmoi
# ============================================
if [[ ! -d "$chezmoi_src" ]]; then
  log_info "Initialising chezmoi from: ${dotfiles_repo}"
  if ! chezmoi init "${dotfiles_repo}"; then
    log_warn "chezmoi init failed; attempting promptStringOnce compatibility patch"
    patch_promptstringonce_compat "${chezmoi_src}/dot_chezmoi.toml.tmpl"
    if [[ "$dry_run" != "true" ]]; then
      chezmoi init --force "${dotfiles_repo}"
    fi
  fi
  patch_promptstringonce_compat "${chezmoi_src}/dot_chezmoi.toml.tmpl"
  log_success "chezmoi initialised"
else
  log_info "chezmoi already initialised — updating from remote"
  patch_promptstringonce_compat "${chezmoi_src}/dot_chezmoi.toml.tmpl"
  chezmoi update --apply=false
  patch_promptstringonce_compat "${chezmoi_src}/dot_chezmoi.toml.tmpl"
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
