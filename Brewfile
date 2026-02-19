# Brewfile - macOS Bootstrap v2
# Base packages installed on ALL machine profiles.
# Profile-specific additions are in profiles/Brewfile.<profile>
#
# Verified tokens as of 2026-02-18 on macOS Sequoia (15.x)
# Run `brew bundle check` to verify before a full install.
#
# Notes:
#   - mole and dockutil are formulae (not casks)
#   - lm-studio is the correct cask token (not lmstudio)
#   - enconvo has no Homebrew cask — install manually from enconvo.com
#   - ankerslicer has no Homebrew cask — install manually
#   - browserosaurus is deprecated (will disable Aug 2026) — kept for now
#   - Audible is NOT on the Mac App Store — removed

# ============================================
# Taps
# ============================================
tap "homebrew/bundle"
tap "homebrew/services"
tap "hashicorp/tap"
tap "anomalyco/tap"           # opencode CLI

# ============================================
# Formulae (CLI tools)
# ============================================

# Core shell / terminal utilities
brew "atuin"                  # Shell history with sync (replaces zsh_history search)
brew "eza"                    # Modern ls replacement (with icons + git status)
brew "fastfetch"              # System info display (replaces deprecated neofetch)
brew "fzf"                    # Fuzzy finder
brew "starship"               # Cross-shell prompt (replaces OMZ themes)
brew "zellij"                 # Terminal multiplexer (replaces tmux)
brew "zoxide"                 # Smart cd with frecency ranking

# ZSH plugins (sourced from Homebrew prefix)
brew "zsh-autosuggestions"    # Fish-style inline suggestions
brew "zsh-syntax-highlighting" # Command syntax highlighting

# Dotfile management
brew "chezmoi"                # Dotfile manager with 1Password integration

# Core utilities
brew "age"                    # Modern file encryption
brew "awscli"                 # AWS command-line interface
brew "chroma"                 # Syntax highlighting (used by various tools)
brew "dockutil"               # Dock management via CLI (formula, not cask)
brew "duti"                   # Set default apps for file types
brew "mas"                    # Mac App Store CLI
brew "mole"                   # SSH tunnel manager (formula, not cask)
brew "pinentry-mac"           # GPG pinentry dialog for macOS Keychain
brew "pygments"               # Syntax highlighting library (Python)
brew "switchaudio-osx"        # CLI audio device switcher
brew "watch"                  # Run commands periodically

# DevOps / Infrastructure
brew "helm"                   # Kubernetes package manager
brew "k9s"                    # Kubernetes cluster TUI
brew "kube-ps1"               # K8s context/namespace in shell prompt
brew "kubectx"                # Fast Kubernetes context/namespace switching
brew "kubernetes-cli"         # kubectl
brew "hashicorp/tap/terraform" # Terraform (official HashiCorp tap)

# AI / developer tools
brew "anomalyco/tap/opencode" # opencode CLI (AI coding assistant)

# ============================================
# Casks (GUI applications)
# ============================================

# Security / Password management
cask "1password"              # Password manager (install early — needed for auth)
cask "1password-cli"          # 1Password CLI (op) for chezmoi secrets

# Productivity
cask "clickup"                # Project management
cask "notion"                 # Notes and docs
cask "notion-calendar"        # Notion calendar
cask "notion-mail"            # Notion mail client
cask "pronotes"               # Quick notes
cask "raycast"                # Launcher and productivity tool (replaces Spotlight)

# Browsers
cask "firefox"                # Firefox browser
cask "google-chrome"          # Chrome browser
cask "tor-browser"            # Tor browser for privacy

# Communication
cask "discord"                # Discord
cask "signal"                 # Encrypted messaging
cask "slack"                  # Team communication
cask "zoom"                   # Video conferencing

# Development
cask "docker"                 # Docker Desktop
cask "drawio"                 # Diagramming
cask "ghostty"                # GPU-accelerated terminal emulator
cask "orbstack"               # Fast Docker/Linux on Mac (lighter than Docker Desktop)
cask "postman"                # API testing
cask "powershell"             # PowerShell (cross-platform)
cask "sequel-ace"             # MySQL / MariaDB database client
cask "visual-studio-code"     # Code editor

