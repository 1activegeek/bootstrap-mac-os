#!/usr/bin/env bash
# modules/07-symlinks.sh - Create required symlinks
#
# Creates convenience symlinks that are either:
#   a) Outside chezmoi's managed scope, or
#   b) Need to point to iCloud/dynamic locations

log_info "Creating symlinks..."

# ============================================
# ~/projects -> iCloud "1 Projects" folder
# ============================================
# The iCloud "1 Projects" folder has a space in the name.
# We create a symlink so all tools can use ~/projects without quoting.
ICLOUD_PROJECTS="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Documents/1 Projects"

if [[ -d "$ICLOUD_PROJECTS" ]]; then
  safe_symlink "$ICLOUD_PROJECTS" "${HOME}/projects"
else
  log_warn "iCloud '1 Projects' folder not found at expected path."
  log_warn "Make sure iCloud Drive is enabled and synced."
  log_warn "Expected: ${ICLOUD_PROJECTS}"
fi

# ============================================
# ~/.claude -> ~/.config/claude
# ============================================
# Claude Code looks for config in ~/.claude but we keep it in ~/.config/claude
# so it's managed alongside other .config directories.
if [[ -d "${HOME}/.config/claude" ]]; then
  if [[ ! -e "${HOME}/.claude" ]]; then
    safe_symlink "${HOME}/.config/claude" "${HOME}/.claude"
  elif [[ -d "${HOME}/.claude" ]] && [[ ! -L "${HOME}/.claude" ]]; then
    log_warn "~/.claude exists as a real directory (not a symlink)."
    log_warn "Merge its contents into ~/.config/claude and remove it manually."
  fi
else
  log_debug "~/.config/claude not yet present — symlink will be created after chezmoi runs"
fi

# ============================================
# Ensure ~/.ssh exists with correct permissions
# ============================================
ensure_dir "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

log_success "Symlinks module complete"
