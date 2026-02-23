#!/usr/bin/env bash
# lib/menu.sh - Interactive menu system
#
# Collects ALL user decisions upfront before any installation begins.
# Variables set here are used throughout the bootstrap process.
#
# Depends on lib/utils.sh being sourced first.

# ============================================
# Banner
# ============================================

show_banner() {
  echo ""
  echo -e "${BOLD}${CYAN}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║        macOS Bootstrap Tool  v2.0            ║"
  echo "  ║                                              ║"
  echo "  ║  Pure shell • brew bundle • chezmoi          ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "  ${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo ""
}

# ============================================
# Profile Selection
# ============================================

select_profile() {
  echo -e "${BOLD}Profile Overlay${NC}"
  echo ""
  echo "  The base Brewfile installs all core packages."
  echo "  An optional profile overlay (profiles/Brewfile.default) adds:"
  echo "    - Microsoft Teams, azure-cli, Okta Verify (work)"
  echo "    - Flux CD, go-task, jq, sops, kustomize, etc. (homelab)"
  echo ""
  read -rp "  Install profile overlay? [Y/n]: " choice

  case "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" in
    n|no)  MACHINE_PROFILE=""        ;;
    *)     MACHINE_PROFILE="default" ;;
  esac

  if [[ -n "$MACHINE_PROFILE" ]]; then
    log_success "Profile overlay: ${MACHINE_PROFILE}"
  else
    log_info "Profile overlay: none (base Brewfile only)"
  fi
  echo ""
}

# ============================================
# Hostname
# ============================================

prompt_hostname() {
  echo -e "${BOLD}Hostname${NC}"
  echo ""
  echo "  Current: $(scutil --get ComputerName 2>/dev/null || echo 'unknown')"
  read -rp "  New hostname (leave blank to skip): " NEW_HOSTNAME

  if [[ -n "${NEW_HOSTNAME:-}" ]]; then
    log_success "Hostname will be set to: ${NEW_HOSTNAME}"
  else
    log_info "Hostname: unchanged"
  fi
  echo ""
}

# ============================================
# Module Toggles
# ============================================

select_modules() {
  echo -e "${BOLD}Module Selection${NC} (all enabled by default)"
  echo ""

  # Defaults
  MOD_HOMEBREW=true
  MOD_HOSTNAME=true
  MOD_MACOS_DEFAULTS=true
  MOD_DOCK=true
  MOD_ZSH=true
  MOD_CHEZMOI=true
  MOD_SYMLINKS=true
  MOD_AUTOUPDATE=true

  echo "  [H] Homebrew + packages    : enabled"
  echo "  [M] macOS system defaults  : enabled"
  echo "  [D] Dock configuration     : enabled"
  echo "  [Z] ZSH setup              : enabled"
  echo "  [C] Chezmoi dotfiles       : enabled"
  echo "  [S] Symlinks               : enabled"
  echo "  [A] Homebrew autoupdate    : enabled"
  echo ""
  echo "  Type letters to toggle off (e.g. 'MD' disables macOS defaults and Dock),"
  echo "  or press Enter to accept all defaults:"
  read -rp "  Toggle: " toggles

  for (( i=0; i<${#toggles}; i++ )); do
    case "${toggles:$i:1}" in
      [Hh]) MOD_HOMEBREW=false       ;;
      [Mm]) MOD_MACOS_DEFAULTS=false ;;
      [Dd]) MOD_DOCK=false           ;;
      [Zz]) MOD_ZSH=false            ;;
      [Cc]) MOD_CHEZMOI=false        ;;
      [Ss]) MOD_SYMLINKS=false       ;;
      [Aa]) MOD_AUTOUPDATE=false     ;;
    esac
  done

  echo ""
  echo "  Final selection:"
  printf "    %-22s %s\n" "Homebrew:"       "$( $MOD_HOMEBREW       && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "macOS defaults:" "$( $MOD_MACOS_DEFAULTS && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "Dock:"           "$( $MOD_DOCK           && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "ZSH:"            "$( $MOD_ZSH            && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "Chezmoi:"        "$( $MOD_CHEZMOI        && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "Symlinks:"       "$( $MOD_SYMLINKS       && echo enabled || echo disabled )"
  printf "    %-22s %s\n" "Autoupdate:"     "$( $MOD_AUTOUPDATE     && echo enabled || echo disabled )"
  echo ""
}

# ============================================
# Confirmation
# ============================================

confirm_settings() {
  echo -e "${BOLD}${CYAN}Summary${NC}"
  echo "  ─────────────────────────────────────"
  echo "  Profile  : ${MACHINE_PROFILE:-none (base only)}"
  echo "  Hostname : ${NEW_HOSTNAME:-<unchanged>}"
  echo "  ─────────────────────────────────────"
  echo ""
  echo -e "  ${YELLOW}After collecting settings, the bootstrap will run unattended"
  echo -e "  until it pauses for 1Password sign-in.${NC}"
  echo ""

  read -rp "  Proceed? [Y/n]: " proceed
  if [[ "$(echo "$proceed" | tr '[:upper:]' '[:lower:]')" == "n" ]]; then
    echo ""
    log_info "Aborted."
    exit 0
  fi
  echo ""
}

# ============================================
# Run the full interactive menu
# ============================================

run_menu() {
  show_banner
  select_profile
  prompt_hostname
  select_modules
  confirm_settings
}
