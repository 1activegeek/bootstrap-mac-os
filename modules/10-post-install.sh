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
echo "  [ ] Place ~/.ssh/id_gitea key (for Obsidian/Gitea sync)"
echo "  [ ] Sign into Mac App Store (if MAS apps were skipped)"
echo "  [ ] Sign into iCloud and verify Obsidian/sync"
echo "  [ ] Open Raycast and import settings backup"
echo "  [ ] Configure Kap: set global shortcut Cmd+Shift+3"
echo "  [ ] Disable screenshot shortcut in System Settings > Keyboard Shortcuts"
echo "  [ ] Set desktop wallpaper and sources in System Settings > Wallpaper"
echo "  [ ] Set mouse cursor color in System Settings > Accessibility > Display"
echo "  [ ] Configure app-specific settings (Slack workspaces, Discord servers)"
echo "  [ ] Install enconvo manually: https://www.enconvo.com"
echo "  [ ] Install AnkerSlicer manually (no Homebrew cask available)"
echo "  [ ] Restart to complete all system changes"
echo ""
log_success "Post-install check complete."
