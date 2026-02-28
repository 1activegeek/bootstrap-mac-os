#!/usr/bin/env bash
# modules/01-homebrew.sh - Homebrew package install/update engine

# shellcheck source=config/package-catalog.sh
source "${SCRIPT_DIR}/config/package-catalog.sh"

INSTALL_SCOPE="${INSTALL_SCOPE:-auto}"
SELECTED_MODULES="${SELECTED_MODULES:-}"
SELECTED_PACKAGE_KEYS="${SELECTED_PACKAGE_KEYS:-}"
DRY_RUN="${DRY_RUN:-false}"

MAS_CACHE=""
SUCCESS_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

ensure_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    log_success "Xcode Command Line Tools: already installed"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would install Xcode Command Line Tools"
    return 0
  fi

  log_info "Installing Xcode Command Line Tools..."
  xcode-select --install
  log_info "Waiting for Xcode CLI tools to finish installing..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  log_success "Xcode Command Line Tools installed"
}

ensure_homebrew() {
  if command_exists brew; then
    log_success "Homebrew: already installed"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "[dry-run] Would install Homebrew"
      return 0
    fi

    log_info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_success "Homebrew installed"
  fi

  eval "$("$(brew_prefix)/bin/brew" shellenv)"
}

configure_homebrew() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run: brew analytics off"
    log_info "[dry-run] Would run: brew update --quiet"
    return 0
  fi

  log_substep "Disabling Homebrew analytics"
  brew analytics off

  log_substep "Updating Homebrew"
  brew update --quiet
}

package_in_list() {
  local value="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$value" ]] && return 0
  done
  return 1
}

collect_selected_package_lines() {
  SELECTED_PACKAGE_LINES=()
  SELECTED_PACKAGE_KEYS_RESOLVED=()

  if [[ -n "$SELECTED_PACKAGE_KEYS" ]]; then
    IFS=',' read -r -a package_keys <<< "$SELECTED_PACKAGE_KEYS"
    local package_key package_line
    for package_key in "${package_keys[@]}"; do
      package_key="${package_key// /}"
      [[ -z "$package_key" ]] && continue
      if package_in_list "$package_key" "${SELECTED_PACKAGE_KEYS_RESOLVED[@]-}"; then
        continue
      fi

      package_line="$(catalog_package_line_by_key "$package_key" || true)"
      if [[ -n "$package_line" ]]; then
        SELECTED_PACKAGE_LINES+=("$package_line")
        SELECTED_PACKAGE_KEYS_RESOLVED+=("$package_key")
      else
        log_warn "Unknown package key skipped: $package_key"
      fi
    done
    return 0
  fi

  if [[ -n "$SELECTED_MODULES" ]]; then
    IFS=',' read -r -a module_ids <<< "$SELECTED_MODULES"
    local module_id package_line package_key
    for module_id in "${module_ids[@]}"; do
      module_id="${module_id// /}"
      [[ -z "$module_id" ]] && continue
      while IFS= read -r package_line; do
        [[ -z "$package_line" ]] && continue
        package_key="${package_line%%|*}"
        if package_in_list "$package_key" "${SELECTED_PACKAGE_KEYS_RESOLVED[@]-}"; then
          continue
        fi
        SELECTED_PACKAGE_LINES+=("$package_line")
        SELECTED_PACKAGE_KEYS_RESOLVED+=("$package_key")
      done < <(catalog_module_lines "$module_id")
    done
  fi
}

is_formula_installed() {
  local ref="$1"
  brew list --formula "$ref" >/dev/null 2>&1
}

is_cask_installed() {
  local ref="$1"
  brew list --cask "$ref" >/dev/null 2>&1
}

ensure_mas_cache() {
  [[ -n "$MAS_CACHE" ]] && return 0
  if command_exists mas && mas account >/dev/null 2>&1; then
    MAS_CACHE="$(mas list 2>/dev/null || true)"
  else
    MAS_CACHE=""
  fi
}

is_mas_installed() {
  local app_id="$1"
  ensure_mas_cache
  [[ "$MAS_CACHE" == *"$app_id"* ]]
}

