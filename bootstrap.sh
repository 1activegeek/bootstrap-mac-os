#!/usr/bin/env bash
# macOS Bootstrap Tool v2.1

set -euo pipefail

if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  BOOTSTRAP_REPO="${BOOTSTRAP_REPO:-https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git}"
  BOOTSTRAP_DIR="${HOME}/.bootstrap"

  echo "[INFO] Cloning bootstrap repo to ${BOOTSTRAP_DIR}..."
  if ! command -v git >/dev/null 2>&1; then
    echo "[INFO] Installing Xcode Command Line Tools (required for git)..."
    xcode-select --install
    until command -v git >/dev/null 2>&1; do sleep 5; done
  fi

  rm -rf "${BOOTSTRAP_DIR}"
  echo "[INFO] Cloning branch v2 from ${BOOTSTRAP_REPO}"
  git clone -b v2 "${BOOTSTRAP_REPO}" "${BOOTSTRAP_DIR}"
  exec "${BOOTSTRAP_DIR}/bootstrap.sh" "$@"
fi

# shellcheck source=lib/utils.sh
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck source=lib/checks.sh
source "${SCRIPT_DIR}/lib/checks.sh"
# shellcheck source=lib/menu.sh
source "${SCRIPT_DIR}/lib/menu.sh"

UNATTENDED=false
BOOTSTRAP_DEBUG="${BOOTSTRAP_DEBUG:-false}"
BOOTSTRAP_MODE="${BOOTSTRAP_MODE:-fresh}"
DRY_RUN="${DRY_RUN:-false}"

for arg in "$@"; do
  case "$arg" in
    --unattended) UNATTENDED=true ;;
    --phase2) BOOTSTRAP_MODE="phase2" ;;
    --phase3) BOOTSTRAP_MODE="phase3" ;;
    --phase4) BOOTSTRAP_MODE="phase4" ;;
    --update) BOOTSTRAP_MODE="update" ;;
    --dry-run) DRY_RUN=true ;;
    --debug) BOOTSTRAP_DEBUG=true ;;
  esac
done
export BOOTSTRAP_DEBUG

NEW_HOSTNAME="${NEW_HOSTNAME:-}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/1activegeek/dotfiles.git}"
SELECTED_MODULES="${SELECTED_MODULES:-}"
SELECTED_PACKAGE_KEYS="${SELECTED_PACKAGE_KEYS:-}"
INSTALL_SCOPE="${INSTALL_SCOPE:-auto}"

export SCRIPT_DIR NEW_HOSTNAME DOTFILES_REPO SELECTED_MODULES SELECTED_PACKAGE_KEYS INSTALL_SCOPE BOOTSTRAP_MODE DRY_RUN

run_module_or_dry() {
  local module_name="$1"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run module: ${module_name}"
    return 0
  fi
  run_module "$module_name"
}

show_preinstall_reminder() {
  echo ""
  echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${YELLOW}  PRE-INSTALL CHECKLIST                        ${NC}"
  echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
  echo ""
  echo "  [ ] Signed into Apple ID"
  echo "  [ ] Signed into Mac App Store"
  echo "  [ ] iCloud sync complete (Documents/Desktop)"
  echo ""
  read -rp "  Press Enter to continue, or q to quit: " ready_input
  if [[ "$(echo "$ready_input" | tr '[:upper:]' '[:lower:]')" == "q" ]]; then
    log_info "Exiting. Re-run when pre-install steps are complete."
    exit 0
  fi
}

