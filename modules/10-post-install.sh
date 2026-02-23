#!/usr/bin/env bash
# modules/10-post-install.sh - Post-install validation and summary
#
# Checks that key tools are installed, displays a system summary,
# and lists any remaining manual steps.

log_step "Post-install validation"

# ============================================
# Tool status check
# ============================================
declare -A TOOLS=(
  ["brew"]="Homebrew"
  ["chezmoi"]="chezmoi"
  ["starship"]="Starship"
  ["atuin"]="Atuin"
  ["zoxide"]="Zoxide"
  ["eza"]="eza"
  ["fzf"]="fzf"
  ["zellij"]="Zellij"
  ["op"]="1Password CLI"
  ["dockutil"]="dockutil"
  ["fastfetch"]="fastfetch"
  ["git"]="Git"
)

echo ""
echo "  Tool Status:"
echo "  ─────────────────────────────────────────"

pass_count=0
fail_count=0

for cmd in "${!TOOLS[@]}"; do
  local name="${TOOLS[$cmd]}"
  if command_exists "$cmd"; then
    printf "  ${GREEN}✓${NC}  %-20s\n" "$name"
    (( pass_count++ ))
  else
    printf "  ${YELLOW}?${NC}  %-20s  (not found on PATH)\n" "$name"
    (( fail_count++ ))
  fi
done

echo "  ─────────────────────────────────────────"
echo "  ${pass_count} available, ${fail_count} not found"
echo ""

# ============================================
# System summary
# ============================================
echo "  System Summary:"
echo "  ─────────────────────────────────────────"
printf "  %-18s %s\n" "Profile:"    "${MACHINE_PROFILE:-personal}"
printf "  %-18s %s\n" "Hostname:"   "$(scutil --get ComputerName 2>/dev/null || echo 'unchanged')"
printf "  %-18s %s\n" "macOS:"      "$(sw_vers -productVersion)"
printf "  %-18s %s\n" "Shell:"      "${SHELL}"
printf "  %-18s %s\n" "Chezmoi:"    "$(chezmoi --version 2>/dev/null | head -1 || echo 'n/a')"

local managed_count
managed_count="$(chezmoi managed 2>/dev/null | wc -l | tr -d ' ')"
printf "  %-18s %s files\n" "Managed files:" "$managed_count"
echo "  ─────────────────────────────────────────"
echo ""

# ============================================
# Display fastfetch (system info)
# ============================================
if command_exists fastfetch; then
  echo ""
  fastfetch
  echo ""
fi

# ============================================
# Manual steps remaining
# ============================================
echo ""
echo -e "${BOLD}${YELLOW}  Manual steps remaining:${NC}"
echo ""
  echo "  [ ] Open 1Password — verify SSH agent is working"
  echo "  [ ] Sign into iCloud and verify Obsidian/sync"
  echo "  [ ] Open Raycast and import settings backup"
  echo "  [ ] Configure Kap: set global shortcut Cmd+Shift+3 (system shortcuts now disabled)"
  echo "  [ ] Set desktop wallpaper and sources in System Settings > Wallpaper"
  echo "  [ ] Set mouse cursor color in System Settings > Accessibility > Display"
  echo "  [ ] Configure app-specific settings (Slack workspaces, Discord servers)"
  echo "  [ ] Restart to complete all system changes"
  echo ""
  echo -e "${BOLD}${CYAN}  App Settings Restore Notes:${NC}"
  echo ""
  echo "  Raycast    — Settings > Advanced > Import (backup exported from old machine)"
  echo "  Ghostty    — Dotfiles managed by chezmoi (~/.config/ghostty/config)"
  echo "  Zellij     — Dotfiles managed by chezmoi (~/.config/zellij/config.kdl)"
  echo "  VS Code    — Settings Sync (sign in with GitHub/Microsoft in VS Code)"
  echo "  Slack      — Sign into each workspace: File > Sign in to another workspace"
  echo "  Discord    — Sign in; servers rejoin automatically from your account"
  echo "  Obsidian   — Open vault from iCloud Drive (sync via iCloud)"
  echo "  Atuin      — Run: atuin login  (syncs history from Atuin cloud)"
  echo "  1Password  — Sign in to restore all vault access"
  echo ""
log_success "Post-install check complete."