install_one_package() {
  local package_line="$1"
  local key module type ref name
  IFS='|' read -r key module type ref name <<< "$package_line"
  [[ -z "$key" ]] && return 0

  local installed=false
  case "$type" in
    brew) is_formula_installed "$ref" && installed=true ;;
    cask) is_cask_installed "$ref" && installed=true ;;
    mas)  is_mas_installed "$ref" && installed=true ;;
  esac

  if [[ "$installed" == "true" ]]; then
    log_substep "[skip] Already installed: $name ($key)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_substep "[dry-run] Would install: $name ($type:$ref)"
    return 0
  fi

  log_substep "Installing: $name ($type:$ref)"

  case "$type" in
    brew)
      if brew install "$ref" >/dev/null 2>&1; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        log_warn "Failed to install formula: $ref"
      fi
      ;;
    cask)
      if HOMEBREW_CASK_OPTS="--no-quarantine" brew install --cask "$ref" >/dev/null 2>&1; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        log_warn "Failed to install cask: $ref"
      fi
      ;;
    mas)
      if ! command_exists mas; then
        FAILED_COUNT=$((FAILED_COUNT + 1))
        log_warn "Failed to install MAS app ${name}: mas CLI not installed"
        return 0
      fi
      if ! mas account >/dev/null 2>&1; then
        FAILED_COUNT=$((FAILED_COUNT + 1))
        log_warn "Failed to install MAS app ${name}: App Store not signed in"
        return 0
      fi
      if mas install "$ref" >/dev/null 2>&1; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        MAS_CACHE=""
      else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        log_warn "Failed to install MAS app id: $ref"
      fi
      ;;
  esac
}

run_selected_install_mode() {
  collect_selected_package_lines

  if [[ ${#SELECTED_PACKAGE_LINES[@]} -eq 0 ]]; then
    log_warn "No packages selected; skipping install"
    return 0
  fi

  log_info "Selected package count: ${#SELECTED_PACKAGE_LINES[@]}"
  local package_line
  for package_line in "${SELECTED_PACKAGE_LINES[@]}"; do
    install_one_package "$package_line"
  done

  echo ""
  log_info "Install summary:"
  log_info "  Success: $SUCCESS_COUNT"
  log_info "  Skipped (already present): $SKIPPED_COUNT"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "  Dry-run planned installs: ${#SELECTED_PACKAGE_LINES[@]}"
  else
    if [[ "$FAILED_COUNT" -gt 0 ]]; then
      log_warn "  Failed: $FAILED_COUNT"
      log_warn "Some packages failed but the installer continued."
    else
      log_info "  Failed: 0"
    fi
  fi
}

run_update_mode() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run: brew update"
    log_info "[dry-run] Would run: brew upgrade"
    log_info "[dry-run] Would run: brew upgrade --cask"
    log_info "[dry-run] Would run: mas upgrade (if signed in)"
    log_info "[dry-run] Would run: brew cleanup --prune=all -q"
    return 0
  fi

  log_info "Running package update mode..."
  brew update
  brew upgrade || true
  brew upgrade --cask || true
  if command_exists mas; then
    if mas account >/dev/null 2>&1; then
      mas upgrade || true
    else
      log_warn "Mac App Store is not signed in; skipping mas upgrade"
    fi
  fi
  brew cleanup --prune=all -q 2>/dev/null || true
  log_success "Update mode complete"
}

run_legacy_bundle_mode() {
  local brewfile="${SCRIPT_DIR}/Brewfile"
  if [[ ! -f "$brewfile" ]]; then
    log_error "Brewfile not found: ${brewfile}"
    return 1
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Would run legacy bundle from: ${brewfile}"
    return 0
  fi

  log_info "Installing packages from legacy Brewfile..."
  if brew bundle --file="$brewfile"; then
    log_success "Legacy Brewfile packages installed"
  else
    log_warn "Legacy brew bundle had failures"
  fi
}

ensure_xcode_cli
ensure_homebrew

if [[ "$INSTALL_SCOPE" == "update" ]]; then
  run_update_mode
  return 0
fi

configure_homebrew

if [[ "$INSTALL_SCOPE" == "legacy-all" ]]; then
  run_legacy_bundle_mode
else
  run_selected_install_mode
fi

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[dry-run] Would run: brew cleanup --prune=all -q"
else
  log_substep "Running brew cleanup"
  brew cleanup --prune=all -q 2>/dev/null || true
fi

log_success "Homebrew module complete"
