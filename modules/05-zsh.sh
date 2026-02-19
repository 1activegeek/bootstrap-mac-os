#!/usr/bin/env bash
# modules/05-zsh.sh - ZSH configuration setup
#
# This module:
#   1. Warns about Oh My Zsh (but doesn't delete it)
#   2. Creates ~/.zshrc.d/ directory
#   3. Sets ZSH as the default shell if needed
#
# Note: The actual ZSH config files (.zshrc, .zprofile, .zshrc.d/*.zsh,
# starship.toml) are deployed by the chezmoi module (06-chezmoi.sh).
# This module just ensures the structure is in place.

# ============================================
# Oh My Zsh check
# ============================================
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_warn "Oh My Zsh detected at ~/.oh-my-zsh"
  log_warn "It will NOT be removed automatically."
  log_warn "Once you've verified the new ZSH config works, remove it with:"
  log_warn "  uninstall_oh_my_zsh   (built-in OMZ command)"
  log_warn "  OR: rm -rf ~/.oh-my-zsh"
  echo ""
fi

# ============================================
# Create directory structure
# ============================================
ensure_dir "${HOME}/.zshrc.d"
log_success "~/.zshrc.d/ directory ready"

# ============================================
# Set ZSH as default shell
# ============================================
local zsh_path
zsh_path="$(which zsh 2>/dev/null || echo '/bin/zsh')"

if [[ "$SHELL" != "$zsh_path" ]]; then
  log_info "Setting default shell to: ${zsh_path}"

  # Add Homebrew zsh to /etc/shells if not already there
  if ! grep -qF "$zsh_path" /etc/shells; then
    log_substep "Adding ${zsh_path} to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
  fi

  chsh -s "$zsh_path" "$(whoami)"
  log_success "Default shell set to: ${zsh_path}"
else
  log_success "Default shell is already ZSH: ${zsh_path}"
fi

log_success "ZSH module complete (dotfiles will be deployed by chezmoi)"