# Media / content
cask "handbrake"              # Video transcoder
cask "kap"                    # Screen recorder (replaces screenshot shortcuts)
cask "obs"                    # Open Broadcaster Software (streaming/recording)
cask "subler"                 # MP4 / MKV metadata editor
cask "vlc"                    # Media player

# Utilities
cask "android-file-transfer"  # Transfer files to/from Android devices
cask "appcleaner"             # Clean uninstall apps
cask "balenaetcher"           # Flash OS images to USB/SD
cask "browserosaurus"         # Browser picker (deprecated Aug 2026, keeping for now)
cask "cyberduck"              # FTP / S3 / cloud storage browser
cask "dash"                   # Offline API documentation
cask "disk-inventory-x"       # Disk usage visualizer
cask "flux"                   # Screen color temperature adjustment
cask "jordanbaird-ice"        # Menu bar management (replaces Vanilla/Stats)
cask "keka"                   # Archive utility
cask "keyboard-cowboy"        # Keyboard shortcut automation
cask "knockknock"             # Persistent macOS process monitor
cask "latest"                 # App update checker
cask "leader-key"             # Leader-key based shortcuts
cask "lunar"                  # External monitor brightness control
cask "mactracker"             # Apple hardware database
cask "mullvadvpn"             # VPN client
cask "raspberry-pi-imager"    # Raspberry Pi OS flasher
cask "session-manager-plugin" # AWS SSM Session Manager plugin
cask "shottr"                 # Screenshot tool with annotation
cask "suspicious-package"     # Inspect .pkg installers before running
cask "taskexplorer"           # Process/task inspector
cask "teamviewer"             # Remote desktop
cask "the-unarchiver"         # Archive extraction
cask "utm"                    # Virtual machines on Apple Silicon
cask "wireshark"              # Network protocol analyzer

# AI tools
cask "anythingllm"            # Local AI document assistant
cask "chatgpt"                # ChatGPT desktop app
cask "lm-studio"              # Local LLM runner (was: lmstudio — incorrect token)
cask "ollama"                 # Local LLM runner (CLI-focused)

# 3D printing / design
cask "blender"                # 3D creation suite
cask "eufymake-studio"        # EufyMake / AnkerMake slicer (replaces deprecated ankermake cask)
cask "openscad"               # Programmatic 3D CAD
cask "orcaslicer"             # Orca Slicer for 3D printing
cask "shapr3d"                # 3D CAD for iPad/Mac

# Fonts
cask "font-jetbrains-mono-nerd-font"  # JetBrains Mono with Nerd Font icons

# Security (install last to avoid popup interference during setup)
cask "lulu"                   # Outbound firewall
cask "blockblock"             # Monitors persistence locations

# ============================================
# Mac App Store Apps
# ============================================
# Note: Requires being signed into the Mac App Store before running.
# Run `mas signin` or sign in via the App Store GUI first.

# Safari Extensions
mas "1Password for Safari",        id: 1569813296
mas "Auto HD FPS for YouTube",     id: 1546729687
mas "DuckDuckGo Privacy Essentials",id: 1482920575
mas "PayPal Honey",                 id: 1472777122
mas "Raindrop.io",                  id: 1549370672
mas "Userscripts",                  id: 1463298887

# Productivity apps
mas "Actions",                      id: 1586435171  # Shortcuts actions
mas "AudioBookBinder",              id: 413969927
mas "Data Jar",                     id: 1453273600
mas "Disk Speed Test",              id: 425264550
mas "DuckDuckGo",                   id: 663592361   # DuckDuckGo browser
mas "Exporter",                     id: 1099120373  # Export iMessages
mas "Just Focus",                   id: 1142151959  # Pomodoro timer
mas "Microsoft Remote Desktop",     id: 1295203466
mas "Perplexity",                   id: 6714467650  # AI search
mas "Presentify",                   id: 1507246666  # Screen annotation
mas "Tailscale",                    id: 1475387142  # VPN mesh network
mas "Twitter",                      id: 1482454543
mas "WireGuard",                    id: 1451685025
mas "Xcode",                        id: 497799835