phase2_readiness_checkpoint() {
  echo ""
  echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${YELLOW}  PHASE 2 READINESS CHECK                      ${NC}"
  echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════${NC}"
  echo ""
  echo "  Requirements before Phase 2:"
  echo "  - 1Password desktop app is signed in"
  echo "  - 1Password CLI integration is enabled"
  echo "  - 1Password CLI auth completed (op signin)"
  echo "  - Mac App Store signed in (recommended)"
  echo ""

  local op_installed="no"
  local op_auth="no"
  local mas_auth="no"

  if check_op_installed >/dev/null 2>&1; then
    op_installed="yes"
  fi
  if check_op_auth >/dev/null 2>&1; then
    op_auth="yes"
  fi
  if check_mas_signin >/dev/null 2>&1; then
    mas_auth="yes"
  fi

  printf "  %-28s %s\n" "1Password CLI installed:" "$op_installed"
  printf "  %-28s %s\n" "1Password CLI authenticated:" "$op_auth"
  printf "  %-28s %s\n" "Mac App Store signed in:" "$mas_auth"
  echo ""

  if [[ "$op_auth" != "yes" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_warn "[dry-run] Phase 2 would block here: 1Password CLI auth required."
      log_info "[dry-run] Run this on real execution: eval \$(op signin)"
    else
      log_error "Phase 2 requires authenticated 1Password CLI."
      log_info "Run: eval \$(op signin)"
      return 1
    fi
  fi

  if [[ "$mas_auth" != "yes" ]]; then
    log_warn "App Store is not signed in; MAS installs may fail later."
  fi

  return 0
}

run_phase2() {
  log_step "Phase 2: Core config + secrets"

  [[ -n "${NEW_HOSTNAME:-}" ]] && run_module_or_dry "02-hostname.sh"
  run_module_or_dry "03-macos-defaults.sh"
  run_module_or_dry "05-zsh.sh"
  run_module_or_dry "06-chezmoi.sh"
  run_module_or_dry "08-homebrew-autoupdate.sh"
  run_module_or_dry "09-1password-secrets.sh"
}

run_phase4() {
  log_step "Phase 4: Final customizations"
  run_module_or_dry "04-dock.sh"
  run_module_or_dry "07-symlinks.sh"
  run_module_or_dry "10-post-install.sh"
}

run_package_selection() {
  local scope="$1"
  INSTALL_SCOPE="$scope"
  export INSTALL_SCOPE SELECTED_MODULES SELECTED_PACKAGE_KEYS
  run_module "01-homebrew.sh"
}

require_macos
check_not_root
setup_traps

if [[ "$UNATTENDED" == "false" ]]; then
  run_menu
fi

export BOOTSTRAP_MODE NEW_HOSTNAME SELECTED_MODULES SELECTED_PACKAGE_KEYS

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "Dry-run mode enabled: no system changes will be made"
else
  log_step "Requesting administrator access"
  sudo_keepalive
fi

case "$BOOTSTRAP_MODE" in
  fresh)
    if [[ "$UNATTENDED" == "false" ]]; then
      show_preinstall_reminder
    else
      log_info "Unattended mode: skipping interactive pre-install reminder"
    fi
    preflight_checks
    SELECTED_MODULES="core"
    SELECTED_PACKAGE_KEYS=""
    run_package_selection "selected"
    [[ -n "${NEW_HOSTNAME:-}" ]] && run_module_or_dry "02-hostname.sh"

    echo ""
    echo -e "${BOLD}${GREEN}==============================${NC}"
    echo -e "${BOLD}${GREEN}  Phase 1 Complete            ${NC}"
    echo -e "${BOLD}${GREEN}==============================${NC}"

    if phase2_readiness_checkpoint; then
      if [[ "$UNATTENDED" == "true" ]]; then
        log_info "Unattended mode: stopping after Phase 1. Run --phase2 separately when ready."
      else
        read -rp "  Continue to Phase 2 now? [Y/n]: " continue_phase2
        if [[ "$(echo "${continue_phase2:-y}" | tr '[:upper:]' '[:lower:]')" != "n" ]]; then
          run_phase2
        else
          log_info "Paused after Phase 1. Re-run with --phase2 when ready."
        fi
      fi
    else
      log_warn "Phase 2 not started due to unmet requirements."
    fi
    ;;

  phase2)
    phase2_readiness_checkpoint
    run_phase2
    ;;

  phase3)
    if [[ -z "${SELECTED_MODULES:-}" ]]; then
      log_warn "No modules selected for Phase 3; nothing to install."
    else
      run_package_selection "selected"
    fi
    ;;

  phase4)
    run_phase4
    ;;

  update)
    run_package_selection "update"
    ;;

  install-modules)
    if [[ -z "${SELECTED_MODULES:-}" ]]; then
      log_warn "No modules selected; nothing to install."
    else
      run_package_selection "selected"
    fi
    ;;

  install-apps)
    if [[ -z "${SELECTED_PACKAGE_KEYS:-}" ]]; then
      log_warn "No individual apps selected; nothing to install."
    else
      run_package_selection "selected"
    fi
    ;;

  *)
    log_error "Unknown mode: $BOOTSTRAP_MODE"
    exit 1
    ;;
esac

if [[ "$DRY_RUN" != "true" ]]; then
  sudo_stop
fi

echo ""
echo -e "${BOLD}${GREEN}======================================${NC}"
echo -e "${BOLD}${GREEN}  Bootstrap action complete           ${NC}"
echo -e "${BOLD}${GREEN}======================================${NC}"
