# Brewfile - macOS Bootstrap v2
# Base packages installed on ALL machine profiles.
# Profile-specific additions are in profiles/Brewfile.<profile>
#
# Verified tokens as of 2026-02-19 on macOS Sequoia (15.x)
# Run `brew bundle check` to verify before a full install.
#
# Notes:
#   - mole and dockutil are formulae (not casks)
#   - lm-studio is the correct cask token (not lmstudio)
#   - enconvo has no Homebrew cask — install manually from enconvo.com
#   - ankerslicer has no Homebrew cask — install manually
#   - browserosaurus is deprecated (will disable Aug 2026) — kept for now
#   - Audible is NOT on the Mac App Store — removed
#   - openscad@snapshot preferred over openscad (stable is outdated 2021.01)

# ============================================
# Taps
# ============================================
tap "hashicorp/tap"
tap "anomalyco/tap"           # opencode CLI
tap "oven-sh/bun"             # Bun JavaScript runtime

# ============================================
# Formulae (CLI tools)
# ============================================

# Core shell / terminal utilities
brew "atuin"                  # Shell history with sync (replaces zsh_history search)
brew "bat"                    # Better cat with syntax highlighting
brew "bat-extras"             # bat integrations (batgrep, batman, etc.)
brew "carapace"               # Multi-shell multi-command argument completer
brew "eza"                    # Modern ls replacement (with icons + git status)
brew "fastfetch"              # System info display (replaces deprecated neofetch)
brew "fd"                     # Fast find replacement (used by fzf as default command)
brew "fzf"                    # Fuzzy finder
brew "starship"               # Cross-shell prompt (replaces OMZ themes)
brew "tmux"                   # Terminal multiplexer (keeping alongside zellij for now)
brew "zellij"                 # Modern terminal multiplexer
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
brew "fabric-ai"              # AI augmentation framework
brew "ffmpeg"                 # Audio/video conversion and streaming
brew "gh"                     # GitHub CLI
brew "gemini-cli"             # Google Gemini AI command-line interface
brew "mas"                    # Mac App Store CLI
brew "mole"                   # SSH tunnel manager (formula, not cask)
brew "pygments"               # Syntax highlighting library (Python)
brew "switchaudio-osx"        # CLI audio device switcher
brew "watch"                  # Run commands periodically
brew "yt-dlp"                 # Feature-rich audio/video downloader

# JavaScript runtime
brew "oven-sh/bun/bun"        # Bun — fast JavaScript runtime, bundler, and package manager

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
cask "raycast"                # Launcher and productivity tool (replaces Spotlight)

# Browsers
cask "brave-browser"          # Brave privacy browser
cask "google-chrome"          # Chrome browser
cask "tor-browser"            # Tor browser for privacy

# Communication
cask "discord"                # Gaming and community chat
cask "slack"                  # Team communication
cask "zoom"                   # Video conferencing

# Development
cask "antigravity"            # AI coding IDE
cask "claude"                 # Anthropic Claude desktop app
cask "claude-code"            # Claude Code CLI
cask "codex"                  # OpenAI Codex agent
cask "docker"                 # Docker Desktop
cask "gcloud-cli"             # Google Cloud SDK
cask "ghostty"                # GPU-accelerated terminal emulator
cask "opencode-desktop"       # opencode desktop client
cask "orbstack"               # Fast Docker/Linux on Mac (lighter than Docker Desktop)
cask "visual-studio-code"     # Code editor
cask "yaak"                   # REST, GraphQL and gRPC API client

# Media / content
cask "handbrake"              # Video transcoder
cask "kap"                    # Screen recorder (replaces screenshot shortcuts)
cask "obs"                    # Open Broadcaster Software (streaming/recording)
cask "vlc"                    # Media player

# AI tools
cask "chatgpt"                # ChatGPT desktop app
cask "lm-studio"              # Local LLM runner with GUI
cask "ollama"                 # Local LLM runner (CLI-focused)

# Utilities
cask "appcleaner"             # Thorough app uninstaller
cask "balenaetcher"           # Flash OS images to USB/SD
cask "browserosaurus"         # Browser picker (deprecated Aug 2026, keeping for now)
cask "disk-inventory-x"       # Disk usage visualizer
cask "flux"                   # Screen color temperature adjustment
cask "handy"                  # Speech-to-text with LLM reformatting
cask "home-assistant"         # Home Assistant companion app
cask "keka"                   # Archive utility
cask "keyboard-cowboy"        # Keyboard shortcut automation
cask "knockknock"             # Persistent macOS process monitor
cask "leader-key"             # Leader-key based shortcuts
cask "lunar"                  # External monitor brightness control
cask "mactracker"             # Apple hardware database
cask "obsidian"               # Knowledge base and note-taking
cask "shottr"                 # Screenshot tool with annotation
cask "superwhisper"           # Dictation tool with LLM reformatting
cask "tailscale"              # Mesh VPN (cask preferred over MAS)
cask "taskexplorer"           # Process/task inspector
cask "the-unarchiver"         # Archive extraction

# 3D printing / design
cask "bambu-studio"           # Bambu Lab slicer
cask "eufymake-studio"        # EufyMake / AnkerMake slicer (replaces deprecated ankermake cask)
cask "openscad@snapshot"       # Programmatic 3D CAD (snapshot build — stable is outdated 2021)
cask "orcaslicer"             # Orca Slicer for 3D printing
cask "prusaslicer"            # PrusaSlicer for 3D printing
cask "shapr3d"                # 3D CAD for iPad/Mac
cask "thumbhost3mf"           # Finder thumbnail previews for .3mf files

# Fonts
cask "font-jetbrains-mono-nerd-font"  # JetBrains Mono with Nerd Font icons

# Security (install last to avoid popup interference during setup)
cask "lulu"                   # Outbound firewall
cask "blockblock"             # Monitors persistence locations

# ============================================
# Mac App Store Apps
# ============================================
# Note: Requires being signed into the Mac App Store before running.
# Sign in via the App Store GUI first.

# Safari Extensions
mas "1Password for Safari",           id: 1569813296
mas "Auto HD FPS for YouTube",        id: 1546729687
mas "DuckDuckGo Privacy Essentials",  id: 1482920575
mas "Hush",                           id: 1544743900   # Cookie/notification banner blocker
mas "PayPal Honey",                   id: 1472777122
mas "The Camelizer",                  id: 1532579087   # Amazon price history tracker
mas "uBlock Origin Lite",             id: 6745342698   # Ad blocker for Safari
mas "Userscripts",                    id: 1463298887

# Obsidian extensions
mas "Obsidian Web Clipper",           id: 6720708363

# Productivity apps
mas "Actions",                        id: 1586435171   # Shortcuts actions
mas "Data Jar",                       id: 1453273600
mas "DuckDuckGo",                     id: 663592361    # DuckDuckGo browser
mas "Microsoft Remote Desktop",       id: 1295203466
mas "Perplexity",                     id: 6714467650   # AI search
mas "Raycast Companion",              id: 6738274497
mas "Xcode",                          id: 497799835
