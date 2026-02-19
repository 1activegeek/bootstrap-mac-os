#!/usr/bin/env bash
# modules/09-1password-secrets.sh - Deploy secrets via chezmoi + 1Password
#
# This is Phase 2 of the bootstrap. It runs AFTER the user has:
#   1. Opened 1Password and signed in
#   2. Enabled CLI integration (1Password > Settings > Developer)
#   3. Authenticated the CLI (op signin)
#
# What it does:
#   - Verifies 1Password CLI is authenticated
#   - Runs `chezmoi apply` (which now has access to 1Password for templates)
#   - Deploys SSH keys from 1Password templates
#   - Fixes SSH file permissions
#   - Configures git signing (if key is available)

# ============================================
# Verify 1Password auth
# ============================================
if ! check_op_auth; then
  log_error "1Password CLI is not authenticated."
  log_info "Please run: eval \$(op signin)"
  log_info "Then re-run: ./bootstrap.sh --phase2"
  return 1
fi

# ============================================
# Apply all dotfiles (including secrets)
# ============================================
log_info "Deploying secrets via chezmoi + 1Password..."

chezmoi apply --force 2>&1 | while IFS= read -r line; do
  log_substep "$line"
done

log_success "Dotfiles (including secrets) applied"

# ============================================
# SSH key permissions
# ============================================
log_info "Setting SSH key permissions..."

local ssh_dir="${HOME}/.ssh"
if [[ -d "$ssh_dir" ]]; then
  chmod 700 "$ssh_dir"

  # Private keys: 600
  find "$ssh_dir" -name "id_*" ! -name "*.pub" -exec chmod 600 {} \; 2>/dev/null || true

  # Public keys: 644
  find "$ssh_dir" -name "*.pub" -exec chmod 644 {} \; 2>/dev/null || true

  # Config file: 600
  [[ -f "${ssh_dir}/config" ]] && chmod 600 "${ssh_dir}/config"

  # known_hosts: 644
  [[ -f "${ssh_dir}/known_hosts" ]] && chmod 644 "${ssh_dir}/known_hosts"

  log_success "SSH key permissions set"
else
  log_warn "~/.ssh directory not found — skipping permission fix"
fi

# ============================================
# id_gitea check
# ============================================
# This key stays RAW on disk (not managed by chezmoi/1Password)
# because Obsidian needs to access it without any agent indirection.
if [[ ! -f "${HOME}/.ssh/id_gitea" ]]; then
  log_warn "~/.ssh/id_gitea not found."
  log_warn "This key must be placed manually — it's not in 1Password."
  log_warn "It's required for Obsidian sync with Gitea."
fi

# ============================================
# Git configuration
# ============================================
log_info "Verifying git configuration..."

# Set git user identity if not already configured
local git_name git_email
git_name="$(git config --global user.name 2>/dev/null || echo '')"
git_email="$(git config --global user.email 2>/dev/null || echo '')"

if [[ -z "$git_name" ]]; then
  read -rp "  Git user.name: " git_name
  git config --global user.name "$git_name"
fi

if [[ -z "$git_email" ]]; then
  read -rp "  Git user.email: " git_email
  git config --global user.email "$git_email"
fi

# Configure sensible git defaults
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global credential.helper osxkeychain
git config --global fetch.prune true
git config --global push.autoSetupRemote true

log_success "Git configuration complete"

log_success "1Password secrets module complete"
