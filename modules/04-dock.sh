#!/usr/bin/env bash
# modules/04-dock.sh - Configure macOS Dock via dockutil
#
# Removes unwanted items, then adds desired apps in specific positions.
# Uses --no-restart for all individual changes, then issues a single
# `killall Dock` at the end (much faster than per-item restarts).
#
# Apps that are not installed are skipped with a warning (not an error).

if ! command_exists dockutil; then
  log_error "dockutil is not installed. Run brew bundle first."
  return 1
fi

log_info "Configuring Dock..."

# ============================================
# Remove unwanted items
# ============================================
log_substep "Removing unwanted Dock items"

DOCK_REMOVE=(
  "Launchpad"
  "Maps"
  "FaceTime"
  "Contacts"
  "Notes"
  "Freeform"
  "TV"
  "News"
  "Numbers"
  "Keynote"
  "Pages"
  "App Store"
  "System Settings"
  "TickTick"
  "Obsidian"
  "iPhone Mirroring"
  "Arc"
  "TeamViewer"
)

for item in "${DOCK_REMOVE[@]}"; do
  if dockutil --find "$item" &>/dev/null 2>&1; then
    dockutil --remove "$item" --no-restart
    log_substep "Removed: $item"
  else
    log_debug "Not in Dock (skip): $item"
  fi
done

# ============================================
# Add desired items in order
# ============================================
log_substep "Adding Dock items"

# Format: "AppName|/path/to/App.app"
# Apps are added left-to-right (each appended to end of apps section)
DOCK_ADD=(
  "Music|/System/Applications/Music.app"
  "Podcasts|/System/Applications/Podcasts.app"
  "Books|/System/Applications/Books.app"
  "Photos|/System/Applications/Photos.app"
  "Shortcuts|/System/Applications/Shortcuts.app"
  "Safari|/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
  "Google Chrome|/Applications/Google Chrome.app"
  "Mail|/System/Applications/Mail.app"
  "Calendar|/System/Applications/Calendar.app"
  "zoom.us|/Applications/zoom.us.app"
  "Slack|/Applications/Slack.app"
  "Discord|/Applications/Discord.app"
  "Messages|/System/Applications/Messages.app"
  "Visual Studio Code|/Applications/Visual Studio Code.app"
  "Ghostty|/Applications/Ghostty.app"
  "Terminal|/System/Applications/Utilities/Terminal.app"
)

for entry in "${DOCK_ADD[@]}"; do
  IFS='|' read -r name path <<< "$entry"

  # Try the exact path first; if Safari lives in an alternate location, handle it
  if [[ ! -e "$path" ]] && [[ "$name" == "Safari" ]]; then
    path="/Applications/Safari.app"
  fi

  if [[ -e "$path" ]]; then
    if ! dockutil --find "$name" &>/dev/null 2>&1; then
      dockutil --add "$path" --label "$name" --section apps --no-restart
      log_substep "Added: $name"
    else
      log_debug "Already in Dock: $name"
    fi
  else
    log_warn "App not found, skipping Dock entry: $name ($path)"
  fi
done

# ============================================
# Add "Others" section (folders)
# ============================================
log_substep "Adding Dock folder items"

# Applications folder — grid view
if ! dockutil --find "Applications" &>/dev/null 2>&1; then
  dockutil --add "/Applications" \
    --label "Applications" \
    --view grid \
    --display folder \
    --sort name \
    --section others \
    --no-restart
  log_substep "Added: Applications folder"
fi

# Downloads folder — list view
if ! dockutil --find "Downloads" &>/dev/null 2>&1; then
  dockutil --add "${HOME}/Downloads" \
    --label "Downloads" \
    --view list \
    --display folder \
    --sort dateadded \
    --section others \
    --no-restart
  log_substep "Added: Downloads folder"
fi

# ============================================
# Single Dock restart (apply all changes at once)
# ============================================
log_substep "Restarting Dock to apply changes"
killall Dock 2>/dev/null || true

log_success "Dock configured"
