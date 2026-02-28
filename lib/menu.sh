#!/usr/bin/env bash
# lib/menu.sh - Interactive menu system (phase and operation first)

# shellcheck source=config/package-catalog.sh
source "${SCRIPT_DIR}/config/package-catalog.sh"

show_banner() {
  echo ""
  echo -e "${BOLD}${CYAN}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║        macOS Bootstrap Tool  v2.1            ║"
  echo "  ║                                              ║"
  echo "  ║  4-phase bootstrap + modular packages        ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "  ${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo ""
}

choose_mode() {
  echo -e "${BOLD}Choose an action${NC}"
  echo ""
  echo "  1) Fresh bootstrap (Phase 1 core)   [default]"
  echo "  2) Run Phase 2 (core config + secrets)"
  echo "  3) Run Phase 3 (additional modules)"
  echo "  4) Run Phase 4 (final customizations)"
  echo "  5) Update current apps"
  echo "  6) Install modules"
  echo "  7) Install individual apps"
  echo ""
  read -rp "  Selection [1-7]: " BOOTSTRAP_MODE_CHOICE

  case "${BOOTSTRAP_MODE_CHOICE:-1}" in
    1) BOOTSTRAP_MODE="fresh" ;;
    2) BOOTSTRAP_MODE="phase2" ;;
    3) BOOTSTRAP_MODE="phase3" ;;
    4) BOOTSTRAP_MODE="phase4" ;;
    5) BOOTSTRAP_MODE="update" ;;
    6) BOOTSTRAP_MODE="install-modules" ;;
    7) BOOTSTRAP_MODE="install-apps" ;;
    *) BOOTSTRAP_MODE="fresh" ;;
  esac

  echo ""
  log_success "Mode selected: ${BOOTSTRAP_MODE}"
  echo ""
}

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

show_module_preview() {
  local module_id="$1"
  local names=""
  while IFS='|' read -r key module type ref name; do
    [[ -z "$key" ]] && continue
    [[ "$module" != "$module_id" ]] && continue
    if [[ -z "$names" ]]; then
      names="$name"
    else
      names="$names, $name"
    fi
  done < <(catalog_module_lines "$module_id")
  printf '%s\n' "$names"
}

select_modules_menu() {
  local phase_filter="$1"
  local default_behavior="$2"
  local selectable_modules=()
  local idx=1

  echo -e "${BOLD}Module selection${NC}"
  echo ""

  while IFS='|' read -r id phase title description; do
    [[ -z "$id" ]] && continue
    [[ "$id" == "core" ]] && continue
    if [[ -n "$phase_filter" ]] && [[ "$phase" != "$phase_filter" ]]; then
      continue
    fi
    selectable_modules+=("$id")
    local preview
    preview="$(show_module_preview "$id")"
    echo "  ${idx}) ${title} (${id})"
    echo "     ${description}"
    [[ -n "$preview" ]] && echo "     Apps: ${preview}"
    echo ""
    ((idx++))
  done < <(catalog_modules)

  if [[ ${#selectable_modules[@]} -eq 0 ]]; then
    log_warn "No selectable modules for this context"
    return 0
  fi

  if [[ "$default_behavior" == "all" ]]; then
    echo "  Default: all modules selected (enter numbers to disable)"
  else
    echo "  Default: no modules selected (enter numbers to enable)"
  fi

  read -rp "  Module numbers (comma-separated, Enter for default): " module_input

  local chosen_modules=()
  if [[ "$default_behavior" == "all" ]]; then
    local disabled=",${module_input// /},"
    for i in "${!selectable_modules[@]}"; do
      local num=$((i + 1))
      if [[ "$disabled" != *",${num},"* ]]; then
        chosen_modules+=("${selectable_modules[$i]}")
      fi
    done
  else
    if [[ -n "${module_input// /}" ]]; then
      IFS=',' read -r -a picks <<< "${module_input// /}"
      for pick in "${picks[@]}"; do
        if [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= ${#selectable_modules[@]} )); then
          chosen_modules+=("${selectable_modules[$((pick - 1))]}")
        fi
      done
    fi
  fi

  SELECTED_MODULES=""
  local first=true
  for module_id in "${chosen_modules[@]}"; do
    if [[ "$first" == "true" ]]; then
      SELECTED_MODULES="$module_id"
      first=false
    else
      SELECTED_MODULES+=",$module_id"
    fi
  done

  if [[ -n "$SELECTED_MODULES" ]]; then
    log_success "Selected modules: $SELECTED_MODULES"
  else
    log_info "No modules selected"
  fi
  echo ""
}

select_apps_menu() {
  local app_keys=()
  local idx=1

  echo -e "${BOLD}Individual app selection${NC}"
  echo ""
  echo "  Default: no apps selected"
  echo ""

  while IFS='|' read -r key module type ref name; do
    [[ -z "$key" ]] && continue
    [[ "$module" == "core" ]] && continue
    local module_title
    module_title="$(catalog_module_title "$module")"
    printf "  %3d) %-28s [%s]\n" "$idx" "$name" "$module_title"
    app_keys+=("$key")
    ((idx++))
  done < <(catalog_packages)

  echo ""
  read -rp "  App numbers (comma-separated, Enter for none): " app_input

  SELECTED_PACKAGE_KEYS=""
  if [[ -n "${app_input// /}" ]]; then
    IFS=',' read -r -a picks <<< "${app_input// /}"
    local first=true
    for pick in "${picks[@]}"; do
      if [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= ${#app_keys[@]} )); then
        if [[ "$first" == "true" ]]; then
          SELECTED_PACKAGE_KEYS="${app_keys[$((pick - 1))]}"
          first=false
        else
          SELECTED_PACKAGE_KEYS+=",${app_keys[$((pick - 1))]}"
        fi
      fi
    done
  fi

  if [[ -n "$SELECTED_PACKAGE_KEYS" ]]; then
    log_success "Selected apps configured"
  else
    log_info "No apps selected"
  fi
  echo ""
}

confirm_settings() {
  echo -e "${BOLD}${CYAN}Summary${NC}"
  echo "  ─────────────────────────────────────"
  echo "  Mode        : ${BOOTSTRAP_MODE}"
  echo "  Hostname    : ${NEW_HOSTNAME:-<unchanged>}"
  echo "  Modules     : ${SELECTED_MODULES:-<none>}"
  echo "  App picks   : ${SELECTED_PACKAGE_KEYS:-<none>}"
  echo "  ─────────────────────────────────────"
  echo ""
  read -rp "  Proceed? [Y/n]: " proceed
  if [[ "$(echo "$proceed" | tr '[:upper:]' '[:lower:]')" == "n" ]]; then
    log_info "Aborted."
    exit 0
  fi
  echo ""
}

run_menu() {
  show_banner
  choose_mode

  NEW_HOSTNAME="${NEW_HOSTNAME:-}"
  SELECTED_MODULES="${SELECTED_MODULES:-}"
  SELECTED_PACKAGE_KEYS="${SELECTED_PACKAGE_KEYS:-}"

  case "$BOOTSTRAP_MODE" in
    fresh)
      SELECTED_MODULES="core"
      prompt_hostname
      ;;
    phase2)
      prompt_hostname
      ;;
    phase3)
      select_modules_menu "phase3" "all"
      ;;
    phase4)
      :
      ;;
    update)
      :
      ;;
    install-modules)
      select_modules_menu "" "none"
      ;;
    install-apps)
      select_apps_menu
      ;;
  esac

  confirm_settings
}
