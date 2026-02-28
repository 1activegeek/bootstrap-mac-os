#!/usr/bin/env bash
# config/package-catalog.sh - Package/module catalog for phased installs

catalog_modules() {
  cat <<'EOF'
core|phase1|Core Bootstrap|Bare minimum packages to get productive quickly
dev-cli|phase3|Developer CLI|Core CLI tools for shell and development workflows
dev-gui|phase3|Developer Apps|Primary coding and API desktop tools
browsers|phase3|Browsers|Additional browser installs beyond core Brave
communication|phase3|Communication|Chat and meetings apps
ai|phase3|AI Tools|Desktop and local model tooling
media|phase3|Media|Recording and media playback tools
utilities|phase3|Utilities|Daily-driver helper and system apps
infra|phase3|Infra/Kubernetes|Cloud and Kubernetes tooling
printing3d|phase3|3D Printing/CAD|Slicer and CAD tooling
security|phase3|Security|Security monitoring and firewall tools
mas-extras|phase3|App Store Extras|Optional Mac App Store installs
EOF
}

catalog_packages() {
  cat <<'EOF'
brew:chezmoi|core|brew|chezmoi|chezmoi
brew:gh|core|brew|gh|GitHub CLI
brew:mas|core|brew|mas|Mac App Store CLI
cask:1password|core|cask|1password|1Password
cask:1password-cli|core|cask|1password-cli|1Password CLI
cask:raycast|core|cask|raycast|Raycast
cask:brave-browser|core|cask|brave-browser|Brave Browser
cask:ghostty|core|cask|ghostty|Ghostty
cask:handy|core|cask|handy|Handy
brew:atuin|dev-cli|brew|atuin|Atuin
brew:bat|dev-cli|brew|bat|bat
brew:bat-extras|dev-cli|brew|bat-extras|bat-extras
brew:carapace|dev-cli|brew|carapace|carapace
brew:eza|dev-cli|brew|eza|eza
brew:fastfetch|dev-cli|brew|fastfetch|fastfetch
brew:fd|dev-cli|brew|fd|fd
brew:fzf|dev-cli|brew|fzf|fzf
brew:starship|dev-cli|brew|starship|starship
brew:zellij|dev-cli|brew|zellij|zellij
brew:zoxide|dev-cli|brew|zoxide|zoxide
brew:zsh-autosuggestions|dev-cli|brew|zsh-autosuggestions|zsh-autosuggestions
brew:zsh-syntax-highlighting|dev-cli|brew|zsh-syntax-highlighting|zsh-syntax-highlighting
brew:dockutil|dev-cli|brew|dockutil|dockutil
brew:chroma|dev-cli|brew|chroma|chroma
brew:watch|dev-cli|brew|watch|watch
brew:yt-dlp|dev-cli|brew|yt-dlp|yt-dlp
brew:terraform|infra|brew|hashicorp/tap/terraform|Terraform
brew:helm|infra|brew|helm|Helm
brew:k9s|infra|brew|k9s|k9s
brew:kube-ps1|infra|brew|kube-ps1|kube-ps1
brew:kubectx|infra|brew|kubectx|kubectx
brew:kubernetes-cli|infra|brew|kubernetes-cli|kubectl
brew:azure-cli|infra|brew|azure-cli|Azure CLI
brew:jq|infra|brew|jq|jq
brew:kustomize|infra|brew|kustomize|kustomize
brew:sops|infra|brew|sops|sops
brew:yamllint|infra|brew|yamllint|yamllint
brew:pre-commit|infra|brew|pre-commit|pre-commit
brew:direnv|infra|brew|direnv|direnv
brew:go-task|infra|brew|go-task/tap/go-task|go-task
brew:flux|infra|brew|fluxcd/tap/flux|flux
brew:bun|dev-cli|brew|oven-sh/bun/bun|Bun
brew:opencode|dev-cli|brew|anomalyco/tap/opencode|opencode
cask:visual-studio-code|dev-gui|cask|visual-studio-code|Visual Studio Code
cask:docker|dev-gui|cask|docker|Docker Desktop
cask:orbstack|dev-gui|cask|orbstack|OrbStack
cask:yaak|dev-gui|cask|yaak|Yaak
cask:claude|dev-gui|cask|claude|Claude
cask:claude-code|dev-gui|cask|claude-code|Claude Code
cask:codex|dev-gui|cask|codex|Codex
cask:opencode-desktop|dev-gui|cask|opencode-desktop|OpenCode Desktop
cask:gcloud-cli|dev-gui|cask|gcloud-cli|Google Cloud CLI
cask:google-chrome|browsers|cask|google-chrome|Google Chrome
cask:tor-browser|browsers|cask|tor-browser|Tor Browser
cask:slack|communication|cask|slack|Slack
cask:discord|communication|cask|discord|Discord
cask:zoom|communication|cask|zoom|Zoom
cask:microsoft-teams|communication|cask|microsoft-teams|Microsoft Teams
cask:chatgpt|ai|cask|chatgpt|ChatGPT
cask:ollama|ai|cask|ollama|Ollama
cask:lm-studio|ai|cask|lm-studio|LM Studio
cask:kap|media|cask|kap|Kap
cask:obs|media|cask|obs|OBS
cask:vlc|media|cask|vlc|VLC
cask:appcleaner|utilities|cask|appcleaner|AppCleaner
cask:keka|utilities|cask|keka|Keka
cask:keyboard-cowboy|utilities|cask|keyboard-cowboy|Keyboard Cowboy
cask:leader-key|utilities|cask|leader-key|Leader Key
cask:obsidian|utilities|cask|obsidian|Obsidian
cask:shottr|utilities|cask|shottr|Shottr
cask:tailscale|utilities|cask|tailscale|Tailscale
cask:flux|utilities|cask|flux|Flux
cask:home-assistant|utilities|cask|home-assistant|Home Assistant
cask:browserosaurus|utilities|cask|browserosaurus|Browserosaurus
cask:lulu|security|cask|lulu|LuLu
cask:blockblock|security|cask|blockblock|BlockBlock
cask:knockknock|security|cask|knockknock|KnockKnock
cask:taskexplorer|security|cask|taskexplorer|TaskExplorer
cask:bambu-studio|printing3d|cask|bambu-studio|Bambu Studio
cask:orcaslicer|printing3d|cask|orcaslicer|OrcaSlicer
cask:prusaslicer|printing3d|cask|prusaslicer|PrusaSlicer
cask:shapr3d|printing3d|cask|shapr3d|Shapr3D
mas:497799835|mas-extras|mas|497799835|Xcode
mas:6738274497|mas-extras|mas|6738274497|Raycast Companion
mas:6714467650|mas-extras|mas|6714467650|Perplexity
mas:1295203466|mas-extras|mas|1295203466|Microsoft Remote Desktop
mas:1453273600|mas-extras|mas|1453273600|Data Jar
mas:1586435171|mas-extras|mas|1586435171|Actions
EOF
}

catalog_module_lines() {
  local selected_module="$1"
  while IFS='|' read -r key module type ref name; do
    [[ -z "$key" ]] && continue
    [[ "$module" == "$selected_module" ]] && printf '%s|%s|%s|%s|%s\n' "$key" "$module" "$type" "$ref" "$name"
  done < <(catalog_packages)
}

catalog_package_line_by_key() {
  local package_key="$1"
  while IFS='|' read -r key module type ref name; do
    [[ -z "$key" ]] && continue
    if [[ "$key" == "$package_key" ]]; then
      printf '%s|%s|%s|%s|%s\n' "$key" "$module" "$type" "$ref" "$name"
      return 0
    fi
  done < <(catalog_packages)
  return 1
}

catalog_module_title() {
  local module_id="$1"
  while IFS='|' read -r id phase title description; do
    [[ "$id" == "$module_id" ]] && { printf '%s\n' "$title"; return 0; }
  done < <(catalog_modules)
  printf '%s\n' "$module_id"
}
