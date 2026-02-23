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
# id_gitea SSH key from 1Password
# ============================================
# Fetches the private key stored in 1Password and writes it to ~/.ssh/id_gitea.
# Required for Obsidian sync with the self-hosted Gitea instance.
log_info "Fetching id_gitea SSH key from 1Password..."

local ssh_dir="${HOME}/.ssh"
local gitea_key="${ssh_dir}/id_gitea"
local gitea_pub="${ssh_dir}/id_gitea.pub"

ensure_dir "$ssh_dir"
chmod 700 "$ssh_dir"

# Fetch private key — adjust the item name/field to match your 1Password vault.
# The item is expected to be named "id_gitea" with fields "private key" and "public key".
if op item get "id_gitea" --fields "private key" --reveal 2>/dev/null | \
    grep -q "BEGIN"; then

  op item get "id_gitea" --fields "private key" --reveal 2>/dev/null \
    > "$gitea_key"
  chmod 600 "$gitea_key"
  log_success "id_gitea private key written to ~/.ssh/id_gitea"

  # Fetch public key if available
  local pub
  pub="$(op item get "id_gitea" --fields "public key" --reveal 2>/dev/null || true)"
  if [[ -n "$pub" ]]; then
    echo "$pub" > "$gitea_pub"
    chmod 644 "$gitea_pub"
    log_success "id_gitea public key written to ~/.ssh/id_gitea.pub"
  fi

else
  log_warn "Could not fetch id_gitea from 1Password."
  log_warn "Ensure a 1Password item named 'id_gitea' exists with a 'private key' field."
  log_warn "You can add it manually to ~/.ssh/id_gitea and run: chmod 600 ~/.ssh/id_gitea"
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
