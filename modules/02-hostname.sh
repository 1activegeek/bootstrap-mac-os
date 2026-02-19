#!/usr/bin/env bash
# modules/02-hostname.sh - Set machine hostname
#
# Sets all four macOS hostname identifiers:
#   ComputerName   - Friendly name shown in Finder / System Settings
#   HostName       - Fully-qualified hostname (used by scutil / DNS)
#   LocalHostName  - Bonjour name (machine.local on the network)
#   NetBIOSName    - Windows / SMB network name
#
# Skips gracefully if NEW_HOSTNAME is empty or not set.

if [[ -z "${NEW_HOSTNAME:-}" ]]; then
  log_info "No hostname specified — skipping"
  return 0
fi

local current_name
current_name="$(scutil --get ComputerName 2>/dev/null || echo 'unknown')"

if [[ "$current_name" == "$NEW_HOSTNAME" ]]; then
  log_success "Hostname already set to: ${NEW_HOSTNAME}"
  return 0
fi

log_info "Setting hostname: '${current_name}' -> '${NEW_HOSTNAME}'"

sudo scutil --set ComputerName  "${NEW_HOSTNAME}"
sudo scutil --set HostName      "${NEW_HOSTNAME}"
sudo scutil --set LocalHostName "${NEW_HOSTNAME}"
sudo defaults write \
  /Library/Preferences/SystemConfiguration/com.apple.smb.server \
  NetBIOSName -string "${NEW_HOSTNAME}"

log_success "Hostname set to: ${NEW_HOSTNAME}"
log_info   "A restart may be needed for all hostname changes to take full effect."
